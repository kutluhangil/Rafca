# Changelog

Newest entries at top.

## Unreleased

- Faz 5: `services/match/` eklendi — Go eşleştirme servisi; `/v1/match`, `/v1/enhance`, `/v1/health`, IP başına dakikada 60 istek.
- Faz 5: `internal/normalize` eklendi — spike'ın Dart normalizasyonundan port; Türkçe I/İ katlaması, yayınevi adı sorgudan çıkarılıp ayrı skor sinyali oluyor, uzun imprint adı başlığı boğmasın diye.
- Faz 5: `internal/score` eklendi — §8.3 ağırlıkları ve §8.4 bantları; yüksek skorlu ama farkı az sonuç MATCHED değil REVIEW, "Dune 1965" ile "Dune 50th Anniversary" tam da düzeltme akışının var olma sebebi.
- Faz 5: Sırtın iki okuması da skorlanıyor — hangisinin düz olduğu eşleştirmeden önce bilinemiyor, iyi olan kazanıyor.
- Faz 5: `internal/vlm` eklendi — düşük güvenli kırpımlar için claude-opus-5 ile structured output.
- Faz 5: Google Books ikinci katmanı bulduğunu `books_index`'e yazıp sonucu birinci katmandan yeniden skorluyor — cevap hep aynı skorlayıcıdan çıkıyor, indeks de kitabı öğreniyor.
- Faz 5: `internal/matcher/golden_test.go` eklendi — §9 regresyon kapısı; fixture'ı gerçek Postgres'e yükleyip normalize → retrieve → score → band zincirini uçtan uca koşuyor, `make match-golden`. Boş olmayan bir `books_index`'e denk gelirse çalışmayı reddediyor.

- Faz 4: `services/index/` eklendi — `ol-index` üç geçişte çalışır (filter → authors → join); 12 GB'lık editions dump'ı tek seferde belleğe sığmadığı için yazar adları ayrı geçişte çözülür.
- Faz 4: `internal/copyfmt` eklendi — PostgreSQL COPY text formatı için kaçış; ters bölü, tab, satır sonu ve `text[]` dizileri round-trip doğrulandı.
- Faz 4: `index-bench` eklendi — pgx ile arama p95 ölçümü, Faz 4 kabul kriteri.
- Faz 4: `ingest.sh` katalogu değiştirmiyor, birleştiriyor — `user_books` satırları `books_index`'e id ile bağlı; truncate-and-reload'u foreign key reddeder, kabul etseydi birinin kütüphanesini başka kitaba bağlardı. Staging tablosu + `on conflict (ol_key) do update` ile id'ler kalıcı.
- Faz 4: `ingest.sh` geçişleri yeniden kullanılabilir — çıktısı duran geçiş atlanıyor; yükleme adımında kesilen bir koşu 12 GB'ı yeniden taramak zorunda kalmıyor.
- Faz 4: `ingest.sh` indeks tanımlarını `pg_indexes` yerine migration dosyasından okuyor — drop ile rebuild arasında kesilen bir koşuda katalog o indeksleri artık tutmadığı için, sonraki koşu hiçbir indeksi geri kurmuyordu.
- Faz 4: `supabase/harness/apply.sh` ayrıldı — test ve geliştirme veritabanı aynı adımlardan kuruluyor.

- Faz 3: `SyncQueueDao` eklendi — outbox kuyruğu; kuyruk kaydı ile satırın `pending_sync` bayrağı tek transaction'da yazılır, aynı satırın tekrar sıraya girmesi tek kayda indirgenir.
- Faz 3: Drift yerel şeması dolduruldu — `CatalogBooks`, `Shelves`, `UserBooks`, `Scans`, `SyncQueueEntries`; sunucuda karşılığı olmayan iki alan: `capture_path` (görseller cihazda kalır) ve `pending_sync`.
- Faz 3: `supabase/harness/` eklendi — `auth` şeması shim'i ve runner; migration'lar ve pgTAP suite'i Docker olmadan düz PostgreSQL üzerinde koşuyor, `make db-start` / `make db-test`.
- Faz 3: `public.spine_join_authors` eklendi — `array_to_string` da yalnızca STABLE olduğu için generated column'da kullanılamıyordu.
- Faz 3: `supabase/tests/rls_test.sql` eklendi — pgTAP; başka kullanıcının satırına select, id ile select, insert, update ve delete denemeleri.
- Faz 3: Supabase migration'ları eklendi — `books_index` (trigram + FTS indeksleri, herkese açık salt okuma), `profiles`/`shelves`/`user_books`/`scans` (komut başına ayrı RLS policy), anonim auth ve yeni kullanıcıda profil tetikleyicisi.
- Faz 3: `public.spine_unaccent` eklendi — `unaccent(text)` yalnızca STABLE olduğu için generated column'da kullanılamıyordu; sözlüğü sabitleyen IMMUTABLE sarmalayıcı.

- Faz 2: `design/gallery.dart` eklendi — her bileşen tek tek, iki temada; tema, reduce-motion ve animasyon tekrar oynatma anahtarlarıyla. `/gallery` rotasından erişilir.
- Faz 2: `AdaptiveSheet` eklendi — Android'de Material bottom sheet, Apple'da detentli sheet; chrome'un tek sahibi `_SheetSurface`, Cupertino dalı için saydam `Material` ile sarılı.
- Faz 2: `ShelfStrip` (compact/hero/empty), `ConfidenceBadge`, `BookCard`, `SpineCropView`, `MonoLabel`, `PrimaryButton` bileşenleri eklendi.
- Faz 2: `design/motion/motion.dart` eklendi — §4.7 süreleri, 400ms tavanı assert ile, reduce-motion 120ms crossfade'e düşürüyor.
- Faz 2: `SpineSemanticColors.brass` / `onBrass` eklendi — `primaryContainer` ışık temasında birincil butonu ve kırpım ayraçlarını zeminden ayrıştıramıyordu.
- Faz 2: `uppercaseForLocale` eklendi — Dart'ın `toUpperCase()` metodu locale duyarlı olmadığı için Türkçe `i` → `İ` ve `ı` → `I` açıkça ele alınıyor.
- Faz 2: `flutter_localizations` delegate'leri Faz 8'den öne çekildi; `tr` locale'i olmadan çerçeve metinleri İngilizce kalıyor ve her build uyarı veriyordu.
- Faz 2: web platformu eklendi (yalnız faz içi görsel doğrulama yüzeyi); Drift bağlantısı koşullu import'a ayrıldı, web dalı sessiz geri düşüş yerine `UnsupportedError` fırlatıyor.
- Faz 1: Android kabul kriteri doğrulandı — Pixel 9 emülatöründe profile APK cold start 970–1405 ms (bütçe 2s), tema anahtarı SYSTEM/DARK/LIGHT döngüsü çalışıyor.
- Faz 1: `cupertino_icons` bağımlılığı eklendi — `AdaptiveScaffold`'un Apple dalındaki `CupertinoSliverNavigationBar` geri chevron glifi bu font olmadan boş çiziliyordu.
- Faz 1: GitHub Actions CI eklendi — saf Dart paketleri ve Flutter uygulaması için analyze + test, ayrıca üretilmiş kaynakların güncelliğini doğrulayan adım.
- Faz 1: `AppDatabase` (Drift) bağlantısı, arka plan izolatı ve provider'ı eklendi; şema Faz 3'te doldurulacak.
- Faz 1: `AdaptiveScaffold` ve `AdaptivePlatform` eklendi — platform sorgusu yalnızca `design/adaptive/` içinde kalır.
- Faz 1: `SpineTheme.dark` / `.light` tema motoru ve `SpineSemanticColors` eklendi; renk, tipografi, boşluk ve şekil tokenları `DESIGN.md`'den sabitlendi.
- Faz 1: Literata, Inter ve IBM Plex Mono `assets/fonts/` altına gömüldü (`google_fonts` kullanılmadı); değişken fontlar `FontVariation` ekseniyle sürülüyor.
- Faz 1: Flutter uygulaması `app/` altında oluşturuldu (`com.kutluhangil.rafca`), Riverpod 2 + go_router + Drift kuruldu.
- Faz 0: `make eval` giriş noktası ve `docs/PROGRESS.md` faz takibi eklendi.
- Faz 0: spike değerlendirme hattı eklendi — §8.2 normalizasyon, §8.3 skorlama, §8.4 güven bantları, metrikler, markdown rapor üreteci, sırt kırpımı ve baskın renk çıkarımı.
- Faz 0: Apple Vision tabanlı masaüstü OCR probu (`spike/tool/vision_ocr.swift`) eklendi; dört rotasyonun orijinal görüntü uzayına geri eşlenmesi doğrulandı.
- Faz 0: `packages/spine_clustering` eklendi — §7.3 sırt kümeleme algoritması, saf Dart, Flutter'a bağımsız; ek olarak sırt genişliği tahminine ihtiyaç duymayan Otsu eşik stratejisi.
- Faz 0: monorepo iskeleti (`packages/`, `spike/`, `services/`, `supabase/`, `docs/`) ve proje kuralları (`CLAUDE.md`) eklendi.
