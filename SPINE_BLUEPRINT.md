# SPINE — Master Build Blueprint

> **Ürün:** Bir raf fotoğrafından kitap sırtlarını tanıyıp fiziksel kütüphaneyi dijitalleştiren mobil uygulama.
> **Platform:** iOS + Android, tek Flutter kod tabanı.
> **Bu dosya:** Claude Code'un VS Code üzerinden faz faz uygulayacağı yürütme planıdır. Fazlar sırayla yapılır, her fazın kabul kriteri geçilmeden sonrakine geçilmez.
> **Sürüm:** v1.0 — 26 Ağustos 2026

---

## 0. AJAN YAPISI VE DOSYA SAHİPLİĞİ

Her faz tek bir ajan rolü tarafından yürütülür. Bir ajan yalnızca kendi sahip olduğu dosyaları değiştirir; başka bir ajanın dosyasına dokunması gerekiyorsa fazı durdurur ve rapor eder.

| # | Ajan | Sorumluluk | Sahip olduğu yollar |
|---|------|-----------|--------------------|
| A0 | **Spike** | Doğruluk ölçümü, atılacak kod | `/spike/**` |
| A1 | **Foundation** | Repo, Flutter iskeleti, CI, tema motoru | `/app/lib/core/**`, `/app/pubspec.yaml`, `/.github/**` |
| A2 | **Design System** | Token, bileşen, animasyon kütüphanesi | `/app/lib/design/**` |
| A3 | **Data** | Supabase şema, RLS, migration | `/supabase/**` |
| A4 | **Index** | Open Library ingest, arama indeksi | `/services/index/**` |
| A5 | **Match** | Go eşleştirme servisi | `/services/match/**` |
| A6 | **Capture** | Kamera, OCR, kümeleme, kırpma | `/app/lib/features/capture/**` |
| A7 | **Review** | Sonuç, doğrulama, düzeltme akışı | `/app/lib/features/review/**` |
| A8 | **Library** | Kütüphane, raflar, detay, arama | `/app/lib/features/library/**` |
| A9 | **Release** | Performans, mağaza, gizlilik, i18n | `/app/android/**`, `/app/ios/**`, `/docs/**` |

---

## 1. ÜRÜN TANIMI

### 1.1 Tek cümlelik değer önerisi
Rafının fotoğrafını çek; kitapların 10 saniye içinde dijital koleksiyonuna eklensin — barkod okutmadan, tek tek yazmadan.

### 1.2 v1 kapsamı (yapılacak)
- Raf fotoğrafından çoklu kitap tanıma
- Üç durumlu güven sistemi: MATCHED / REVIEW / UNKNOWN
- Düşük güvenli sonuçlar için düzeltme akışı (asıl ürün burası)
- Kütüphane, raflar, kitap detayı, manuel arama
- Paylaşılabilir "Shelf Strip" kartı
- TR/EN arayüz dili
- Anonim yerel kullanım + isteğe bağlı hesap ile bulut senkronu

### 1.3 v1 kapsam dışı (yapılmayacak — Claude Code bunları eklemeyecek)
- Sosyal akış, takip, yorum, puanlama
- Okuma istatistikleri / yıllık hedef
- Plak, VHS, board game koleksiyonları (mimari izin verecek, UI verilmeyecek)
- Çoklu cihaz gerçek zamanlı senkron
- Kitap satın alma / affiliate

---

## 2. FAZ 0 — DOĞRULUK SPIKE (GO / NO-GO KAPISI)

**Bu faz geçilmeden hiçbir üretim kodu yazılmaz. Bu fazın kodu sonunda silinir.**

### 2.1 Yapılacak
1. `/spike/dataset/` altına **20 gerçek raf fotoğrafı** konur. Çeşitlilik zorunlu:
   - 6 adet: iyi ışık, düz açı, kalın sırtlar
   - 6 adet: sarı ev ışığı, hafif açı (10–25°)
   - 4 adet: ince sırtlar / cep kitapları
   - 4 adet: Türkçe kitaplar ağırlıklı raf
2. Her fotoğraf için `ground_truth.json`: raftaki her kitabın gerçek başlık + yazar bilgisi, soldan sağa sırayla.
3. `/spike/` altında bir Dart veya Python betiği:
   - Görüntüyü 0°, 90°, 180°, 270° döndürerek OCR çalıştırır (Android'de ML Kit, masaüstü spike'ta Tesseract veya Google Cloud Vision kabul edilir — amaç oran ölçmek)
   - Metin bloklarını konum + açıya göre kümeler (bkz. §7.3 algoritma)
   - Her küme için ham metin üretir
4. `/spike/report.md` üretilir. Zorunlu metrikler:
   - **Segmentasyon recall:** gerçek kitap sayısının yüzde kaçı için bir küme oluştu
   - **Metin yakalama oranı:** kümelerin yüzde kaçında başlığın en az 2 anlamlı kelimesi okundu
   - **Uçtan uca doğru eşleşme:** (§8'deki eşleştirme kabaca uygulanıp) doğru kitaba bağlanan oran
   - Fotoğraf grubuna göre kırılım (ışık, açı, dil)

### 2.2 Kapı kararı

| Sonuç | Karar |
|-------|-------|
| Uçtan uca doğruluk ≥ %70 | Devam. Plan aynen uygulanır. |
| %50 – %70 | Devam, ama düzeltme akışı (Faz 7) ürünün merkezi kabul edilir, pazarlama dili "asistan" olur, "otomatik" olmaz. |
| %35 – %50 | VLM katmanı v1'e alınır, cihaz-içi OCR yalnızca ön eleme olur. Maliyet modeli ve ücretli plan Faz 1'den önce tanımlanır. |
| < %35 | **DUR.** Ürün bu haliyle yapılmaz. Kullanıcıya rapor edilir. |

> ⚠️ Claude Code bu kapıyı kendi başına geçemez. Rapor üretilir, karar kullanıcıya sorulur.

---

## 3. TEKNİK MİMARİ

```
┌──────────────────────────────────────────────┐
│  FLUTTER APP (iOS + Android, tek kod tabanı) │
│  • camera + sensors (tesviye kontrolü)       │
│  • google_mlkit_text_recognition (cihaz-içi) │
│  • spine clustering (saf Dart)               │
│  • drift/sqlite (yerel-önce depolama)        │
│  • supabase_flutter (opsiyonel senkron)      │
└───────────────┬──────────────────────────────┘
                │ HTTPS (batch match request)
                ▼
┌──────────────────────────────────────────────┐
│  GO MATCH SERVICE (Docker)                   │
│  • /v1/match      → trigram + FTS eşleştirme │
│  • /v1/enhance    → VLM fallback (kredili)   │
│  • /v1/health                                │
│  Ubuntu ev sunucusu + Cloudflare Tunnel      │
└───────────────┬──────────────────────────────┘
                ▼
┌──────────────────────────────────────────────┐
│  SUPABASE (Postgres + Auth + Storage)        │
│  • books_index  (Open Library alt kümesi)    │
│  • pg_trgm + unaccent + tsvector             │
│  • kullanıcı verisi + RLS                    │
└──────────────────────────────────────────────┘
```

### 3.1 Stack kararları (sabit, tartışmaya kapalı)

| Katman | Karar | Gerekçe |
|--------|-------|---------|
| Mobil | Flutter 3.3x stable, Dart 3 | Tek kod tabanı, iOS+Android |
| State | Riverpod 2 (code-gen'li) | Test edilebilirlik |
| Routing | go_router | Deep link + platform geçişleri |
| Yerel DB | Drift (SQLite) | Yerel-önce; internet olmadan kütüphane açılır |
| OCR | google_mlkit_text_recognition | Cihaz-içi, ücretsiz, döndürülmüş blok döndürür |
| Kamera | camera + sensors_plus | Odak kilidi + tesviye göstergesi |
| Backend | Go 1.2x, `net/http` + `pgx` | Eşleştirme CPU işi, tek binary, düşük RAM |
| DB/Auth/Storage | Supabase | Postgres eklentileri (pg_trgm) hazır, RLS |
| Dağıtım | Docker Compose + Cloudflare Tunnel | Mevcut ev sunucusu; v1'de bulut faturası yok |
| Ödeme (v1.1) | RevenueCat + App Store / Play IAP | Mağaza içi tüketim kredisi zorunlu |

### 3.2 Neden Go tek başına backend değil
Eşleştirmenin zor kısmı bulanık metin araması. Postgres `pg_trgm` + `tsvector` bunu hazır ve hızlı veriyor. Go yalnızca bu sorguyu saran, normalizasyon + skorlama + VLM orkestrasyonu yapan ince bir katman. Go'da sıfırdan arama motoru yazılmayacak.

---

## 4. TASARIM SİSTEMİ (Stitch çıktısından sabitlenmiş)

### 4.1 Renk tokenları

```dart
// app/lib/design/tokens/colors.dart
class SpineColors {
  // Nocturnal Archivist — dark tema birincil
  static const bgDeep        = Color(0xFF12100E);
  static const surface       = Color(0xFF1C1916);
  static const surfaceRaised = Color(0xFF262119);
  static const border        = Color(0xFF3A332A);
  static const textPrimary   = Color(0xFFF4EFE6);
  static const textSecondary = Color(0xFFA79C8C);

  static const brass         = Color(0xFFC9963F); // primary
  static const matched       = Color(0xFF6E8F6A); // secondary
  static const review        = Color(0xFFC97A3F); // tertiary
  static const unknown       = Color(0xFFA9503F); // danger

  // Light tema
  static const lightBg       = Color(0xFFF5F0E8);
  static const lightSurface  = Color(0xFFFFFFFF);
}
```

### 4.2 Tipografi

| Rol | Font | Kullanım |
|-----|------|----------|
| Headline | **Literata** (serif) | Ekran başlıkları, kitap adı, karşılama |
| Body | **Inter** | Tüm arayüz metni |
| Label / Data | **IBM Plex Mono** | Güven değeri, ISBN, durum rozeti, işlem logu — UPPERCASE, letterSpacing 0.08em, 11–12px |

`google_fonts` paketi kullanılmayacak — üç font `assets/fonts/` altına gömülecek (çevrimdışı ve mağaza boyutu kontrolü için).

### 4.3 Şekil ve boşluk
- Radius: kart 14, sheet 24, buton 12, chip stadium
- Spacing skalası: 4 / 8 / 12 / 16 / 24 / 32 / 48
- Gölge yok. Derinlik = hairline border (`border`, 1px) + %4 iç parlaklık.

### 4.4 İmza bileşeni — `ShelfStrip`
Her biri bir kitabı temsil eden dikey renkli çubuklardan oluşan yatay şerit. Renk, o kitabın sırt kırpımından baskın renk çıkarılarak elde edilir (`palette_generator`).
- Kompakt varyant: 40px yükseklik, header'da
- Hero varyant: 96px, kütüphane üstünde tam genişlik
- Boş varyant: yalnızca outline çubuklar (Image 3'teki boş durum)
- **En az 4 ekranda görünür.** Ürünün görsel kimliği budur.

### 4.5 Güven rozeti — `ConfidenceBadge`
Her kitap kartında: 3px sol kenar çubuğu + mono etiket.
`MATCHED` (yeşil) · `REVIEW` (turuncu) · `UNKNOWN` (kırmızı)
Belirsiz sonuçlar asla ikincil bir ekrana saklanmaz.

### 4.6 Platform uyarlama kuralları (iOS tasarımı ayrıca üretilmedi — kural tabanlı türetilecek)

| Öğe | Android | iOS |
|-----|---------|-----|
| Alt gezinme | Material NavigationBar + ortada yükseltilmiş kamera FAB | CupertinoTabBar, kamera sekmesi dolu daire glif |
| Başlık | Large collapsing app bar | Large title, scroll'da inline'a çöker |
| Sheet | Material bottom sheet, drag handle | Detentli sheet (medium/large), grabber |
| Liste silme | Uzun bas → menü | Swipe-to-delete |
| Geri | Sistem geri + AppBar ok | Chevron + önceki ekran adı, kenar swipe |
| Geri bildirim | Snackbar | Üstten inline toast |
| İkon | Material Symbols Rounded 300 | SF Symbols benzeri ince set |
| Haptik | `HapticFeedback.selectionClick` | `HapticFeedback.lightImpact` |

Uygulama: `app/lib/design/adaptive/` altında `AdaptiveScaffold`, `AdaptiveSheet`, `AdaptiveListRow`. Özellik kodu asla `Platform.isIOS` kontrolü yapmaz; yalnızca adaptive bileşeni çağırır.

### 4.7 Hareket spesifikasyonu

| Etkileşim | Animasyon | Süre / eğri |
|-----------|-----------|-------------|
| ShelfStrip girişi | Her çubuk 12ms arayla alttan `scaleY 0→1` | 260ms, easeOutCubic |
| Segmentasyon | Her sırt dikdörtgeni sırayla stroke-dash ile çizilir, sonra %8 brass dolgu | 120ms/sırt |
| İşlem yüzdesi | Mono metin karakter karakter yazılır, ilerleme çubuğu lineer | — |
| Kamera → İşleniyor | Çekilen kare Hero ile büyüyerek taşınır | 320ms, easeInOutCubic |
| Sonuç listesi | Stagger 30ms, fadeIn + translateY 12px | 220ms |
| MATCHED geçişi | Tek seferlik yeşil pulse | 400ms |
| REVIEW rozeti | **Animasyon yok** — statik kalır, dikkat çekmesi için | — |

Kurallar: hiçbir animasyon 400ms'i geçmez. `MediaQuery.disableAnimations` (reduce motion) açıkken hepsi 120ms crossfade'e düşer. Animasyonlar `app/lib/design/motion/` altında merkezî sabitlerden okunur.

---

## 5. GİZLİLİK MİMARİSİ (mockup çelişkisinin çözümü)

**Sabit kural:** Ham raf fotoğrafı ve sırt kırpımları **varsayılan olarak yalnızca cihazda** tutulur (`ApplicationDocumentsDirectory/spine/captures/`). Buluta hiçbir görsel gitmez.

Sunucuya giden tek şey: OCR sonucu **düz metin** ve isteğe bağlı olarak kullanıcının açıkça onayladığı tek bir sırt kırpımı (yalnızca "Enhance" butonuna basıldığında, yalnızca o kırpım).

Onboarding metni buna göre düzeltilecek:

> ~~"We do not record video or store images beyond the scanning process."~~
> **"Photos stay on your device. Only the text we read is sent for matching — and only if you ask us to."**
> TR: **"Fotoğraflar cihazında kalır. Eşleştirme için yalnızca okunan metin gönderilir."**

"PROOF OF CAPTURE" görseli yerel dosyadan okunur; bulut senkronu kapalıysa yüklenmez. Bulut senkronu açılırsa kullanıcıya ayrıca sorulur.

Store gizlilik beyanları (`/docs/privacy/`): App Store Nutrition Label ve Play Data Safety formu bu mimariye birebir uyacak şekilde Faz 10'da doldurulur.

---

## 6. VERİ MODELİ

### 6.1 Supabase şeması

```sql
-- KATALOG (herkese açık okuma, yazma yok)
create table books_index (
  id            bigserial primary key,
  ol_key        text unique,               -- Open Library work/edition key
  isbn13        text,
  title         text not null,
  subtitle      text,
  authors       text[] not null default '{}',
  publisher     text,
  publish_year  int,
  language      text,                       -- 'tur', 'eng', ...
  cover_url     text,
  search_blob   text generated always as (
                  lower(unaccent(coalesce(title,'') || ' ' ||
                  coalesce(array_to_string(authors,' '),'')))
                ) stored,
  search_tsv    tsvector generated always as (
                  to_tsvector('simple', coalesce(title,'') || ' ' ||
                  coalesce(array_to_string(authors,' '),''))
                ) stored
);
create index books_trgm on books_index using gin (search_blob gin_trgm_ops);
create index books_fts  on books_index using gin (search_tsv);
create index books_isbn on books_index (isbn13);

-- KULLANICI VERİSİ (RLS: auth.uid() = user_id)
create table profiles   (id uuid primary key references auth.users, display_name text, created_at timestamptz default now());
create table shelves    (id uuid primary key default gen_random_uuid(), user_id uuid not null, name text not null, sort_order int default 0, created_at timestamptz default now());
create table user_books (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null,
  book_id      bigint references books_index(id),   -- null olabilir: manuel giriş
  manual_title text, manual_author text,            -- katalogda yoksa
  shelf_id     uuid references shelves(id) on delete set null,
  status       text check (status in ('unread','reading','read')) default 'unread',
  confidence   text check (confidence in ('matched','review','unknown')) not null,
  spine_color  text,                                -- #RRGGBB, ShelfStrip için
  added_at     timestamptz default now(),
  unique (user_id, book_id)
);
create table scans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  detected_count int, matched_count int,
  created_at timestamptz default now()
);
```

**RLS:** `books_index` → `select` herkese açık. Diğer tüm tablolar → `using (auth.uid() = user_id)`, dört komut için de ayrı policy. Anonim kullanıcı için Supabase anonymous auth kullanılır; hesap açınca yerel veri yükselir.

### 6.2 Yerel şema (Drift)
Supabase tablolarının aynası + `pending_sync` bayrağı + `capture_path`. **Uygulama internet olmadan tam çalışır**; senkron kuyruklanır.

---

## 7. TARAMA HATTI (uygulamanın kalbi)

### 7.1 Yakalama
- `ResolutionPreset.max`, minimum 3000px genişlik; altındaysa uyarı.
- Deklanşör öncesi zorunlu kontroller: odak kilidi + `sensors_plus` ile roll/pitch **±7°** içinde. Dışındaysa "Hold parallel to the shelf" chip'i kırmızıya döner ve deklanşör pasifleşir.
- Titreşim kontrolü: son 300ms ivme varyansı eşiğin üstündeyse çekim ertelenir.
- Flaş varsayılan kapalı (cam/parlak sırtlarda yansıma yapar), manuel açılabilir.

### 7.2 Ön işleme (saf Dart, `image` paketi)
1. Kullanıcı 4 köşeyi sürükleyerek raf alanını seçer (v1'de manuel quad — otomatik raf kenarı tespiti v2).
2. Perspektif düzeltme (homography warp).
3. Griye çevirme + CLAHE benzeri lokal kontrast artırma.
4. Uzun kenar 4000px'e sabitlenir.

### 7.3 OCR + kümeleme algoritması (kritik — Faz 0'da doğrulanan)

```
1. Görüntüyü 0°, 90°, 180°, 270° döndürerek 4 kez OCR çalıştır.
2. Tüm TextElement'leri topla: {text, cornerPoints, angle, sourceRotation}.
3. Gürültü at: 2 karakterden kısa, alfanümerik olmayan, yükseklik < medyan/4.
4. Baskın sırt yönünü bul: element açılarının medyanı (raf yatay ise ≈ ±90°).
5. Her elementin merkezini sırt yönüne DİK eksene projekte et → 1B dizi.
6. 1B kümeleme: diziyi sırala, ardışık farkları hesapla, boşluk > (medyan sırt
   genişliği × 0.6) olan yerlerden böl. Her parça = bir sırt adayı.
7. Aday çok genişse (medyanın 2.5 katı) ikiye böl — bitişik iki ince sırt.
8. Her aday için: içindeki elementleri okuma sırasına diz → ham sorgu metni.
   Hem düz hem ters okuma sırası üretilir (sırt yazısı yukarıdan da aşağıdan da yazılabilir).
9. Adayın piksel kutusunu kırp → yerel dosyaya yaz → baskın rengi çıkar.
```

Çıktı: `List<SpineCandidate { rawTextForward, rawTextReverse, bbox, cropPath, dominantColor }>`

**Bu algoritma `app/lib/features/capture/clustering/` altında saf Dart, Flutter'a bağımsız yazılacak ve birim testleri Faz 0 veri setiyle çalışacak.**

### 7.4 Eşleştirme isteği
Tüm adaylar **tek batch** halinde `POST /v1/match` gönderilir (N ayrı istek değil).

```json
{ "candidates": [
  { "id": "c1", "queries": ["1984 george orwell", "orwell george 1984"], "lang_hint": "tr" }
]}
```

---

## 8. GO EŞLEŞTİRME SERVİSİ

### 8.1 Uç noktalar
| Metot | Yol | Açıklama |
|-------|-----|----------|
| POST | `/v1/match` | Batch aday → top-3 kitap + skor |
| POST | `/v1/enhance` | Tek sırt kırpımı → VLM ile başlık çıkarımı (kredi harcar) |
| GET | `/v1/health` | Sürüm + DB ping |

### 8.2 Normalizasyon (skorlamadan önce)
Küçült → unaccent → Türkçe I/İ özel durumu → yaygın gürültü kelimelerini at (`yayınları, yayinlari, kitap, roman, cilt, vol, edition, press, books, classics`) → yayınevi adlarını ayrı bir sinyal olarak sakla, sorgudan çıkar → çift boşluk temizle.

### 8.3 Skorlama
```
score = 0.55 * trigram_similarity(search_blob, query)
      + 0.30 * ts_rank(search_tsv, plainto_tsquery(query))
      + 0.10 * dil_eşleşmesi (cihaz dili == kitap dili)
      + 0.05 * yayınevi ipucu eşleşmesi
```
Forward ve reverse sorgunun yüksek olanı alınır.

### 8.4 Güven bantları
| Skor | Durum |
|------|-------|
| ≥ 0.82 ve ikinci adayla fark ≥ 0.12 | `MATCHED` |
| 0.45 – 0.82, veya ilk iki aday birbirine çok yakın | `REVIEW` |
| < 0.45 | `UNKNOWN` |

> İkinci adayla farkın küçük olması otomatik `REVIEW` yapar — "Dune 1965" ile "Dune 50th Anniversary" ayrımı (Image 10) tam olarak budur.

### 8.5 Üç katmanlı fallback
1. **Yerel indeks** (Open Library alt kümesi) — varsayılan, ücretsiz, hızlı.
2. **Google Books API** — yerel indeks `UNKNOWN` dönerse ve dil ipucu `tur` ise. Sonuç `books_index`'e yazılır (indeks kendi kendini besler).
3. **VLM `/v1/enhance`** — yalnızca kullanıcı UNKNOWN kartındaki butona basarsa. Sırt kırpımı gönderilir, model yalnızca `{"title": "...", "author": "..."}` döndürür, sonuç 1. katmana geri sokulur. API anahtarı yalnızca sunucuda. Kredi düşülür.

### 8.6 Dağıtım
`services/match/Dockerfile` (multi-stage, distroless), `docker-compose.yml`, Cloudflare Tunnel ile `match.<domain>` altında yayınlanır. Rate limit: IP başına 60 istek/dk. Yapılandırma ortam değişkeniyle; `.env` repoya girmez, `.env.example` girer.

---

## 9. FAZ FAZ YÜRÜTME PLANI

Her fazın sonunda: `flutter analyze` temiz, testler yeşil, kabul kriterleri işaretli, ilerleme `/docs/PROGRESS.md`'ye yazılır. **Commit atılmaz** (bkz. §12).

### FAZ 1 — Temel (A1)
- Flutter projesi, monorepo düzeni: `/app`, `/services`, `/supabase`, `/spike`, `/docs`
- Riverpod + go_router + Drift kurulumu
- Tema motoru: `SpineTheme.dark` / `.light`, tokenlar §4'ten
- Fontlar gömülür, `AdaptiveScaffold` iskeleti
- GitHub Actions: analyze + test (build/deploy yok)
- **Kabul:** boş uygulama iki platformda açılıyor, tema anahtarı çalışıyor, cold start < 2s

### FAZ 2 — Tasarım Sistemi (A2)
- `ShelfStrip` (3 varyant), `ConfidenceBadge`, `BookCard`, `SpineCropView`, `AdaptiveSheet`, `MonoLabel`, `PrimaryButton`
- `motion/` sabitleri, reduce-motion desteği
- Widgetbook benzeri bir `/app/lib/design/gallery.dart` demo ekranı
- **Kabul:** Image 1–14'teki her bileşen galeride tek tek görülebiliyor, iki temada da doğru

### FAZ 3 — Veri (A3)
- Supabase migration'ları (§6.1), RLS policy'leri, anonim auth
- Drift yerel şema + senkron kuyruğu
- **Kabul:** RLS testleri — başka kullanıcının satırı hiçbir sorguda dönmüyor

### FAZ 4 — Kitap İndeksi (A4)
- Open Library dump indirme + filtreleme betiği (yalnızca gerekli alanlar; `tur` ve `eng` öncelikli alt küme)
- Postgres COPY ile toplu yükleme, `pg_trgm`/`unaccent` eklentileri
- **Kabul:** 1M+ kayıt yüklü, tek trigram sorgusu < 80ms (p95)

### FAZ 5 — Eşleştirme Servisi (A5)
- Go servisi, §8'deki normalizasyon + skorlama + bantlar
- Faz 0 veri setinden üretilen sorgularla golden test: `go test ./... -run Golden`
- Docker + compose + tunnel yapılandırması
- **Kabul:** golden testte Faz 0 raporundaki doğruluk oranı yeniden üretiliyor (±%3)

### FAZ 6 — Yakalama (A6)
- Kamera ekranı (Image 11): tesviye, hizalama çerçevesi, ipucu chip'i, deklanşör, son çekim küçük resmi
- Köşe düzeltme ekranı, ön işleme, OCR, §7.3 kümeleme
- İşleniyor ekranı (Image 9): sırt dikdörtgenleri sırayla çizilir, mono log, yüzde
- **Kabul:** 20 fotoğrafın tamamı çökmeden işleniyor; orta seviye Android'de 20 kitaplık raf için çekimden sonuca **< 8 saniye**

### FAZ 7 — Sonuç ve Düzeltme (A7) — *ürünün en kritik fazı*
- Sonuç ekranı (Image 12): kaynak görsel açılır-kapanır, mini ShelfStrip, üç gruplu liste, `CONF: 0.98` mono değerleri, alt aksiyon çubuğu
- Düzeltme sheet'i (Image 10): kırpım görüntüsü (zoom + döndür), 3 aday, "Search Manually", "Not a book"
- Manuel arama (Image 5)
- Toplu işlemler: "Add 8 matched books", "Review 2 issues"
- UNKNOWN kartında "Enhance" (kredi uyarısı ile)
- **Kabul:** kullanıcı bir taramadaki tüm hataları **uygulamayı terk etmeden** düzeltebiliyor; her düzeltme yerel + buluta yazılıyor

### FAZ 8 — Kütüphane (A8)
- Kütüphane boş durum (Image 3) ve dolu durum (Image 4) — **düzeltme: `UNKNOWN`/`Scan Failed` öğeleri kütüphaneye karışmaz**, üstte "3 bekleyen öğe" bandı olarak durur ve düzeltme akışına götürür
- Filtre chip'leri, arama, kitap detay (Image 1), raflar (Image 14)
- ShelfStrip renklerinin sırt kırpımlarından üretilmesi
- **Kabul:** 500 kitaplık kütüphanede kaydırma 60fps; çevrimdışı tam çalışıyor

### FAZ 9 — Paylaşım ve Yerelleştirme (A9)
- Paylaşılabilir koleksiyon kartı (Image 13): PNG render + paylaş sayfası
- TR/EN i18n (`flutter_localizations` + ARB), tüm metinler dışarı çıkarılır
- Ayarlar: tema, bulut senkronu anahtarı, veri dışa aktarma (CSV/JSON), hesap silme
- **Kabul:** uygulamada tek bir sabit kodlanmış kullanıcı metni kalmadı

### FAZ 10 — Sertleştirme ve Mağaza (A9)
- Performans bütçeleri CI'da ölçülür: cold start < 2s, tarama < 8s, APK < 45MB, bellek tepe < 250MB
- Hata izleme (Sentry), çevrimdışı hata kuyruğu
- Gizlilik metinleri (§5), App Store Nutrition Label, Play Data Safety
- Play kapalı test (12 kullanıcı / 14 gün gereksinimi) planı, App Store Connect hazırlığı
- İkon, splash, mağaza görselleri, açıklama metinleri (TR/EN)
- **Kabul:** her iki mağazanın inceleme kontrol listesi `/docs/RELEASE_CHECKLIST.md`'de işaretli

---

## 10. TEST VE REGRESYON

- `/spike/dataset/` **kalıcı olarak repoda kalır** ve regresyon kapısına dönüşür.
- `make eval` komutu: 20 fotoğrafı uçtan uca çalıştırır, doğruluk raporu üretir, önceki rapordan **%3'ten fazla düşerse CI kırılır.**
- Birim test zorunlu: kümeleme algoritması, normalizasyon, skorlama bantları, RLS.
- Widget test: `ConfidenceBadge` üç durum, `ShelfStrip` boş/dolu.
- Altın kural: **doğruluk metriği bir özelliktir, iyileşmesi ölçülür.**

---

## 11. RİSK KAYDI

| Risk | Olasılık | Etki | Önlem |
|------|----------|------|-------|
| Türkçe kitap kapsamı zayıf | Yüksek | Yüksek | Google Books fallback + kullanıcı katkısıyla indeks büyütme |
| İnce/cep kitap sırtları okunamıyor | Yüksek | Orta | Kümede bölme kuralı; düzeltme akışı |
| Cam kapaklı raf yansıması | Orta | Orta | Flaş varsayılan kapalı, uyarı metni |
| VLM maliyeti kontrolsüz büyür | Orta | Yüksek | Yalnızca manuel tetikleme + kredi sistemi + IP rate limit |
| Ev sunucusu erişilemez | Orta | Yüksek | Servis stateless; Fly.io'ya taşıma yolu Faz 5'te hazır tutulur |
| Mağaza gizlilik reddi | Düşük | Yüksek | §5 mimarisi + beyanların birebir uyumu |

---

## 12. GIT VE KATKI KURALLARI (zorunlu — `CLAUDE.md`'ye aynen yazılacak)

```markdown
## Git kuralları
- `git commit` ve `git push` ÇALIŞTIRILMAZ. Tüm commit ve push işlemlerini
  yalnızca Kutluhan manuel yapar.
- Branch AÇILMAZ (`git branch`, `git checkout -b` yok). Çalışma mevcut
  branch üzerinde kalır.
- Commit mesajlarına "Co-Authored-By: Claude" veya herhangi bir AI/Claude
  atfı EKLENMEZ. GitHub Contributors listesinde yalnızca Kutluhan görünür.
- Değişiklikler yapılır, `git status` ile özet sunulur, commit kullanıcıya bırakılır.
```

Ayrıca `CLAUDE.md` şunları içerecek: klasör sahiplikleri (§0), stack kararları (§3.1), tasarım tokenları (§4), "v1 kapsam dışı" listesi (§1.3) ve her fazın kabul kriteri.

---

## 13. İLK KOMUT

Claude Code'a verilecek ilk talimat:

> `SPINE_BLUEPRINT.md` dosyasını oku. Yalnızca **Faz 0**'ı uygula: `/spike/` klasörünü oluştur, kümeleme algoritmasını (§7.3) yaz, `/spike/dataset/` içindeki 20 fotoğraf üzerinde çalıştır ve `/spike/report.md` raporunu üret. Üretim kodu yazma, Flutter projesi kurma, commit atma. Rapor hazır olunca dur ve sonucu bildir.
