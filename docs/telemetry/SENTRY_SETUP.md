# Rafça — Sentry Telemetri ve Hata Takibi Kurulum Kılavuzu

Rafça, `sentry_flutter` SDK'sı ile entegre çalışacak şekilde tasarlanmıştır.

## 1. Sentry Projesi Oluşturma
1. [sentry.io](https://sentry.io/) paneline giriş yapın.
2. **Projects > Create Project** butonuna tıklayın.
3. Platform olarak **Flutter** seçin.
4. Proje adı: `rafca`
5. Proje oluşturulduktan sonra **Client Keys (DSN)** bölümündeki DSN adresini kopyalayın (Örn: `https://abcd1234@o12345.ingest.sentry.io/67890`).

## 2. Derleme / Çalıştırma Sırasında DSN Tanımlama

DSN derleme aşamasında `--dart-define` ile enjekte edilir. Bu sayede hiçbir gizli anahtar kaynak kod deposuna yazılmaz.

### Geliştirme (Debug)
```bash
cd app
flutter run --dart-define=SENTRY_DSN="https://your-dsn@o0.ingest.sentry.io/0"
```

### Android Release Derleme (AAB / APK)
```bash
cd app
flutter build appbundle --release --dart-define=SENTRY_DSN="https://your-dsn@o0.ingest.sentry.io/0"
```

### iOS Release Derleme (IPA)
```bash
cd app
flutter build ipa --release --dart-define=SENTRY_DSN="https://your-dsn@o0.ingest.sentry.io/0"
```

## 3. Çevrimdışı ve Gizlilik Garantisi
- DSN girilmediğinde uygulama **sıfır ağ çağrısı** yapar; hatalar cihaz içinde `OfflineErrorQueue` (FIFO, max 50) üzerinde tutulur.
- Ekran görüntüsü ve kişisel veri gönderimi devre dışıdır (`attachScreenshot: false`, `sendDefaultPii: false`).
- Kitaplık içeriği, kamera fotoğrafları ve kullanıcı meta verileri asla Sentry'ye gönderilmez.
