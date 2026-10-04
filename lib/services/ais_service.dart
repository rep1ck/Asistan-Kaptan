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

/// Real-time AIS via free aisstream.io WebSocket (requires free API key).
class AisService {
  WebSocketChannel? _ch;
  final _ctrl = StreamController<Map<int, AisVessel>>.broadcast();
  final Map<int, AisVessel> _vessels = {};
  Timer? _prune;

  Stream<Map<int, AisVessel>> get stream => _ctrl.stream;
  Map<int, AisVessel> get snapshot => Map.unmodifiable(_vessels);

  Future<void> start({
    required String apiKey,
    required double lat,
    required double lon,
    double deltaDeg = 0.6,
  }) async {
    await stop();
    if (apiKey.trim().isEmpty) return;

    final swLat = lat - deltaDeg;
    final neLat = lat + deltaDeg;
    final swLon = lon - deltaDeg;
    final neLon = lon + deltaDeg;

    try {
      _ch = WebSocketChannel.connect(
        Uri.parse('wss://stream.aisstream.io/v0/stream'),
      );
      _ch!.sink.add(jsonEncode({
        'APIKey': apiKey.trim(),
        'BoundingBoxes': [
          [
            [swLat, swLon],
            [neLat, neLon],
          ]
        ],
        'FilterMessageTypes': ['PositionReport'],
      }));

      _ch!.stream.listen(
        (raw) {
          try {
            final data = jsonDecode(raw is String ? raw : raw.toString())
                as Map<String, dynamic>;
            if (data['MessageType'] != 'PositionReport') return;
            final meta = data['MetaData'] as Map<String, dynamic>?;
            final msg = data['Message'] as Map<String, dynamic>?;
            final pr = msg?['PositionReport'] as Map<String, dynamic>?;
            if (meta == null || pr == null) return;

            final mmsi = (meta['MMSI'] as num?)?.toInt() ??
                (pr['UserID'] as num?)?.toInt();
            if (mmsi == null) return;

            final vLat = (meta['latitude'] as num?)?.toDouble() ??
                (pr['Latitude'] as num?)?.toDouble();
            final vLon = (meta['longitude'] as num?)?.toDouble() ??
                (pr['Longitude'] as num?)?.toDouble();
            if (vLat == null || vLon == null) return;

            final name = (meta['ShipName'] as String?)?.trim() ?? '';
            final sog = (pr['Sog'] as num?)?.toDouble();
            final cog = (pr['Cog'] as num?)?.toDouble();

            _vessels[mmsi] = AisVessel(
              mmsi: mmsi,
              name: name.isEmpty ? 'MMSI $mmsi' : name,
              lat: vLat,
              lon: vLon,
              sogKn: sog != null && sog >= 0 && sog < 102 ? sog : null,
              cogDeg: cog != null && cog >= 0 && cog < 360 ? cog : null,
              updated: DateTime.now(),
            );
            _ctrl.add(snapshot);
          } catch (_) {}
        },
        onError: (_) {},
        onDone: () {},
        cancelOnError: false,
      );

      _prune = Timer.periodic(const Duration(seconds: 30), (_) {
        final cut = DateTime.now().subtract(const Duration(minutes: 10));
        _vessels.removeWhere((_, v) => v.updated.isBefore(cut));
        _ctrl.add(snapshot);
      });
    } catch (_) {}
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
