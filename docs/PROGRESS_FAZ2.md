# FAZ 2 — Tasarım Sistemi (A2)

**Durum: KAPALI.** `flutter analyze` temiz, `flutter test` 47/47 yeşil.

## Yapıldı

- [x] `design/motion/motion.dart` — §4.7 süre ve eğri sabitleri. İki global
      kural koda gömüldü: hiçbir süre 400ms'i geçemez (`assert`, kırpma yok) ve
      reduce-motion açıkken her şey 120ms crossfade'e düşer, stagger sıfırlanır,
      eğri lineerleşir, hiçbir şey yer değiştirmez.
- [x] `ShelfStrip` — üç varyant (compact 40px / hero 96px / empty 96px).
      Çubuklar tek bir zaman çizelgesinden 12ms arayla tabandan büyür. Genişlik
      oransal (`Flexible`), yani şerit fiziksel rafın ölçekli çizimi.
- [x] `ConfidenceBadge` — 3px çubuk + mono etiket, üç bant.
- [x] `BookCard` — kırpım sola dayalı, güven çubuğu kart kenarında tam boy,
      hairline kural üstünde metadata alt satırı.
- [x] `SpineCropView` — pirinç köşe ayraçları; kırpım yoksa boş çerçeve.
- [x] `MonoLabel` — iki boy (`caps` 11px, `data` 12px), her zaman UPPERCASE.
- [x] `PrimaryButton` — primary (pirinç dolgu) ve secondary (saydam + hairline).
- [x] `AdaptiveSheet` — Android'de Material bottom sheet, Apple'da detentli
      sheet; her ikisinde de aynı 24px üst köşe, hairline ve üst kenar parlaması.
- [x] `design/gallery.dart` — her bileşen tek tek, iki temada. Tema anahtarı,
      reduce-motion zorlama anahtarı ve animasyon tekrar oynatma düğmesi var.
      `/gallery` rotasından ve ana ekrandaki düğmeden erişilir.
- [x] 25 yeni widget testi (`components_test.dart`, `adaptive_sheet_test.dart`).

## Kabul kriteri

Blueprint: "Image 1–14'teki her bileşen galeride tek tek görülebiliyor, iki
temada da doğru."

Doğrulama yüzeyi Chrome (`flutter run -d web-server`, Playwright ile
ekran görüntüsü) — kullanıcı talimatı gereği emülatör kullanılmadı; cihaz
doğrulaması tüm fazlar bitince toplu yapılacak.

- [x] Dokuz bileşen bölümünün hepsi galeride ayrı ayrı görülüyor.
- [x] Koyu tema mockup'larla eşleşiyor (pirinç `#C9963F`, kart yüzeyi, hairline).
- [x] Işık teması doğru — aşağıdaki iki kusur bulunup düzeltildikten sonra.
- [x] Material dalı (Android UA ile) ve Cupertino dalı (masaüstü Chrome, macOS
      olarak raporlanıyor) ayrı ayrı açıldı; sheet ikisinde de tek yüzey.

## Doğrulamada bulunan ve düzeltilen kusurlar

1. **Pirinç, ışık temasında kayboluyordu.** `primaryContainer` koyu temada
   `#C9963F` (mockup'ın pirinci) ama ışık temasında `#FFDEAE` — parşömen zemin
   üzerinde birincil butonun zeminden neredeyse hiç ayrışmadığı soluk bir krem.
   Aynı sorun `SpineCropView` köşe ayraçlarını da okunmaz yapıyordu. Çözüm:
   `SpineSemanticColors`'a `brass` / `onBrass` eklendi — koyu tema
   `primaryContainer`, ışık teması `#7F5700` + beyaz. Rol tek yerden okunuyor.

2. **AdaptiveSheet iki kat çiziyordu.** `showModalBottomSheet` temadaki
   `bottomSheetTheme`'den kendi yüzeyini, şeklini ve sürükleme tutamağını
   çiziyor, `_SheetSurface` de kendininkini — sonuç iki yuvarlak üst köşe ve iki
   tutamak. Chrome'un tek sahibi `_SheetSurface` yapıldı.

3. **Cupertino dalında metin debug stiliyle çiziliyordu.** `showCupertinoSheet`
   bir `Material` atası sağlamıyor; sheet içindeki her metnin altı çiziliyordu
   ve içerideki `InkWell`'in boyayacağı yüzey yoktu. `_SheetSurface` saydam bir
   `Material` ile sarıldı. Test her iki platformda da bunu doğruluyor.

4. **`ConfidenceBadge` Türkçe İ'yi bozuyordu.** Dart'ın `String.toUpperCase()`
   metodu locale duyarlı değil: `i` her zaman `I` oluyor, `ı` hiç değişmiyor.
   Türkçe varsayılan dil olduğu için `uppercaseForLocale` yazıldı ve mono
   etiket, rozet ve buton üçü de oradan geçiyor. `eşleşti` artık `EŞLEŞTİ`.

## Faz dışı, bilerek yapılan iki ekleme

- **`flutter_localizations`** (Faz 8'den öne çekildi). Bileşenler locale'e göre
  büyük harfe çeviriyor ve ürünün fallback dili Türkçe; delegate olmadan `tr`
  locale'i her build'de uyarı veriyor ve çerçeve metinleri İngilizce kalıyordu.
  ARB dosyaları ve uygulama metinleri hâlâ Faz 8'de.
- **Web platformu** (`app/web/`). Faz içi görsel doğrulama yüzeyi; dağıtım
  hedefi değil. `dart:io` bağımlı olduğu için Drift bağlantısı koşullu import'a
  ayrıldı: `connection/native.dart` cihazda, `connection/web.dart` web'de
  açıkça `UnsupportedError` fırlatıyor — sessiz bellek-içi geri düşüş yok.

## Sahiplik notu

A2 `/app/lib/design/**` sahibi. Bu fazda A1 alanında üç dosyaya dokunuldu ve
sebepleri şunlar:

- `core/router/app_router.dart` — galeriye `/gallery` rotası.
- `core/app/rafca_app.dart` — localization delegate'leri.
- `core/database/app_database.dart` + `connection/` — web derlemesinin
  derlenebilmesi için koşullu import.
- `features/home/home_screen.dart` — galeriye giden düğme.

## Bilinen açık uçlar

- Mockup'ların HTML'i kart yüzeyi için `#1C1916`, hairline için `#3A332A`
  kullanıyor; DESIGN.md frontmatter'ı ise `#1d1b19` ve `#4f4537` diyor. CLAUDE.md
  hairline'ı `outline-variant #4f4537` olarak sabitlediği için frontmatter
  izlendi. Gözle fark edilmiyor, ama bir gün mockup'a birebir oturtmak
  gerekirse çakışma burada.
- Işık teması hâlâ türetilmiş. İlk ışık mockup'ı geldiğinde `SpineColors.light*`
  ve `SpineSemanticColors.light` yeniden gözden geçirilmeli.
- Galeri metinleri bilerek yerelleştirilmedi; kullanıcıya çıkmayan bir
  geliştirici ekranı.
