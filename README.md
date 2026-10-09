# Kaptan Asistanı

Ticari gemiler için Android seyir asistanı (1.1.0)

## Özellikler

- **Harita:** OSM / ESRI + OpenSeaMap deniz işaretleri
- **Seyir planı:** Dokunarak waypoint, mesafe (NM), kerteriz, ETA
- **SOG / COG:** GPS üzerinden canlı hız ve rota
- **AIS:** Canlı gemi takibi (aisstream.io)
- **CPA / TCPA:** Yakınlaşma hesabı ve tehlike uyarısı (v1.1)
- **Deniz havası:** Open-Meteo (rüzgar, dalga, swell, sıcaklık)
- **Ayarlar:** Seyir hızı, draft, CPA/TCPA eşikleri, AIS anahtarı
- **Plan kaydet / yükle:** Yerel depolama

## CPA / TCPA (yeni)

AIS açıkken diğer gemilere göre:
- **CPA** (Closest Point of Approach) — en yakın geçiş mesafesi (NM)
- **TCPA** — CPA’ya kalan süre (dakika)

Ayarlardaki eşiklerin altındaki yaklaşımlar kırmızı işaretlenir. Gemi ikonuna dokunarak detay görünür.

## APK

1. GitHub **Actions** → yeşil build
2. **Artifacts** → `KaptanAsistani-APK` indir
3. Telefondaki eski uygulamayı sil, yeni APK kur

Yardımıcı araçtır. Resmi ENC/ECDIS yerine geçmez.

MIT License
