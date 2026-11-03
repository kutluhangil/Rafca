# Faz 14: AR Canlı Raf Lensi & Kitapçı Keşif Modu (Live AR HUD)

## Kapsam ve Amaç
Kullanıcı kitapçıdayken, sahafta veya bir kütüphanede gezinirken elindeki bir rafın içindeki kitaplardan hangilerine zaten sahip olduğunu, hangilerinin okuma listesinde olduğunu ve hangilerinin kütüphanesinde olmadığını anında görmek ister. Faz 14, canlı kamera akışını 500ms (2 FPS) hızında hafif bir işlem hattından geçirerek rafın üzerine etkileşimli bir HUD katmanı çizen Artırılmış Gerçeklik modülünü hayata geçirir.

---

## Gerçekleştirilen İşler

### 1. AR Lens Modelleri (`ArDetectedItem`, `ArBookStatus`, `ArLensState`)
- **Konum:** `app/lib/features/ar_lens/models/ar_lens_models.dart`
- **Sahiplik ve Okuma Durumu (`ArBookStatus`):**
  - `ownedRead`: Kütüphanede mevcut ve okunmuş (Orman Yeşili `#2F5D2C`).
  - `ownedUnread`: Kütüphanede mevcut fakat okunacak (Kehribar / Pirinç `#C9963F`).
  - `notOwned`: Kütüphanede yok / Keşif (Krem / Fildişi `#E8E1DD`).
- **Algılanan Öğe (`ArDetectedItem`):**
  - Kamera koordinatlarına normalize edilmiş sınırlayıcı kutu (`normalizedRect`), ham metin, eşleşen başlık, yazar, trigram benzerlik skoru.

### 2. Yüksek Hızlı Bellek İçi Trigram Eşleme Motoru (`ArMatchingEngine`)
- **Konum:** `app/lib/features/ar_lens/services/ar_matching_engine.dart`
- **Yetenekler:**
  - Kullanıcının kütüphanesindeki kitapları başlangıçta belleğe alarak `ArIndexEntry` trigram tablosunu oluşturur.
  - Kamera akışından gelen her metin parçacığı için mikrosaniye seviyesinde (<2ms) Jaccard trigram benzerlik sorgusu çalıştırır.
  - `0.48` eşik değeri ile açı ve hafif OCR harf hatalarına toleranslı eşleştirme yapar.

### 3. Akış Denetleyici ve Throttling Mekanizması (`ArLensController`)
- **Konum:** `app/lib/features/ar_lens/state/ar_lens_controller.dart`
- **Özellikler:**
  - 450ms zaman aşımı koruması ile kare atlama (drop-frame) ve backpressure yönetimi: CPU tüketimi <%15 ve pil tasarrufu sağlanır.
  - OCR bloklarını sınırlayıcı kutulara (`bbox`) gruplayarak normalize koordinatlara dönüştürür.
  - Kütüphane değişikliklerini dinleyip bellek içi indeksi her zaman taze tutar.

### 4. Canlı HUD Katmanı ve Etkileşimli Arayüz (`ArOverlayWidget` & `ArHudPainter`)
- **Konum:** `app/lib/features/ar_lens/widgets/ar_overlay_widget.dart`
- **Görsel Tasarım:**
  - Nocturnal Archivist temalı yarı saydam gölgelendirilmiş sınırlayıcı kutular ve durum rozetleri.
  - Canlı durum hapı ("TARANIYOR" / "CANLI AR LENSİ").
  - Kütüphanede olmayan kitaplara dokunulduğunda doğrudan açılan "İstek Listesine Ekle" alt sayfası (`_onTapArItem`).
  - Dokunulan kitabı tek tıkla `unread` statüsünde kütüphaneye ekler ve rozeti anında kehribar rengine (`ownedUnread`) dönüştürür.

### 5. Kamera Ekranı Entegrasyonu (`CameraScreen`)
- **Konum:** `app/lib/features/capture/screens/camera_screen.dart`
- **Mod Seçici:** "RAF SIRTI", "BARKOD (ISBN)" ve "CANLI AR" arasında akıcı geçiş.
- Canlı AR modunda kılavuz çizgileri yerine canlı HUD katmanı (`ArOverlayWidget`) render edilir.
- `app_router.dart`: `?mode=ar` ve `?mode=arLens` deep-link desteği eklendi.

### 6. Yerelleştirme (i18n)
- `arLensMode`, `arLensTitle`, `arStatusOwnedRead`, `arStatusOwnedUnread`, `arStatusNotOwned`, `arAddToWishlist`, `arBookAddedToWishlist` anahtarları Türkçe ve İngilizce olarak eklendi.

---

## Test & Doğrulama
- `app/test/features/ar_lens/ar_matching_engine_test.dart`: 5/5 birim testi yeşil.
- `app/test/features/ar_lens/ar_lens_controller_test.dart`: 4/4 akış ve throttling testi yeşil.
- `app/test/features/ar_lens/ar_overlay_widget_test.dart`: 3/3 HUD ve etkileşim testi yeşil.
- Toplam test sayısı: **167 testin tamamı yeşil (%100 başarı)**.
- `flutter analyze`: **0 issue**.
- `scripts/check_performance_budgets.sh`: Tüm bütçeler doğrulandı.
