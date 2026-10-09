import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class AisVessel {
  final int mmsi;
  final String name;
  final double lat;
  final double lon;
  final double? sogKn;
  final double? cogDeg;
  final DateTime updated;

  AisVessel({
    required this.mmsi,
    required this.name,
    required this.lat,
    required this.lon,
    this.sogKn,
    this.cogDeg,
    required this.updated,
  });
}

enum AisConnectionState { idle, connecting, connected, error }

/// Real-time AIS via aisstream.io WebSocket.
class AisService {
  WebSocketChannel? _ch;
  final _ctrl = StreamController<Map<int, AisVessel>>.broadcast();
  final Map<int, AisVessel> _vessels = {};
  final Map<int, String> _names = {};
  Timer? _prune;
  String? _lastError;
  AisConnectionState state = AisConnectionState.idle;

  Stream<Map<int, AisVessel>> get stream => _ctrl.stream;
  Map<int, AisVessel> get snapshot => Map.unmodifiable(_vessels);
  String? get lastError => _lastError;
  bool get isConnected => state == AisConnectionState.connected;

  Future<bool> start({
    required String apiKey,
    required double lat,
    required double lon,
    /// ~2° ≈ 120 NM — sparse regions (inland / open sea)
    double deltaDeg = 2.0,
  }) async {
    await stop();
    _lastError = null;
    state = AisConnectionState.connecting;

    final key = apiKey.trim();
    if (key.isEmpty) {
      _lastError = 'API anahtarı boş — Ayarlar’dan girin';
      state = AisConnectionState.error;
      return false;
    }

    final swLat = (lat - deltaDeg).clamp(-90.0, 90.0);
    final neLat = (lat + deltaDeg).clamp(-90.0, 90.0);
    final swLon = (lon - deltaDeg).clamp(-180.0, 180.0);
    final neLon = (lon + deltaDeg).clamp(-180.0, 180.0);

    try {
      _ch = WebSocketChannel.connect(
        Uri.parse('wss://stream.aisstream.io/v0/stream'),
      );

      final sub = jsonEncode({
        'APIKey': key,
        'BoundingBoxes': [
          [
            [swLat, swLon],
            [neLat, neLon],
          ]
        ],
        'FilterMessageTypes': [
          'PositionReport',
          'StandardClassBPositionReport',
          'ExtendedClassBPositionReport',
          'ShipStaticData',
        ],
      });
      _ch!.sink.add(sub);
      state = AisConnectionState.connected;

      _ch!.stream.listen(
        (raw) {
          try {
            final text = _asText(raw);
            if (text == null || text.isEmpty) return;
            final data = jsonDecode(text) as Map<String, dynamic>;
            final type = data['MessageType'] as String?;
            if (type == null) return;

            if (type == 'SubscriptionConfirmation') {
              state = AisConnectionState.connected;
              _lastError = null;
              return;
            }

            if (type.toLowerCase().contains('error')) {
              _lastError =
                  text.length > 120 ? '${text.substring(0, 120)}…' : text;
              state = AisConnectionState.error;
              return;
            }

            final meta = data['MetaData'] as Map<String, dynamic>? ?? {};
            final msgRoot = data['Message'] as Map<String, dynamic>? ?? {};
            final body = (msgRoot[type] as Map<String, dynamic>?) ??
                (msgRoot['PositionReport'] as Map<String, dynamic>?) ??
                (msgRoot['ShipStaticData'] as Map<String, dynamic>?) ??
                {};

            final mmsi = _asInt(meta['MMSI']) ??
                _asInt(meta['MMSI_String']) ??
                _asInt(body['UserID']);
            if (mmsi == null) return;

            if (type == 'ShipStaticData') {
              final n = (body['Name'] as String?)?.trim() ??
                  (meta['ShipName'] as String?)?.trim() ??
                  '';
              if (n.isNotEmpty) _names[mmsi] = n;
              return;
            }

            final vLat = _asDouble(meta['latitude']) ??
                _asDouble(meta['Latitude']) ??
                _asDouble(body['Latitude']);
            final vLon = _asDouble(meta['longitude']) ??
                _asDouble(meta['Longitude']) ??
                _asDouble(body['Longitude']);
            if (vLat == null || vLon == null) return;
            if (vLat < -90 || vLat > 90 || vLon < -180 || vLon > 180) return;

            final nameMeta = (meta['ShipName'] as String?)?.trim() ?? '';
            final name = nameMeta.isNotEmpty
                ? nameMeta
                : (_names[mmsi] ?? 'MMSI $mmsi');
            final sog = _asDouble(body['Sog']);
            final cog = _asDouble(body['Cog']);

            _vessels[mmsi] = AisVessel(
              mmsi: mmsi,
              name: name,
              lat: vLat,
              lon: vLon,
              sogKn: sog != null && sog >= 0 && sog < 102.3 ? sog : null,
              cogDeg: cog != null && cog >= 0 && cog < 360 ? cog : null,
              updated: DateTime.now(),
            );
            if (!_ctrl.isClosed) _ctrl.add(snapshot);
          } catch (_) {}
        },
        onError: (e) {
          _lastError = 'Bağlantı hatası: $e';
          state = AisConnectionState.error;
        },
        onDone: () {
          if (state != AisConnectionState.error) {
            _lastError = 'AIS bağlantısı kapandı';
          }
          state = AisConnectionState.error;
        },
        cancelOnError: false,
      );

      _prune = Timer.periodic(const Duration(seconds: 45), (_) {
        final cut = DateTime.now().subtract(const Duration(minutes: 20));
        _vessels.removeWhere((_, v) => v.updated.isBefore(cut));
        if (!_ctrl.isClosed) _ctrl.add(snapshot);
      });
      return true;
    } catch (e) {
      _lastError = 'AIS açılamadı: $e';
      state = AisConnectionState.error;
      return false;
    }
  }

  String? _asText(dynamic raw) {
    if (raw is String) return raw;
    if (raw is List<int>) {
      try {
        return utf8.decode(raw);
      } catch (_) {
        return null;
      }
    }
    try {
      return raw.toString();
    } catch (_) {
      return null;
    }
  }

  int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  double? _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  Future<void> stop() async {
    _prune?.cancel();
    _prune = null;
    try {
      await _ch?.sink.close();
    } catch (_) {}
    _ch = null;
    _vessels.clear();
    state = AisConnectionState.idle;
    if (!_ctrl.isClosed) _ctrl.add({});
  }

  void dispose() {
    stop();
    _ctrl.close();
  }
}
