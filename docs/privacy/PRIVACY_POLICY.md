# Rafça Gizlilik Politikası / Privacy Policy

**Son Güncelleme / Last Updated:** 3 Kasım 2026

---

## Türkçe

### 1. Temel Felsefemiz: Yerel Öncelikli ve Sıfır Gözetim
Rafça, fiziksel kitaplığınızı fotoğraflayarak dijitalleştirmenizi sağlayan bir arşiv aracıdır.
Tasarımımızın temeli kullanıcı gizliliğine ve veri egemenliğine dayanır:
- **Fotoğraflar ve Sırt Kırpımları Cihazınızda Kalır:** Çektiğiniz ham raf fotoğrafları ve ayrıştırılan kitap sırtı kırpımları yalnızca cihazınızın yerel depolama alanında (`ApplicationDocumentsDirectory/spine/captures/`) saklanır.
- **Görseller Buluta Aktarılmaz:** Kitap görselleri veya kamera akışları hiçbir şekilde uzak sunuculara veya üçüncü taraf yapay zeka sağlayıcılarına yüklenmez.
- **Yalnızca Düz Metin İşlenir:** Eşleştirme servisine yalnızca yerel OCR motoru (Google ML Kit) tarafından okunan düz metin (başlık, yazar, yayıncı parçaları) şifreli HTTPS kanalı üzerinden gönderilir.
- **İzleme ve Reklam Yok:** Rafça'da üçüncü taraf reklam ağı, davranışsal profil çıkarma, veri simsarlığı veya çapraz uygulama takibi (cross-app tracking) bulunmaz.

### 2. Toplanan ve İşlenen Veriler
- **Kamera Erişimi:** Yalnızca raf tarama işlemi sırasında anlık fotoğraf çekmek ve roll/pitch tesviye sensörüyle düz açıyı sağlamak için kullanılır. Sürekli video kaydı yapılmaz.
- **OCR Metinleri:** Kitap eşleştirmesi yapabilmek için sırt üzerinden okunan karakter dizileri Open Library / yerel katalog indeksinde sorgulanır.
- **Kütüphane Kayıtları:** Eklediğiniz kitaplar, oluşturduğunuz raflar ve okuma durumları cihazınızdaki yerel SQLite (Drift) veritabanında tutulur.
- **İsteğe Bağlı Bulut Yedekleme:** Ayarlar ekranından açıkça etkinleştirilmediği sürece hiçbir kütüphane verisi buluta iletilmez. Etkinleştirildiğinde veriler Supabase üzerinde uçtan uca kullanıcıya özel satır düzeyinde güvenlik (RLS) ile korunur.
- **Hata ve Tanılama Kayıtları:** Uygulamanın kararlılığını sağlamak amacıyla anonimleştirilmiş çökme raporları ve performans metrikleri (kişisel veya görsel veri içermeksizin) toplanabilir.

### 3. Kullanıcı Hakları ve Veri Kontrolü
- **Tam Veri Dışa Aktarma:** Kütüphanenizi dilediğiniz zaman standart CSV veya JSON formatında tek tıkla dışa aktarabilirsiniz.
- **Kalıcı Silme:** Ayarlar menüsünden "Kütüphaneyi Sıfırla" seçeneğiyle tüm yerel kayıtları ve sırt kırpımlarını kalıcı olarak silebilirsiniz.

---

## English

### 1. Core Principle: Local-First & Zero Surveillance
Rafca is an archival tool designed to digitize physical bookshelves from a single photograph.
Privacy by design is our foundation:
- **Photos Stay on Your Device:** Original bookshelf captures and segmented spine crops reside exclusively in your device's local application storage (`ApplicationDocumentsDirectory/spine/captures/`).
- **No Images in the Cloud:** Raw photographs, crops, or camera streams are never uploaded to remote servers or third-party AI clouds.
- **Plain Text Processing Only:** Only plain text recognized locally by on-device OCR (book title, author, publisher tokens) is securely transmitted via HTTPS for catalog matching.
- **No Ads, No Tracking:** Rafca contains no third-party ad networks, no behavioural profiling, and no cross-app tracking.

### 2. Data Collection and Usage
- **Camera Access:** Used strictly during active shelf scanning to capture still images with roll/pitch guidance. No persistent video stream is recorded.
- **OCR Text Tokens:** Text recognized on book spines is matched against our Open Library derived catalog index.
- **Local Library Storage:** Book records, shelf arrangements, and reading statuses are stored locally on your device in an encrypted SQLite database via Drift.
- **Optional Cloud Sync:** Disabled by default. If explicitly toggled in Settings, metadata synchronizes with encrypted cloud storage protected by PostgreSQL Row-Level Security (RLS).
- **Diagnostics:** Optional, non-identifiable crash events and performance telemetry may be collected strictly to improve application stability.

### 3. User Ownership & Data Rights
- **Export Anytime:** Download your full archival collection at any time in standardized RFC 4180 CSV or structured JSON format.
- **Instant Library Wipe:** Use the "Reset Library" option under Settings to permanently delete all local databases and cached spine crops.

---

**İletişim / Contact:** support@rafca.app — Kutluhan Gül
