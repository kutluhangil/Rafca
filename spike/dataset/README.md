# Faz 0 dataset

Bu klasör **kalıcıdır**. Faz 0 bittikten sonra da repoda kalır ve regresyon
kapısına dönüşür (SPINE_BLUEPRINT.md §10): `make eval` bu fotoğrafları uçtan
uca çalıştırır, doğruluk önceki rapordan %3'ten fazla düşerse CI kırılır.

## Ne koyulacak

**20 gerçek raf fotoğrafı.** Mockup, ekran görüntüsü veya internetten indirilmiş
stok fotoğraf değil — kendi kitaplığından, telefonla çekilmiş fotoğraflar.

Çeşitlilik zorunlu (§2.1):

| Adet | Grup id | Koşul |
|------|---------|-------|
| 6 | `good_light` | İyi ışık, düz açı, kalın sırtlar |
| 6 | `warm_angled` | Sarı ev ışığı, 10–25° açı |
| 4 | `thin_spines` | İnce sırtlar / cep kitapları |
| 4 | `turkish` | Türkçe kitaplar ağırlıklı raf |

## Çekim kuralları

- En az 3000px genişlik (§7.1). Telefonda tam çözünürlük açık olsun.
- Flaş kapalı — cam ve parlak sırtlar yansıma yapar.
- Rafa mümkün olduğunca paralel dur; `warm_angled` grubu bilerek açılı olacak.
- Tek karede en fazla bir raf katı olsun.
- Sırtlar okunabilir olsun; sen okuyamıyorsan OCR da okuyamaz.

## Sonra

`ground_truth.example.json` dosyasını `ground_truth.json` olarak kopyala ve
her fotoğraf için raftaki kitapları **soldan sağa sırayla** yaz. Sonra:

```sh
cd spike
swiftc -O -o tool/vision_ocr tool/vision_ocr.swift   # bir kez
dart run bin/spike.dart --crops
```

Rapor `spike/report.md` dosyasına yazılır. GO/NO-GO kararı raporu okuyan
kullanıcıya aittir, Claude Code bu kapıyı kendi başına geçemez.

## Neden mockup olmaz

`stitch_spine_book_scanner_app/` altındaki `screen.png` dosyaları arayüz
tasarımıdır. İçlerindeki kitap görselleri kusursuz, düz ve yüksek kontrastlı
render'lardır. Onlarla ölçülen doğruluk gerçek bir rafta karşılaşılacak
doğruluk hakkında hiçbir şey söylemez.
