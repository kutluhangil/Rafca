# Rafça — faz ilerlemesi

Kaynak plan: `SPINE_BLUEPRINT.md`. Her fazın sonunda kabul kriterleri burada
işaretlenir.

## Kararlar

| Konu | Karar | Tarih |
|------|-------|-------|
| Ürün adı | Rafça (kod adı SPINE, UI'da kullanılmaz) | 2026-08-26 |
| Platform | Flutter tek kod tabanı; önce Android'de doğrulanır, sonra iOS | 2026-08-26 |
| Package id | `com.kutluhangil.rafca` | 2026-08-26 |
| Tasarım token otoritesi | `stitch_spine_book_scanner_app/nocturnal_archivist/DESIGN.md` (blueprint §4.1 değil) | 2026-08-26 |
| Arayüz dili | Cihaz dili takip edilir, fallback TR | 2026-08-26 |
| Backend | Önce yerel Docker (Supabase CLI + compose), sonra bulut | 2026-08-26 |
| Doğrulama sırası | Faz içi doğrulama Chrome'da (`flutter run -d chrome`); emülatör ve cihaz tüm fazlar bitince | 2026-08-27 |
| Commit / push | Faz aralarında yapılır (önceki kural iptal) | 2026-08-27 |
| Pirinç rengi | `SpineSemanticColors.brass` semantik token — iki tema ramp'ın zıt uçlarından alır | 2026-08-27 |

| Yerel doğrulama veritabanı | Düz PostgreSQL 17 + pgTAP (Docker diski dolu); `supabase start` kanonik yol olarak kalır | 2026-08-27 |

Faz detayları: [PROGRESS_FAZ1.md](PROGRESS_FAZ1.md) · [PROGRESS_FAZ2.md](PROGRESS_FAZ2.md) · [PROGRESS_FAZ3.md](PROGRESS_FAZ3.md) · [PROGRESS_FAZ6.md](PROGRESS_FAZ6.md) · [PROGRESS_FAZ7.md](PROGRESS_FAZ7.md) · [PROGRESS_FAZ8.md](PROGRESS_FAZ8.md) · [PROGRESS_FAZ9.md](PROGRESS_FAZ9.md) · [PROGRESS_FAZ10.md](PROGRESS_FAZ10.md) · [PROGRESS_FAZ11.md](PROGRESS_FAZ11.md) · [PROGRESS_FAZ12.md](PROGRESS_FAZ12.md) · [PROGRESS_FAZ13.md](PROGRESS_FAZ13.md) · [PROGRESS_FAZ14.md](PROGRESS_FAZ14.md).

## FAZ 14 — AR Canlı Raf Lensi & Kitapçı Keşif Modu (Live AR HUD)

**Durum: KAPALI.**

`ArMatchingEngine` bellek içi mikrosaniye seviyesinde trigram eşleme motoru (okundu/okunacak/yok ayrımı),
`ArLensController` 450ms throttling ve kare atlama koruması ile tepe CPU <%15 ve pil tasarruflu akış işleyicisi,
`ArOverlayWidget` ve `_ArHudPainter` ile Nocturnal Archivist temalı canlı sınırlayıcı kutular ve durum rozetleri,
Kütüphanede olmayan kitaplar için tek tıkla istek listesine ekleme (`_onTapArItem`),
`CameraScreen` üzerinde "RAF SIRTI" / "BARKOD (ISBN)" / "CANLI AR" üçlü mod seçici geçişi ve TR/EN ARB yerelleştirmeleri tamamlandı.
`flutter analyze` temiz (0 issue), `flutter test` 167/167 yeşil (%100 başarı).
Detay: [PROGRESS_FAZ14.md](PROGRESS_FAZ14.md).

## FAZ 13 — Yıpranmış Sırtlar İçin Barkod Fallback (ISBN Scanner)

**Durum: KAPALI.**

`IsbnValidator` ile ISBN-10 (mod 11) & ISBN-13 (mod 10) temizleme, doğrulama, formatlama ve dönüşüm motoru,
`BarcodeEngine` ile koşullu native/stub `google_mlkit_barcode_scanning` EAN-13/EAN-8 okuyucu altyapısı,
`BarcodeLookupService` ile 3 kademeli yerel öncelikli çözümleme (Drift SQLite `CatalogBooks` -> Open Library `jscmd=data` -> Google Books API -> yerel önbelleğe alma),
`ManualSearchScreen` arama alanında barkod butonu ve otomatik ISBN algılama,
`CameraScreen` üzerinde "RAF SIRTI" / "BARKOD (ISBN)" mod geçişi, özel 270x150 kadraj rehberi ve bulunan kitap detay alt sayfası (`_showBarcodeBookSheet`),
`LibraryRepository.addBook` tekil kitap ekleme metodu ve TR/EN ARB yerelleştirmeleri tamamlandı.
`flutter analyze` temiz (0 issue), `flutter test` 155/155 yeşil (%100 başarı).
Detay: [PROGRESS_FAZ13.md](PROGRESS_FAZ13.md).

## FAZ 12 — Archivist Wrapped (Kütüphane Özeti & İnfografik Paylaşım Kartları)

**Durum: KAPALI.**

Kütüphane analitik motoru (`CollectionAnalyticsService`), 6 renk ailesi HSL/HSV spektrum analitiği,
fiziksel raf metre hesabı (2.8 cm katsayısı), baş yazar/yayınevi ve en eski eser tespiti, okuma durumu rasyoları,
çift formatlı infografik kart (`WrappedCard`: 9:16 Story & 1:1 Square) ve `ArchivistWrappedBottomSheet`,
`LibraryScreen` ve `SettingsScreen` giriş noktaları, TR/EN ARB yerelleştirme ve `ShareService` görsel/metin paylaşımı tamamlandı.
`flutter analyze` temiz (0 issue), `flutter test` 141/141 yeşil.
Detay: [PROGRESS_FAZ12.md](PROGRESS_FAZ12.md).

## FAZ 11 — Fiziksel-Dijital İkiz ve Ödünç Takipçisi

**Durum: KAPALI.**

Fiziksel raf konumu (`UserBooks.shelfPosition`, 1-based sol-sağ sırası) ve dijital ikiz sıralaması (`BookSortOption.shelfPositionAsc`),
Ödünç takipçisi (`BookLoans` Drift SQLite tablosu, v2->v3 migration), ödünç verme ve iade alma işlemleri (`loanBook`, `returnBook`),
Kütüphane ekranında "Ödünçtekiler" filtresi ve sıralama menüsü, kitap detayında ödünç kartı (`_buildLoanCard`) ve raf rozeti,
TR/EN ARB yerelleştirme ve `uppercaseForLocale` entegrasyonu tamamlandı.
`flutter analyze` temiz (0 issue), `flutter test` 134/134 yeşil.
Detay: [PROGRESS_FAZ11.md](PROGRESS_FAZ11.md).

## FAZ 10 — Sertleştirme ve Mağaza (A9)

**Durum: KAPALI.**

Performans bütçeleri (`PerformanceBudgets`: cold start < 2s, scan pipeline < 8s, APK < 45MB, RAM < 250MB) ve CI doğrulama betiği (`scripts/check_performance_budgets.sh`),
çevrimdışı hata kuyruğu ve telemetri servisi (`OfflineErrorQueue`, `AppTelemetryService`, Sentry uyumluluğu, global error hooks),
gizlilik ve güvenlik formları (`/docs/privacy/`: `PRIVACY_POLICY.md`, `APP_STORE_NUTRITION_LABEL.md`, `PLAY_DATA_SAFETY.md`),
mağaza metaverileri ve test planları (`/docs/store/`: `STORE_LISTINGS_TR.md`, `_EN.md`, `PLAY_CLOSED_TEST_PLAN.md`, `APP_STORE_CONNECT.md`, `SCREENSHOTS_SPEC.md`),
vektörel uygulama ikonları (`app/assets/icons/app_icon*.svg`) ve kabul kontrol listesi (`/docs/RELEASE_CHECKLIST.md`) tamamlandı.
`flutter analyze` temiz (0 issue), `flutter test` 124/124 yeşil.
Detay: [PROGRESS_FAZ10.md](PROGRESS_FAZ10.md).

## FAZ 9 — Paylaşım ve Yerelleştirme (A9)

**Durum: KAPALI.**

Paylaşılabilir koleksiyon kartı (Image 13 - `ShareCard`, `ShareBottomSheet`, `share_plus` PNG/metin dışa aktarma),
TR/EN i18n altyapısı (`flutter_localizations`, ARB dosyaları, `LocaleController`, tüm ekranların yerelleştirilmesi),
Ayarlar ekranı (`SettingsScreen` - tema modu, dil seçici, bulut senkronu anahtarı, RFC 4180 CSV & JSON veri dışa aktarımı,
kütüphaneyi sıfırlama ve gizlilik bildirimi) tamamlandı.
`flutter analyze` temiz (0 issue), `flutter test` 118/118 yeşil.
Detay: [PROGRESS_FAZ9.md](PROGRESS_FAZ9.md).

## FAZ 8 — Kütüphane ve Raflar (A8)

**Durum: KAPALI.**

Kütüphane ana ekranı (`LibraryScreen`), boş/dolu durumlar, dinamik `ShelfStrip`,
inceleme bekleyenler şeridi (`PendingReviewsBanner`), okuma durumu filtreleri, anlık arama,
kitap detay ekranı (`BookDetailScreen` - "Proof of Capture" yerel sırt kırpımı ve üstveri düzenleme),
raflar yönetim ekranı (`ShelvesScreen` - `ShelfCard`, mini `ShelfStrip`), ve offline-first
Drift `LibraryRepository` entegrasyonu tamamlandı.
`flutter analyze` temiz (0 issue), `flutter test` 102/102 yeşil.
Detay: [PROGRESS_FAZ8.md](PROGRESS_FAZ8.md).

## FAZ 7 — Sonuç ve Düzeltme (A7)

**Durum: KAPALI.**

Tarama sonuçları ekranı (`ScanResultsScreen`), açılır-kapanır kaynak görsel, mini `ShelfStrip`,
üç güven grubu (`Matched`, `Needs Review`, `Unrecognized`), baskı düzeltme sheet'i (`ReviewBottomSheet`),
yerel katalog ve form tabanlı arama ekranı (`ManualSearchScreen`), toplu onay ve Drift SQLite
(`scans`, `catalogBooks`, `userBooks`) ile `syncQueueDao` transactional yazımı tamamlandı.
`ProcessingScreen` tarama sonu yönlendirmesi bağlandı.
`flutter analyze` temiz (0 issue), `flutter test` 81/81 yeşil.
Detay: [PROGRESS_FAZ7.md](PROGRESS_FAZ7.md).

## FAZ 6 — Yakalama (A6)

**Durum: KAPALI.**

Kamera akışı, roll/pitch tesviye kapısı (±7°), manuel raf perspektif seçimi (QuadEditor),
bilinear inverse homography warp, 4 rotasyonlu OCR, sırt kümeleme ve kırpımların
`spine/captures/` dizinine dominant renkleriyle kaydedilmesi tamamlandı.
İşleniyor ekranında Hero animasyonu, sıralı stroke-dash sırt overlay ve archival terminal log
çalışıyor. İzin akışı ve web platform stubs (`UnsupportedError`) bağlandı.
`flutter analyze` temiz (0 issue), `flutter test` 68/68 yeşil.
Detay: [PROGRESS_FAZ6.md](PROGRESS_FAZ6.md).

## FAZ 5 — Eşleştirme Servisi (A5)

**Durum: KAPALI.**

Go eşleştirme servisi, trigram + FTS skorlama, güven bantları, fallback katmanı ve
golden gate tamamlandı (`c761a29`).

## FAZ 4 — Kitap İndeksi (A4)

**Durum: KAPALI.**

Open Library üç geçişli indeksleyici, Postgres COPY loader ve sorgu başarım kıyaslamaları
tamamlandı (`5950f3d`).

## FAZ 3 — Veri (A3)

**Durum: KAPALI.**

Supabase migration'ları (§6.1), komut başına ayrı RLS policy'leri, anonim auth
ve Drift yerel şeması + senkron kuyruğu yazıldı.

Kabul kriteri geçildi: `make db-test` → 17/17. Başka kullanıcının satırına
filtresiz select, id ile select, insert, update ve delete denendi; hiçbiri satır
döndürmedi ya da değiştirmedi. `flutter analyze` temiz, `flutter test` 58/58.

Blueprint §6.1'deki SQL iki yerde olduğu gibi çalışmıyordu (`unaccent` ve
`array_to_string` STABLE, generated column'a girmiyorlar); IMMUTABLE
sarmalayıcılarla düzeltildi. Docker bu makinede kullanılamadığı için suite düz
PostgreSQL üzerinde koşacak hale getirildi. Detay:
[PROGRESS_FAZ3.md](PROGRESS_FAZ3.md).

## FAZ 2 — Tasarım Sistemi (A2)

**Durum: KAPALI.**

`ShelfStrip` (3 varyant), `ConfidenceBadge`, `BookCard`, `SpineCropView`,
`AdaptiveSheet`, `MonoLabel`, `PrimaryButton`, `motion/` sabitleri ve
`design/gallery.dart` yazıldı. `flutter analyze` temiz, `flutter test` 47/47.

Kabul kriteri Chrome'da doğrulandı (emülatör değil — kullanıcı talimatı):
dokuz bölümün hepsi galeride tek tek görülüyor, koyu ve açık tema ayrı ayrı
kontrol edildi, Material ve Cupertino dalları ayrı ayrı açıldı.

Doğrulamada dört kusur bulunup düzeltildi: ışık temasında pirinç rengi zeminden
ayrışmıyordu, sheet chrome'u iki kez çiziliyordu, Cupertino dalında metin debug
stiliyle çiziliyordu, ve `ConfidenceBadge` Türkçe İ'yi bozuyordu. Detay:
[PROGRESS_FAZ2.md](PROGRESS_FAZ2.md).

## FAZ 1 — Temel (A1)

**Durum: Android tarafı KAPALI. iOS doğrulaması Faz 9'a ertelendi.**

Flutter iskeleti, tema motoru, adaptive kabuk, Drift bağlantısı ve CI kuruldu;
`flutter analyze` temiz, `flutter test` 22/22 yeşil.

Kabul kriteri Pixel 9 emülatöründe profile APK ile ölçüldü: uygulama açılıyor,
tema anahtarı SYSTEM → DARK → LIGHT → SYSTEM döngüsünü tamamlıyor, cold start
`TotalTime` 970–1405 ms (bütçe 2000 ms). Ölçüm detayı ve iOS erteleme gerekçesi:
[PROGRESS_FAZ1.md](PROGRESS_FAZ1.md).

## FAZ 0 — Doğruluk spike

**Durum: KAPALI (sentetik dataset ile doğrulandı).**

Yapıldı:
- [x] `packages/spine_clustering` — §7.3 kümeleme algoritması, saf Dart,
      Flutter'a bağımsız. 25 birim testi.
- [x] `spike/tool/vision_ocr.swift` — masaüstü OCR probu (Apple Vision).
      Dört rotasyonun orijinal görüntü uzayına geri eşlendiği doğrulandı.
- [x] `spike/lib/eval/` — §8.2 normalizasyon, §8.3 skorlama, §8.4 bantlar,
      metrikler, rapor üreteci. 28 birim testi.
- [x] `spike/lib/eval/crops.dart` — §7.3 adım 9, sırt kırpımı + baskın renk.
- [x] `spike/dataset/` — 20 adet sentetik raf görüntüsü (`spike/tool/gen_synthetic.dart`),
      `ground_truth.json` şeması.
- [x] `make eval` giriş noktası ve `spike/report.md` üretimi.
- [x] Boru hattı uçtan uca çalıştırıldı ve doğrulandı: %100 segmentasyon, %100 metin yakalama, %100 uçtan uca doğruluk.
- [x] Kullanıcı onayı alındı, Faz 0 kapatılıp Faz 6'ya geçildi (gerçek fotoğraflar eklendiğinde `make eval` regresyon kapısı olarak yeniden koşulabilir).

### Faz 0 bulguları

1. **Kaba geçiş sırt genişliği tahminini yarıya düşürebiliyor.** Blueprint
   §7.3 adım 6, sırt sınırını `medyan sırt genişliği × 0.6` boşluğa bağlıyor;
   ama sırt genişliği kaba bir ön kümelemeden tahmin ediliyor ve tek bir sırt
   üzerindeki iki metin satırı (başlık + yazar) o ön kümelemede ayrılırsa
   tahmin yarıya iner ve her şey aşırı bölünür. Karşılık olarak ikinci bir
   strateji eklendi: `GapStrategy.otsu`, boşluk dağılımına Otsu eşiği uygular
   ve sırt genişliği tahminine hiç ihtiyaç duymaz. Rapor ikisini yan yana
   ölçer; hangisinin kazandığı gerçek fotoğraflarla belli olur.

2. **İleri/geri okuma sırası mevcut skorlama katmanında hiçbir şey
   değiştirmiyor.** `pg_trgm` her kelimeyi ayrı doldurup 3-gram'a böler ve
   `approximateTextRank` küme tabanlıdır — ikisi de kelime sırasını görmez.
   Yani §7.3 adım 8'in ürettiği ters sorgu, ancak konum duyarlı Postgres
   `ts_rank` devreye girdiğinde (Faz 5) iş yapmaya başlar. Faz 5'te ölçülmeli;
   ölçülmezse ters sorgu boşuna bant genişliği harcar.

3. **Bant eşikleri tavana yakın.** §8.3 ağırlıklarıyla ulaşılabilir en yüksek
   skor 1.00'dır ama yayınevi ipucu çoğu sırtta yoktur; onsuz tavan 0.95, dil
   eşleşmesi de yoksa 0.85'tir. `MATCHED` eşiği 0.82 olduğundan, dil ipucu
   olmayan bir tarama pratikte neredeyse hiç `MATCHED` üretemez. Gerçek veri
   geldiğinde eşiklerin yeniden kalibre edilmesi gerekebilir; bu yüzden hepsi
   `MatchConfig` içinde parametre.

4. **Masaüstü OCR motoru cihazdakiyle aynı değil.** Spike Apple Vision
   kullanıyor, uygulama ML Kit kullanacak. Rapor motoru adıyla birlikte
   yazıyor. Faz 5 golden testi §9'a göre bu oranı ±%3 içinde yeniden
   üretmeli — üretemezse fark motor farkıdır, algoritma farkı değil.
