# FAZ 1 — Temel (A1)

**Durum: Android tarafı KAPALI. iOS doğrulaması Faz 9'a ertelendi.**

## Yapıldı

- [x] Flutter projesi `app/`, package id `com.kutluhangil.rafca` (Android + iOS).
- [x] Monorepo düzeni: `app/`, `packages/`, `services/`, `spike/`, `supabase/`, `docs/`, `data/`.
- [x] Riverpod 2 (code-gen'li) + go_router + Drift kurulumu; `build_runner` çalışıyor.
- [x] Fontlar `assets/fonts/` altına gömüldü, `google_fonts` paketi kullanılmadı.
      Literata ve Inter yalnızca değişken font olarak yayınlandığı için tek dosya
      + `FontVariation('wght'/'opsz')`; IBM Plex Mono statik iki ağırlık.
      OFL lisans dosyaları da yanlarında.
- [x] Tema motoru: `SpineTheme.dark` / `.light`, tokenlar `DESIGN.md`'den.
      Gölge yok, surface tint kapalı, hairline border, sheet yalnız üst köşeler.
- [x] `SpineSemanticColors` ThemeExtension — MATCHED / REVIEW / UNKNOWN,
      hairline, raised surface, üst kenar parlaması.
- [x] `AdaptiveScaffold` + `AdaptivePlatform` iskeleti. Özellik kodu platform
      sormaz; yalnızca `design/adaptive/` sorar.
- [x] `AppDatabase` (Drift) — bağlantı, arka plan izolatı, provider. Şema Faz 3'te.
- [x] GitHub Actions: `dart analyze --fatal-infos` + `dart test` (iki saf Dart
      paketi) ve `flutter analyze --fatal-infos` + `flutter test`; ayrıca üretilmiş
      kaynakların güncel olduğunu doğrulayan adım. Build/deploy yok.
- [x] `flutter analyze` temiz, `flutter test` 22/22 yeşil.

## Kabul kriteri — Android (2026-08-26)

Ölçüm ortamı: Pixel 9 emülatörü (`emulator-5554`, 1080x2424), Flutter 3.44.1,
`flutter build apk --profile`. Debug build JIT yüzünden temsili değildir, bu
yüzden süre profile APK üzerinden alındı.

- [x] **Boş uygulama açılıyor.** `app-profile.apk` kuruldu, ana ekran çiziliyor.
- [x] **Tema anahtarı çalışıyor.** Üç durum sırayla doğrulandı:
      `THEME: SYSTEM` → `DARK` → `LIGHT` → `SYSTEM`. Döngü başa dönüyor
      (dördüncü dokunuştaki ekran görüntüsü ilkiyle bayt bayt aynı).
- [x] **Cold start < 2s.** `am start -W` beş ölçüm, `TotalTime`:
      1405 / 1198 / 970 / 1037 / 1001 ms. En kötü durum 1.41s, kararlı hâl ~1.0s.
      Referans olarak debug APK 3.5–6.4 ms bandındaydı; bütçe profile ile ölçülür.

## iOS — Faz 9'a ertelendi

Kullanıcı kararı: doğrulama sırası önce Android, sonra iOS (bkz. `CLAUDE.md`
"Platform kararı"). iOS'ta cold start ölçümü ayrıca simülatörde yapılamaz —
`flutter build ios --simulator --profile` "Profile mode is not supported for
simulators" ile reddediyor; sayı fiziksel cihazda alınmalı. Faz 9 (A9) iOS
adaptive katmanı ile birlikte ölçülecek.

## Bilinen açık uçlar

- `riverpod` 3.x ve `sqlite3_flutter_libs` 0.6.x yayında; blueprint §3.1
  "Riverpod 2" dediği için 2.x'te kalındı. Sürüm yükseltmesi ayrı bir karar.
- Işık teması türetilmiştir; Stitch yalnızca koyu tema üretti. İlk açık tema
  mockup'ı geldiğinde `SpineColors.light*` değerleri revize edilmeli.
- `cupertino_icons` bağımlılık olarak eklendi. `AdaptiveScaffold` Apple
  platformlarında `CupertinoSliverNavigationBar` kuruyor ve o çubuk geri
  chevron'unu CupertinoIcons fontundan çiziyor; bağımlılık olmadan build
  `packages/cupertino_icons/CupertinoIcons` bulunamadı uyarısı veriyordu ve
  glif çalışma zamanında boş çıkacaktı.
