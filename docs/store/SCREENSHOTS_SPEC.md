# Mağaza Ekran Görüntüleri Spesifikasyonu (Screenshots Spec)

Nocturnal Archivist görsel kimliği doğrultusunda hem Apple App Store hem de Google Play Store için gerekli olan ekran görüntülerinin çerçeve, cihaz ve içerik planı.

---

## 1. Gerekli Ekran Boyutları

### Apple App Store
1. **6.9" / 6.7" iPhone Display:** 1320 x 2868 piksel veya 1290 x 2796 piksel (iPhone 16 Pro Max / 15 Pro Max).
2. **6.5" / 5.5" iPhone Display:** 1242 x 2688 piksel veya 1242 x 2208 piksel.
3. **13" iPad Pro Display:** 2064 x 2752 piksel (M4 / 6th Gen).

### Google Play Store
1. **Telefon:** Minimum 1080 x 2400 piksel (16:9 veya 20:9 oranı). En az 4, en fazla 8 ekran görüntüsü.
2. **7 inç Tablet:** Minimum 1200 x 1920 piksel.
3. **10 inç Tablet:** Minimum 1600 x 2560 piksel.
4. **Özellik Grafiği (Feature Graphic):** 1024 x 500 piksel PNG veya JPEG (Obsidian zemin, altın pirinç monogram ve "Fiziksel kitaplığınızı tek fotoğrafla dijitalleştirin" sloganı).

---

## 2. Ekran Akışı ve Metin Şablonları (6 Ekran)

| Ekran No | Gösterilen Arayüz | TR Başlık / Vurgu | EN Headline / Subhead | Görsel Detayı |
|---|---|---|---|---|
| **Ekran 1** | `HomeScreen` (Dolu durum) | **Tüm Kitaplığınız Parmaklarınızın Ucunda**<br>Nocturnal Archivist zarafetiyle arşivleyin | **Your Entire Library in One Place**<br>Archived with midnight elegance | Koyu arka plan, pirinç başlık, dinamik `ShelfStrip` ve kitap kartları |
| **Ekran 2** | `CameraScreen` & Tesviye | **Tek Deklanşörle Tüm Rafı Tarayın**<br>Hassas açı tesviyesi ve otomatik kadrajlama | **Scan Whole Shelves at Once**<br>Precise roll & pitch guidance | Kamera önizlemesi, yeşil su terazisi rozeti ve raf kılavuz çizgileri |
| **Ekran 3** | `CropScreen` (Quad Editor) | **Milimetrik Perspektif Düzeltme**<br>Köşeleri raf kenarlarına zahmetsizce oturtun | **Perspective Warp & Alignment**<br>Effortlessly map shelf boundaries | 4-noktalı ters homografi seçim köşeleri ve altın büyüteç kılavuzu |
| **Ekran 4** | `ScanResultsScreen` | **Anında Sırt Ayrıştırma & Eşleştirme**<br>Yüksek doğruluklu yerel katalog entegrasyonu | **Instant Spine Segmentation**<br>High-confidence catalogue matching | Ayrıştırılmış sırtlar, `Matched` yeşil rozetleri ve alternatif baskı seçimi |
| **Ekran 5** | `BookDetailScreen` | **"Proof of Capture" — Rafınızın Somut İzi**<br>Fiziksel sırt kırpımı ve renk paleti daima sizinle | **Proof of Capture From Your Shelf**<br>Original spine crop preserved locally | Orijinal sırt kırpımı, dominant renk çubukları, edebi detaylar |
| **Ekran 6** | `ShareCard` (Image 13) | **Koleksiyonunuzu Sanatsal Olarak Paylaşın**<br>Tek tıkla hikaye veya yüksek çözünürlüklü kart | **Share Your Curated Collection**<br>Export artistic archival cards | Literata tipografisi, mini raf şeridi ve zarif filigranlı kart |

---

## 3. Renk ve Tipografi Yönergeleri
- Arka Plan: `#12100E` (Obsidian derin siyah).
- Başlık Yazı Tipi: `Literata` (Serif, Bookish, Archival).
- Vurgu & Çerçeve Rengi: `#C9963F` (Spine Brass / Sıcak Pirinç).
- Alt Metin Yazı Tipi: `Inter` veya `IBM Plex Mono`.
