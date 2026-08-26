# Rafça — proje kuralları

> Ürün: raf fotoğrafından kitap sırtlarını tanıyıp fiziksel kütüphaneyi dijitalleştiren mobil uygulama.
> Yürütme planı: `SPINE_BLUEPRINT.md`. Fazlar sırayla, kabul kriteri geçilmeden sonrakine geçilmez.

## Ad ve kimlik
- Kullanıcıya görünen ad: **Rafça** (blueprint'teki "SPINE" kod adıdır, UI'da kullanılmaz).
- Kod içi tanımlayıcılar İngilizce kalır: `SpineColors`, `ShelfStrip`, `SpineCandidate`.
- Package / bundle id: `com.kutluhangil.rafca` (Android + iOS aynı).

## Git kuralları
- `git commit` ve `git push` ÇALIŞTIRILMAZ. Tüm commit ve push işlemlerini
  yalnızca Kutluhan manuel yapar.
- Branch AÇILMAZ (`git branch`, `git checkout -b` yok). Çalışma mevcut
  branch üzerinde kalır.
- Commit mesajlarına "Co-Authored-By: Claude" veya herhangi bir AI/Claude
  atfı EKLENMEZ. GitHub Contributors listesinde yalnızca Kutluhan görünür.
- Değişiklikler yapılır, `git status` ile özet sunulur, commit kullanıcıya bırakılır.

## Platform kararı
Flutter 3.44+ tek kod tabanı, iOS + Android. Backend ortak.
Sıra: önce Android'de doğrulanır, sonra iOS adaptive katmanı + platform testleri.
Özellik kodu asla `Platform.isIOS` kontrolü yapmaz — yalnızca `app/lib/design/adaptive/` bileşenlerini çağırır.

## Stack (sabit, tartışmaya kapalı)
| Katman | Karar |
|--------|-------|
| Mobil | Flutter 3.44 stable, Dart 3.12 |
| State | Riverpod 2 (code-gen'li) |
| Routing | go_router |
| Yerel DB | Drift (SQLite) |
| OCR (cihaz) | google_mlkit_text_recognition |
| OCR (spike/masaüstü) | Apple Vision CLI (`spike/tool/vision_ocr.swift`) |
| Kamera | camera + sensors_plus |
| Backend | Go 1.2x, `net/http` + `pgx` |
| DB/Auth/Storage | Supabase (önce yerel Docker, sonra bulut) |
| Dağıtım | Docker Compose + Cloudflare Tunnel |

## Klasör sahiplikleri
| Ajan | Sahip olduğu yollar |
|------|--------------------|
| A0 Spike | `/spike/**` |
| A1 Foundation | `/app/lib/core/**`, `/app/pubspec.yaml`, `/.github/**` |
| A2 Design System | `/app/lib/design/**` |
| A3 Data | `/supabase/**` |
| A4 Index | `/services/index/**` |
| A5 Match | `/services/match/**` |
| A6 Capture | `/app/lib/features/capture/**` |
| A7 Review | `/app/lib/features/review/**` |
| A8 Library | `/app/lib/features/library/**` |
| A9 Release | `/app/android/**`, `/app/ios/**`, `/docs/**` |

Paylaşılan saf Dart kütüphanesi: `/packages/spine_clustering/**` (Flutter'a bağımsız, hem `/spike` hem `/app` kullanır).

Bir ajan yalnızca kendi sahip olduğu dosyaları değiştirir. Başka bir ajanın dosyasına dokunmak gerekiyorsa faz durdurulur ve rapor edilir.

## Design direction: stitch-nocturnal-archivist
Tasarım kaynağı `stitch_spine_book_scanner_app/` — 14 ekran mockup'ı + `nocturnal_archivist/DESIGN.md`.
**Token otoritesi `DESIGN.md`'dir**, `SPINE_BLUEPRINT.md` §4.1 değil (çakışmada DESIGN.md kazanır).
Yeni bir design skill sorulmaz, bu satır kararı kaydeder.

Sabitler:
- Gölge yok. Derinlik = 1px hairline border (`outline-variant #4f4537`) + üst kenarda %10 beyaz iç parlaklık.
- Radius: kart 14, sheet 24 (yalnız üst köşeler), buton 12, chip stadium.
- Spacing skalası: 4 / 8 / 12 / 16 / 24 / 32 / 48.
- Fontlar `assets/fonts/` altına gömülür — `google_fonts` paketi KULLANILMAZ.
- IBM Plex Mono her zaman UPPERCASE + letterSpacing, "sistem çıktısı" anlamı taşır.
- Hiçbir animasyon 400ms'i geçmez; reduce-motion açıkken hepsi 120ms crossfade.

## Yerelleştirme
TR + EN. Cihaz dili takip edilir, desteklenmiyorsa **TR**'ye düşer.
Kullanıcıya görünen tek bir metin bile sabit kodlanmaz — hepsi ARB dosyalarında.

## Gizlilik (sabit kural)
Ham raf fotoğrafı ve sırt kırpımları **varsayılan olarak yalnızca cihazda** tutulur.
Sunucuya giden tek şey: OCR düz metni. Tek istisna — kullanıcı "Enhance"e basarsa yalnızca o tek sırt kırpımı gider.

## v1 kapsam dışı (eklenmeyecek)
Sosyal akış / takip / yorum / puanlama · okuma istatistikleri · plak-VHS-board game UI'ı ·
çoklu cihaz gerçek zamanlı senkron · kitap satın alma / affiliate.

## Her fazın sonunda
`flutter analyze` temiz · testler yeşil · kabul kriterleri işaretli · ilerleme `docs/PROGRESS.md`'ye yazılır · commit atılmaz.
