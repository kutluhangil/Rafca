# Faz 9 — Paylaşım ve Yerelleştirme (A9)

**Durum: KAPALI.**
**Tarih:** 2026-11-03
**Kapsam:** `SPINE_BLUEPRINT.md` §436-441.

---

## 1. Neler Yapıldı?

### A. Paylaşılabilir Koleksiyon Kartı (Image 13)
- `ShareCollectionData` veri modeli tanımlandı (`features/share/models/share_models.dart`).
- `ShareCard` bileşeni geliştirildi (`features/share/widgets/share_card.dart`):
  - Nocturnal Archivist tipografisi: `Literata` başlık, `IBM Plex Mono` etiketler ve sayaçlar.
  - Kitap sayısı ve dinamik koleksiyon alt başlığı.
  - Taranan kitapların dominant renklerinden oluşan mini `ShelfStrip`.
  - Kategori etiketleri (`uppercaseForLocale` ile Türkçe İ/I uyumlu).
  - Şık Rafça filigranı ve yakalama tarihi damgası.
- `ShareService` (`features/share/services/share_service.dart`):
  - `RepaintBoundary` üzerinden PNG render alma (`capturePng`).
  - `share_plus` (v13.x `ShareParams`) entegrasyonu ile sistem paylaşım menüsü üzerinden görsel ve metin paylaşımı.
- `ShareBottomSheet` modal bottom sheet (`features/share/widgets/share_bottom_sheet.dart`):
  - Kart canlı önizleme, Hikaye / Mesaj / Bağlantı hızlı paylaşım butonları ve birincil dışa aktarma aksiyonu.
  - `LibraryScreen` ve `ShelfCard` üzerindeki paylaşım ikonlarına bağlandı.

### B. TR/EN Yerelleştirme (i18n & l10n)
- Flutter 3.47+ uyumlu yerelleştirme mimarisi kuruldu:
  - `app/l10n.yaml` (`output-dir: lib/l10n`).
  - `app_tr.arb` (Türkçe kanonik kaynak) ve `app_en.arb` (İngilizce tam karşılıklar).
  - `flutter gen-l10n` ile `AppLocalizations` üretildi.
- `LocaleController` ve `localeControllerProvider` (`core/localization/locale_controller.dart`):
  - Sistem dili, Türkçe ve İngilizce anlık geçiş desteği.
  - `RafcaApp` kök seviyesinde `locale` dinamik dinleyiciye bağlandı.
- **Kabul Kriteri Sağlandı:** Uygulamadaki tüm ekranlardaki sabit kodlanmış metinler (`HomeScreen`, `LibraryScreen`, `BookDetailScreen`, `ShelvesScreen`, `CameraScreen`, `CropScreen`, `PermissionScreen`, `ProcessingScreen`, `ScanResultsScreen`, `ReviewBottomSheet`, `ManualSearchScreen`) `l10n` anahtarlarına taşındı.

### C. Ayarlar Ekranı (SettingsScreen)
- `features/settings/screens/settings_screen.dart` oluşturuldu:
  - **Görünüm:** Koyu Gece (Dark), Gündüz (Light) ve Sistem Teması segment seçici.
  - **Dil Seçimi:** Sistem Varsayılanı, Türkçe, English dinamik geçiş.
  - **Bulut ve Yedekleme:** Uçtan uca şifreli Supabase bulut senkronizasyonu anahtarı.
  - **Veri Yönetimi:**
    - RFC 4180 uyumlu CSV dışa aktarma (`ExportService`).
    - Geliştirici ve yedekleme dostu girintili JSON dışa aktarma (`ExportService`).
    - Kütüphaneyi sıfırlama (onay diyaloglu, yerel Drift tablolarını temizleme).
  - **Hakkında & Gizlilik:**
    - Blueprint §5 gizlilik ilkelerini ("Fotoğraflar yalnızca cihazda saklanır, sunucuya yalnızca OCR metni gider") içeren Gizlilik Sözleşmesi diyalogu.
    - Sürüm ve tasarım sistemi bilgisi (`v1.0.0`, `Nocturnal Archivist`).
- `Routes.settings` rotası `app_router.dart` içine eklendi ve `HomeScreen` app bar'ına ayarlar aksiyon butonu yerleştirildi.

---

## 2. Testler ve Doğrulama

- `test/features/settings/export_service_test.dart` (2 test): CSV kaçış karakterleri, başlıklar ve JSON çıktısı doğrulandı.
- `test/features/settings/settings_screen_test.dart` (7 test): Tema, dil değişimi, bulut senkron anahtarı, CSV/JSON paylaşım çağrısı, gizlilik diyalogu ve sıfırlama akışı doğrulandı.
- `test/features/share/share_card_test.dart` (3 test): Türkçe/İngilizce kart render'ı ve boş renk toleransı doğrulandı.
- `test/features/share/share_bottom_sheet_test.dart` (4 test): Kart önizleme, metin/görsel paylaşım aksiyonları ve İngilizce yerelleştirme doğrulandı.
- **Tüm Suite:** `flutter test` → 118/118 test yeşil.
- **Statik Analiz:** `flutter analyze` → 0 issue.
- **Root Suite:** `make test` ve `make analyze` → tamamı yeşil.
