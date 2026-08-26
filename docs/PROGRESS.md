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
| Doğrulama sırası | Her fazda önce Android emülatöründe ölçülür; iOS Faz 9'da toplu doğrulanır | 2026-08-26 |

Faz 1 detayı: [PROGRESS_FAZ1.md](PROGRESS_FAZ1.md).

## FAZ 1 — Temel (A1)

**Durum: Android tarafı KAPALI. iOS doğrulaması Faz 9'a ertelendi.**

Flutter iskeleti, tema motoru, adaptive kabuk, Drift bağlantısı ve CI kuruldu;
`flutter analyze` temiz, `flutter test` 22/22 yeşil.

Kabul kriteri Pixel 9 emülatöründe profile APK ile ölçüldü: uygulama açılıyor,
tema anahtarı SYSTEM → DARK → LIGHT → SYSTEM döngüsünü tamamlıyor, cold start
`TotalTime` 970–1405 ms (bütçe 2000 ms). Ölçüm detayı ve iOS erteleme gerekçesi:
[PROGRESS_FAZ1.md](PROGRESS_FAZ1.md).

## FAZ 0 — Doğruluk spike

**Durum: altyapı tamam, veri bekliyor. Kapı KAPALI.**

Yapıldı:
- [x] `packages/spine_clustering` — §7.3 kümeleme algoritması, saf Dart,
      Flutter'a bağımsız. 25 birim testi.
- [x] `spike/tool/vision_ocr.swift` — masaüstü OCR probu (Apple Vision).
      Dört rotasyonun orijinal görüntü uzayına geri eşlendiği doğrulandı.
- [x] `spike/lib/eval/` — §8.2 normalizasyon, §8.3 skorlama, §8.4 bantlar,
      metrikler, rapor üreteci. 28 birim testi.
- [x] `spike/lib/eval/crops.dart` — §7.3 adım 9, sırt kırpımı + baskın renk.
- [x] `spike/dataset/` — şema, örnek `ground_truth.json`, çekim talimatları.
- [x] `make eval` giriş noktası.
- [x] Boru hattı uçtan uca çalıştırıldı (geçici fixture ile) — OCR, kümeleme,
      eşleştirme, rapor, kırpım, renk çıktısı üretiliyor.

Yapılmadı — **kullanıcıyı bekliyor**:
- [ ] `spike/dataset/` altına 20 gerçek raf fotoğrafı (6 `good_light`,
      6 `warm_angled`, 4 `thin_spines`, 4 `turkish`).
- [ ] `spike/dataset/ground_truth.json` doldurulması.
- [ ] `make eval` ile `spike/report.md` üretimi.
- [ ] GO/NO-GO kararı (§2.2) — **karar kullanıcıya aittir**.

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
