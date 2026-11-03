# Faz 10 — Sertleştirme ve Mağaza (A9 / Hardening & Release Prep)

**Durum: KAPALI.**
**Tarih:** 2026-11-03
**Kapsam:** `SPINE_BLUEPRINT.md` §442-449.

---

## 1. Neler Yapıldı?

### A. Performans Bütçeleri & CI Doğrulama
- Blueprint §443 performans bütçeleri tanımlandı (`app/lib/core/performance/performance_budgets.dart`):
  - **Cold Start:** < 2.0s (2000 ms)
  - **Tarama Pipeline:** < 8.0s (8000 ms)
  - **APK Boyutu:** < 45 MB (47,185,920 bayt)
  - **Tepe Bellek (RAM Peak):** < 250 MB
- `PipelineBenchmarkTracker` ve `BudgetValidationResult` ile ölçüm sınıfları oluşturuldu.
- `scripts/check_performance_budgets.sh` otomatik CI bütçe denetim betiği yazıldı ve `.github/workflows/ci.yml` içine eklendi.
- `test/core/performance_budgets_test.dart` ile bütçe aşım ve doğrulama mantığı birim testlerle mühürlendi.

### B. Hata İzleme ve Çevrimdışı Hata Kuyruğu (Telemetry & Error Handling)
- `OfflineErrorQueue` (`app/lib/core/telemetry/offline_error_queue.dart`):
  - 50 olaylık FIFO bellek korumalı kuyruk, serileştirme ve drenaj desteği.
- `AppTelemetryService` (`app/lib/core/telemetry/telemetry_service.dart`):
  - Ekmek kırıntısı (Breadcrumbs) takibi, Sentry DSN yapılandırması (`isSentryConfigured`), global hata kancaları (`FlutterError.onError`, `PlatformDispatcher.onError`).
- `app/lib/main.dart` içinde telemetri başlangıç entegrasyonu sağlandı.
- `test/core/telemetry_test.dart` ile tam test kapsamı sağlandı.

### C. Gizlilik Metinleri & Mağaza Güvenlik Formları
- **Gizlilik Politikası:** `docs/privacy/PRIVACY_POLICY.md` (TR & EN çift dilli, Blueprint §5 ilkelerine tam sadık: ham fotoğraf ve kırpımlar yalnızca cihazda saklanır, uzak sunucuya görsel gitmez, izleme/reklam yok).
- **Apple App Store Nutrition Label:** `docs/privacy/APP_STORE_NUTRITION_LABEL.md` (Data Used to Track You = None, Data Linked to You = None, Diagnostics = Not Linked).
- **Google Play Data Safety:** `docs/privacy/PLAY_DATA_SAFETY.md` (Üçüncü tarafla paylaşım yok, TLS 1.3 aktarım şifrelemesi, yerel kütüphaneyi sıfırlama mekanizması).

### D. Mağaza Tanıtım ve Test Planları
- **TR & EN Mağaza Metinleri:** `docs/store/STORE_LISTINGS_TR.md` ve `docs/store/STORE_LISTINGS_EN.md` (Nocturnal Archivist tonu, 80 karakterlik kısa açıklama, 4000 karakterlik tam metin, anahtar kelimeler).
- **Google Play 14 Günlük Kapalı Test Planı:** `docs/store/PLAY_CLOSED_TEST_PLAN.md` (12+ test kullanıcısı, 4 fazlık 14 günlük günlük test senaryosu ve geri bildirim kanalları).
- **App Store Connect Kılavuzu:** `docs/store/APP_STORE_CONNECT.md` (Books/Reference kategorileri, 4+ yaş sınırı, TestFlight harici test grubu, şifreleme ihracat muafiyeti).
- **Ekran Görüntüleri Spesifikasyonu:** `docs/store/SCREENSHOTS_SPEC.md` (6.7" ve 6.5" iPhone, tablet ve telefon çözünürlükleri, 6 ekranlık tanıtım akışı).

### E. İkon, Splash ve Tasarım Varlıkları
- Nocturnal Archivist temalı ana vektörel uygulama ikonu: `app/assets/icons/app_icon.svg`.
- Android Adaptive Icon bileşenleri: `app/assets/icons/app_icon_background.svg` ve `app/assets/icons/app_icon_foreground.svg`.
- `app/pubspec.yaml` varlık kaydı tamamlandı.

### F. Kabul Kriteri: Mağaza İnceleme Kontrol Listesi
- **Kabul:** `docs/RELEASE_CHECKLIST.md` hazırlandı ve her iki mağazanın (App Store & Google Play) tüm teknik ve yasal inceleme maddeleri eksiksiz işaretlendi.

---

## 2. Testler ve Doğrulama
- `flutter test` → **124 / 124 test yeşil**.
- `flutter analyze` → **0 issue**.
- `scripts/check_performance_budgets.sh` → **Tüm bütçeler başarıyla doğrulandı**.
- `make test` ve `make analyze` → **Tamamı yeşil**.
