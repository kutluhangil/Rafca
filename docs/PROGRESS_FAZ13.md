# Faz 13: Yıpranmış Sırtlar İçin Barkod Fallback (ISBN Scanner)

## Kapsam ve Amaç
Çok eski, sırt yazısı silinmiş, kumaş kaplı veya hasarlı ciltlerde optik karakter tanıma (OCR) sıfır veya düşük kaliteli token üretebilir. Faz 13, kullanıcının kitabın arka kapağındaki EAN-13/EAN-8 barkodunu okutarak veya doğrudan ISBN girerek kitabı sıfır hata ile kütüphanesine eklemesini sağlayan yerel öncelikli barkod tarama motorunu hayata geçirir.

---

## Gerçekleştirilen İşler

### 1. ISBN Doğrulama ve Dönüşüm Motoru (`IsbnValidator`)
- **Konum:** `app/lib/features/capture/barcode/isbn_validator.dart`
- **Yetenekler:**
  - `clean(raw)`: Boşluk ve tire karakterlerini temizleme, büyük harfe çevirme.
  - `isValidIsbn10(clean)`: Modulo 11 ağırlıklı sağlama toplamı (sayısal ve 'X' denetim hanesi desteği).
  - `isValidIsbn13(clean)`: Modulo 10 (1-3 ağırlıklı) standart EAN-13 sağlama toplamı.
  - `isbn10ToIsbn13(isbn10)`: 10 haneli ISBN'leri standart 978 önekli 13 haneli EAN formatına dönüştürme.
  - `normalizeToIsbn13(raw)`: Hem ISBN-10 hem ISBN-13 girişlerini standart 13 haneli formata getirme.
  - `format(isbn13)`: Okunabilir tireli sunum formatı (`978-605-185-001-6`).

### 2. Koşullu Barkod Tarama Motoru (`BarcodeEngine`)
- **Konumlar:**
  - `app/lib/features/capture/barcode/barcode_engine.dart` (Koşullu export)
  - `app/lib/features/capture/barcode/barcode_engine_stub.dart` (Web & headless test stub'ı)
  - `app/lib/features/capture/barcode/barcode_engine_native.dart` (`google_mlkit_barcode_scanning: ^0.13.0`)
- **Formatlar:** `BarcodeFormat.ean13`, `BarcodeFormat.ean8`.
- Görüntü dosyasını okuyup taranan tüm barkodları filtreler, `IsbnValidator` ile denetleyip geçerli ISBN-13 listesi döner.

### 3. Yerel Öncelikli ISBN Katalog Sorgulama Servisi (`BarcodeLookupService`)
- **Konum:** `app/lib/features/capture/barcode/barcode_lookup_service.dart`
- **3 Kademeli Çözümleme Stratejisi:**
  1. **Yerel Drift SQLite:** `CatalogBooks` tablosunda `isbn13.equals(cleanIsbn)` sorgulanır (sıfır ağ gecikmesi).
  2. **Open Library API Fallback:** `https://openlibrary.org/api/books?bibkeys=ISBN:{isbn}&format=json&jscmd=data`. Tek istekte kitap başlığı, yazarları, yayınevi, basım yılı ve yüksek çözünürlüklü kapak görselini alır.
  3. **Google Books API Fallback:** `https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}` ile ikincil ağ kaynağı.
  4. **Otomatik Yerel Önbelleğe Alma:** Ağdan bulunan kitaplar yerel SQLite `CatalogBooks` tablosuna kaydedilir; sonraki tüm sorgularda yerel kütüphane hızında açılır.

### 4. Kullanıcı Arayüzü Entegrasyonları
- **Manuel Arama Ekranı (`ManualSearchScreen`):**
  - Arama alanına ISBN barkod tarama butonu (`Icons.qr_code_scanner`) eklendi.
  - Arama alanına 10 veya 13 haneli geçerli ISBN yazıldığında otomatik olarak `BarcodeLookupService` tetiklenir ve sonuç anında listelenir.
- **Kamera Ekranı (`CameraScreen`):**
  - "RAF SIRTI" ve "BARKOD (ISBN)" modları arasında tek tıkla geçiş sağlayan Nocturnal Archivist mod seçici eklendi.
  - Barkod modunda kompakt kadraj rehberi (270x150) ve açıklayıcı rehber metin sunulur; deklanşör gyro kısıtlamasından muaf tutulur.
  - Barkod okunduğunda açılan `_showBarcodeBookSheet` alt sayfası ile kitap detayları ve tek tıkla "Kütüphaneye Ekle" aksiyonu sağlanır.
- **Kütüphane Deposu (`LibraryRepository.addBook`):**
  - Tekil kitap eklemeleri için `userBooks`, `catalogBooks` ve `syncQueueDao` işlemlerini yöneten transactional metot eklendi.
- **Yerelleştirme (i18n):**
  - `scanBarcode`, `barcodeMode`, `spineMode`, `isbnNotFound`, `searchingIsbn`, `invalidIsbn`, `barcodeScanHint`, `bookFoundFromBarcode`, `addToLibrary` anahtarları Türkçe ve İngilizce olarak ARB dosyalarına işlendi.

---

## Test & Doğrulama
- `app/test/features/capture/isbn_validator_test.dart`: 5/5 birim testi yeşil.
- `app/test/features/capture/barcode_lookup_service_test.dart`: 5/5 yerel ve mock ağ testi yeşil.
- `app/test/features/review/manual_search_screen_test.dart`: 3/3 widget testi yeşil.
- `app/test/features/library/library_repository_test.dart`: `addBook` dahil 12/12 test yeşil.
- Toplam test sayısı: **155 testin tamamı yeşil (%100 başarı)**.
- `flutter analyze`: **0 issue**.
- `scripts/check_performance_budgets.sh`: Tüm bütçeler doğrulandı.
