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
  final double? headingDeg;
  final int? navStatus;
  final DateTime updated;

  // Static / voyage (AIS type 5)
  final int? imo;
  final String? callSign;
  final int? shipType;
  final double? draughtM;
  final String? destination;
  final String? etaText;
  final double? loaM;
  final double? beamM;

  AisVessel({
    required this.mmsi,
    required this.name,
    required this.lat,
    required this.lon,
    this.sogKn,
    this.cogDeg,
    this.headingDeg,
    this.navStatus,
    required this.updated,
    this.imo,
    this.callSign,
    this.shipType,
    this.draughtM,
    this.destination,
    this.etaText,
    this.loaM,
    this.beamM,
  });

  AisVessel copyWith({
    String? name,
    double? lat,
    double? lon,
    double? sogKn,
    double? cogDeg,
    double? headingDeg,
    int? navStatus,
    DateTime? updated,
    int? imo,
    String? callSign,
    int? shipType,
    double? draughtM,
    String? destination,
    String? etaText,
    double? loaM,
    double? beamM,
  }) {
    return AisVessel(
      mmsi: mmsi,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      sogKn: sogKn ?? this.sogKn,
      cogDeg: cogDeg ?? this.cogDeg,
      headingDeg: headingDeg ?? this.headingDeg,
      navStatus: navStatus ?? this.navStatus,
      updated: updated ?? this.updated,
      imo: imo ?? this.imo,
      callSign: callSign ?? this.callSign,
      shipType: shipType ?? this.shipType,
      draughtM: draughtM ?? this.draughtM,
      destination: destination ?? this.destination,
      etaText: etaText ?? this.etaText,
      loaM: loaM ?? this.loaM,
      beamM: beamM ?? this.beamM,
    );
  }

  static String navStatusLabel(int? s) {
    switch (s) {
      case 0:
        return 'Motorla seyir';
      case 1:
        return 'Demirde';
      case 2:
        return 'Sürüntüde (kontrollü)';
      case 3:
        return 'Kısıtlı manevra';
      case 4:
        return 'Kısıtlı draft';
      case 5:
        return 'Bağlı';
      case 6:
        return 'Karaya oturmuş';
      case 7:
        return 'Balıkçılık';
      case 8:
        return 'Yelkenle seyir';
      case 14:
        return 'AIS-SART';
      case 15:
        return 'Tanımsız';
      default:
        return s == null ? '—' : 'Kod $s';
    }
  }

  static String shipTypeLabel(int? t) {
    if (t == null) return '—';
    if (t >= 70 && t <= 79) return 'Kargo';
    if (t >= 80 && t <= 89) return 'Tanker';
    if (t >= 60 && t <= 69) return 'Yolcu';
    if (t >= 40 && t <= 49) return 'Yüksek hızlı';
    if (t >= 30 && t <= 39) return 'Balıkçı';
    if (t >= 50 && t <= 59) return 'Özel / destek';
    if (t == 36 || t == 37) return 'Yat / eğlence';
    return 'Tip $t';
  }
}

enum AisConnectionState { idle, connecting, connected, error }

/// Real-time AIS via aisstream.io WebSocket.
class AisService {
  WebSocketChannel? _ch;
  final _ctrl = StreamController<Map<int, AisVessel>>.broadcast();
  final Map<int, AisVessel> _vessels = {};
  final Map<int, _StaticCache> _static = {};
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
          'StaticDataReport',
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
            final body = (msgRoot[type] as Map<String, dynamic>?) ?? {};

            final mmsi = _asInt(meta['MMSI']) ??
                _asInt(meta['MMSI_String']) ??
                _asInt(body['UserID']);
            if (mmsi == null) return;

            if (type == 'ShipStaticData' || type == 'StaticDataReport') {
              _ingestStatic(mmsi, meta, body, type);
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
            final st = _static[mmsi];
            final name = nameMeta.isNotEmpty
                ? nameMeta
                : (st?.name ?? (_vessels[mmsi]?.name ?? 'MMSI $mmsi'));

            final sog = _asDouble(body['Sog']);
            final cog = _asDouble(body['Cog']);
            final hdg = _asDouble(body['TrueHeading']);
            final nav = _asInt(body['NavigationalStatus']);

            final prev = _vessels[mmsi];
            _vessels[mmsi] = AisVessel(
              mmsi: mmsi,
              name: name,
              lat: vLat,
              lon: vLon,
              sogKn: sog != null && sog >= 0 && sog < 102.3 ? sog : prev?.sogKn,
              cogDeg: cog != null && cog >= 0 && cog < 360 ? cog : prev?.cogDeg,
              headingDeg: hdg != null && hdg >= 0 && hdg < 360
                  ? hdg
                  : prev?.headingDeg,
              navStatus: nav ?? prev?.navStatus,
              updated: DateTime.now(),
              imo: st?.imo ?? prev?.imo,
              callSign: st?.callSign ?? prev?.callSign,
              shipType: st?.shipType ?? prev?.shipType,
              draughtM: st?.draughtM ?? prev?.draughtM,
              destination: st?.destination ?? prev?.destination,
              etaText: st?.etaText ?? prev?.etaText,
              loaM: st?.loaM ?? prev?.loaM,
              beamM: st?.beamM ?? prev?.beamM,
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

  void _ingestStatic(int mmsi, Map<String, dynamic> meta,
      Map<String, dynamic> body, String type) {
    final name = _cleanStr(body['Name']) ?? _cleanStr(meta['ShipName']);
    final call = _cleanStr(body['CallSign']);
    final imo = _asInt(body['ImoNumber']);
    final shipType = _asInt(body['Type']) ?? _asInt(body['ShipType']);
    final draught = _asDouble(body['MaximumStaticDraught']);
    final dest = _cleanStr(body['Destination']);

    String? etaText;
    final eta = body['Eta'];
    if (eta is Map) {
      final mo = _asInt(eta['Month']);
      final dy = _asInt(eta['Day']);
      final hr = _asInt(eta['Hour']);
      final mi = _asInt(eta['Minute']);
      if (mo != null && mo >= 1 && mo <= 12 && dy != null && dy >= 1) {
        final h = (hr == null || hr > 23) ? 0 : hr;
        final m = (mi == null || mi > 59) ? 0 : mi;
        etaText =
            '${mo.toString().padLeft(2, '0')}/${dy.toString().padLeft(2, '0')} '
            '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} UTC';
      }
    }

    double? loa;
    double? beam;
    final dim = body['Dimension'];
    if (dim is Map) {
      final a = _asDouble(dim['A']) ?? 0;
      final b = _asDouble(dim['B']) ?? 0;
      final c = _asDouble(dim['C']) ?? 0;
      final d = _asDouble(dim['D']) ?? 0;
      if (a + b > 0) loa = a + b;
      if (c + d > 0) beam = c + d;
    }

    final cache = _StaticCache(
      name: name,
      callSign: call,
      imo: (imo != null && imo > 0) ? imo : null,
      shipType: shipType,
      draughtM:
          (draught != null && draught > 0 && draught < 30) ? draught : null,
      destination: dest,
      etaText: etaText,
      loaM: loa,
      beamM: beam,
    );
    _static[mmsi] = cache;

    final prev = _vessels[mmsi];
    if (prev != null) {
      _vessels[mmsi] = prev.copyWith(
        name: (name != null && name.isNotEmpty) ? name : null,
        imo: cache.imo,
        callSign: cache.callSign,
        shipType: cache.shipType,
        draughtM: cache.draughtM,
        destination: cache.destination,
        etaText: cache.etaText,
        loaM: cache.loaM,
        beamM: cache.beamM,
      );
      if (!_ctrl.isClosed) _ctrl.add(snapshot);
    }
  }

  String? _cleanStr(dynamic v) {
    if (v is! String) return null;
    final s = v.trim();
    if (s.isEmpty || s.replaceAll('@', '').trim().isEmpty) return null;
    return s;
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
    _static.clear();
    state = AisConnectionState.idle;
    if (!_ctrl.isClosed) _ctrl.add({});
  }

  void dispose() {
    stop();
    _ctrl.close();
  }
}

class _StaticCache {
  final String? name;
  final String? callSign;
  final int? imo;
  final int? shipType;
  final double? draughtM;
  final String? destination;
  final String? etaText;
  final double? loaM;
  final double? beamM;

  _StaticCache({
    this.name,
    this.callSign,
    this.imo,
    this.shipType,
    this.draughtM,
    this.destination,
    this.etaText,
    this.loaM,
    this.beamM,
  });
}
