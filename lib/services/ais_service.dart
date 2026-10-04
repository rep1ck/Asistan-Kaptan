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

/// Real-time AIS via free aisstream.io WebSocket.
class AisService {
  WebSocketChannel? _ch;
  final _ctrl = StreamController<Map<int, AisVessel>>.broadcast();
  final Map<int, AisVessel> _vessels = {};
  Timer? _prune;
  String? _lastError;

  Stream<Map<int, AisVessel>> get stream => _ctrl.stream;
  Map<int, AisVessel> get snapshot => Map.unmodifiable(_vessels);
  String? get lastError => _lastError;

  Future<bool> start({
    required String apiKey,
    required double lat,
    required double lon,
    double deltaDeg = 1.0,
  }) async {
    await stop();
    _lastError = null;
    final key = apiKey.trim();
    if (key.isEmpty) {
      _lastError = 'API key empty';
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
        ],
      });
      _ch!.sink.add(sub);

      _ch!.stream.listen(
        (raw) {
          try {
            final text = _asText(raw);
            if (text == null || text.isEmpty) return;
            final data = jsonDecode(text) as Map<String, dynamic>;
            final type = data['MessageType'] as String?;
            if (type == null) return;
            if (type == 'SubscriptionConfirmation') return;

            final meta = data['MetaData'] as Map<String, dynamic>? ?? {};
            final msgRoot = data['Message'] as Map<String, dynamic>? ?? {};
            final pr = (msgRoot[type] as Map<String, dynamic>?) ??
                (msgRoot['PositionReport'] as Map<String, dynamic>?) ??
                {};

            final mmsi = _asInt(meta['MMSI']) ??
                _asInt(meta['MMSI_String']) ??
                _asInt(pr['UserID']);
            if (mmsi == null) return;

            final vLat = _asDouble(meta['latitude']) ??
                _asDouble(meta['Latitude']) ??
                _asDouble(pr['Latitude']);
            final vLon = _asDouble(meta['longitude']) ??
                _asDouble(meta['Longitude']) ??
                _asDouble(pr['Longitude']);
            if (vLat == null || vLon == null) return;
            if (vLat < -90 || vLat > 90 || vLon < -180 || vLon > 180) return;

            final name = (meta['ShipName'] as String?)?.trim() ?? '';
            final sog = _asDouble(pr['Sog']);
            final cog = _asDouble(pr['Cog']);

            _vessels[mmsi] = AisVessel(
              mmsi: mmsi,
              name: name.isEmpty ? 'MMSI $mmsi' : name,
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
          _lastError = e.toString();
        },
        onDone: () {
          _lastError ??= 'connection closed';
        },
        cancelOnError: false,
      );

      _prune = Timer.periodic(const Duration(seconds: 30), (_) {
        final cut = DateTime.now().subtract(const Duration(minutes: 15));
        _vessels.removeWhere((_, v) => v.updated.isBefore(cut));
        if (!_ctrl.isClosed) _ctrl.add(snapshot);
      });
      return true;
    } catch (e) {
      _lastError = e.toString();
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
    if (!_ctrl.isClosed) _ctrl.add({});
  }

  void dispose() {
    stop();
    _ctrl.close();
  }
}
