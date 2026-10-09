# Kaptan Asistanı

Ticari gemiler için Android seyir asistanı (1.2.0)

## Özellikler

- **Harita:** OSM / ESRI + OpenSeaMap deniz işaretleri
- **Gemi işareti:** COG yönünde üçgen (ok ucu); AIS yeşil / tehlike kırmızı
- **Seyir planı:** Dokunarak waypoint, mesafe (NM), kerteriz, ETA
- **SOG / COG:** GPS üzerinden canlı hız ve rota
- **AIS:** Canlı gemi takibi (aisstream.io) + filtre (tümü / yakın / tehlikeli)
- **CPA / TCPA:** Yakınlaşma hesabı, tehlike uyarısı, haritada CPA çizgisi
- **Çapa nöbeti:** Demir noktası + yarıçap; drift alarmı
- **MOB:** Tek dokunuşla kişi denize düştü işareti + mesafe/kerteriz
- **GPX:** Plan / MOB / çapa panoya GPX olarak kopyalama
- **Deniz havası:** Open-Meteo (rüzgar, dalga, swell, sıcaklık)
- **Ayarlar:** Seyir hızı, draft, CPA/TCPA, çapa yarıçapı, AIS filtre

## Araç çubuğu (harita)

| İkon | İşlev |
|------|--------|
| Plan | Waypoint ekleme modu |
| Klasör | Kayıtlı planlar |
| Katmanlar | Seamark / harita / AIS |
| Konum | Gemiyi ortala |
| Çapa | Çapa nöbeti aç/kapa |
| Kişi | MOB işareti |
| Dosya | GPX panoya kopyala |

## APK

1. GitHub **Actions** → yeşil build
2. **Artifacts** → `KaptanAsistani-APK` indir
3. Telefondaki eski uygulamayı sil, yeni APK kur

Yardımıcı araçtır. Resmi ENC/ECDIS yerine geçmez.

MIT License
