import '../core/nav_math.dart';

class PortRef {
  final String name;
  final double lat;
  final double lon;
  final String kind;

  const PortRef(this.name, this.lat, this.lon, this.kind);
}

const turkishPorts = <PortRef>[
  PortRef('İstanbul', 41.0082, 28.9784, 'liman'),
  PortRef('Haydarpaşa', 41.0030, 29.0150, 'liman'),
  PortRef('Ambarlı', 40.9680, 28.6850, 'liman'),
  PortRef('Tekirdağ', 40.9780, 27.5110, 'liman'),
  PortRef('Bandırma', 40.3520, 27.9700, 'liman'),
  PortRef('Gemlik', 40.4300, 29.1550, 'liman'),
  PortRef('İzmit', 40.7650, 29.9400, 'liman'),
  PortRef('Yalova', 40.6550, 29.2750, 'liman'),
  PortRef('Çanakkale', 40.1460, 26.4060, 'liman'),
  PortRef('İzmir', 38.4230, 27.1430, 'liman'),
  PortRef('Aliağa', 38.8000, 26.9700, 'liman'),
  PortRef('Nemrut', 38.7750, 26.9100, 'liman'),
  PortRef('Mersin', 36.8000, 34.6450, 'liman'),
  PortRef('İskenderun', 36.5800, 36.1700, 'liman'),
  PortRef('Antalya', 36.8850, 30.7000, 'liman'),
  PortRef('Samsun', 41.2900, 36.3300, 'liman'),
  PortRef('Trabzon', 41.0050, 39.7200, 'liman'),
  PortRef('Zonguldak', 41.4550, 31.7900, 'liman'),
  PortRef('Bartın', 41.7500, 32.3800, 'liman'),
  PortRef('Ereğli', 41.2800, 31.4200, 'liman'),
  PortRef('Boğaz (Kuzey)', 41.2200, 29.1300, 'darbogaz'),
  PortRef('Boğaz (Güney)', 40.9960, 29.0000, 'darbogaz'),
  PortRef('Çanakkale Boğazı', 40.2000, 26.4000, 'darbogaz'),
  PortRef('Türkeli Feneri', 41.2340, 29.1100, 'faro'),
  PortRef('Ahırkapı Feneri', 41.0060, 28.9850, 'faro'),
  PortRef('Fenerbahçe', 40.9680, 29.0330, 'faro'),
  PortRef('Gelibolu', 40.4100, 26.6700, 'liman'),
  PortRef('Kepez', 40.1800, 26.3700, 'faro'),
  PortRef('Foça', 38.6700, 26.7500, 'liman'),
  PortRef('Kuşadası', 37.8600, 27.2600, 'liman'),
  PortRef('Bodrum', 37.0350, 27.4300, 'liman'),
  PortRef('Marmaris', 36.8500, 28.2700, 'liman'),
  PortRef('Fethiye', 36.6200, 29.1200, 'liman'),
];

class PortDistance {
  final PortRef port;
  final double nm;
  final double bearing;
  const PortDistance(this.port, this.nm, this.bearing);
}

List<PortDistance> nearestPorts(double lat, double lon, {int limit = 8}) {
  final list = <PortDistance>[
    for (final p in turkishPorts)
      PortDistance(
        p,
        NavMath.distanceNm(lat, lon, p.lat, p.lon),
        NavMath.bearingDeg(lat, lon, p.lat, p.lon),
      ),
  ]..sort((a, b) => a.nm.compareTo(b.nm));
  return list.take(limit).toList();
}
