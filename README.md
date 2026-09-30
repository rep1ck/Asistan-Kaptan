# Kaptan Asistani

**Ticari gemiler icin Android seyir asistani (MVP 1.0)**

Ucretsiz / acik kaynak. Resmi ECDIS / ENC yerine gecmez.

## Ozellikler (MVP)

- Global harita: OpenStreetMap + OpenSeaMap seamark
- GPS: konum, SOG, COG
- Haritaya dokun → seyir plani (mesafe NM, kerteriz, ETA)
- Deniz havasi: ruzgar, dalga, swell (Open-Meteo)
- Gemi ayarlari: cruise kn, draft, CPA/TCPA esikleri
- Sadece Android

## APK (GitHub Actions)

1. Bu repoyu GitHub'a push et
2. Actions → Build Android APK
3. Artifacts → KaptanAsistani-APK indir

## Yerel derleme

```bash
flutter create . --platforms=android
flutter pub get
flutter build apk --release
```

## Uyari

Yardimci aractir. Kopru prosedurleri, resmi harita ve ECDIS esas alinmalidir.

MIT License
