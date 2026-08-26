# Changelog

Newest entries at top.

## Unreleased

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
