# Google Play — 14 Günlük Kapalı Test Planı (12+ Test Kullanıcısı)

**Paket Adı:** `com.kutluhangil.rafca`
**Gereksinim:** Google Play Store bireysel geliştirici politikası uyarınca en az **12 test kullanıcısının** en az **14 gün kesintisiz** kapalı test kanalına (Closed Testing Track) katılımı zorunludur.

---

## 1. Test Takvimi ve Zaman Çizelgesi

```
[GÜN 1-2]   Dağıtım ve Kurulum (Onboarding & Permission flow)
[GÜN 3-6]   Kamera, Tesviye ve Raf Tarama (Capture & Warp)
[GÜN 7-10]  Sonuç İnceleme, Eşleştirme ve Kütüphane Yönetimi
[GÜN 11-13] Paylaşım Kartları, Dışa Aktarma (CSV/JSON), Tema & Dil Değişimi
[GÜN 14]    Geri Bildirim Derleme, Hata İncelemesi ve Üretim Başvurusu
```

---

## 2. Test Kullanıcı Grubu Listesi (14 Kişi / Hedef: >12 Aktif)

| No | İsim / Kod | Cihaz Modeli | Android Sürümü | Rol / Görev |
|---|---|---|---|---|
| 1 | Tester-01 (Kutluhan) | Google Pixel 8 | Android 14 | Ana doğrulama & log takibi |
| 2 | Tester-02 (Orkun) | Samsung Galaxy S23 | Android 14 | Performans ve kamera tesviye |
| 3 | Tester-03 | Xiaomi 13T | Android 14 | Farklı ışık koşullarında raf tarama |
| 4 | Tester-04 | OnePlus 11 | Android 14 | Çevrimdışı tarama ve yerel eşleştirme |
| 5 | Tester-05 | Samsung Galaxy A54 | Android 13 | Orta segment bellek/RAM tepe testi |
| 6 | Tester-06 | Google Pixel 7a | Android 14 | Dil değişimi (TR/EN) & ayarlar |
| 7 | Tester-07 | Honor Magic 5 | Android 13 | 4-noktalı perspektif warp doğrulama |
| 8 | Tester-08 | Poco F5 | Android 13 | Paylaşım kartı PNG render |
| 9 | Tester-09 | Nothing Phone (2) | Android 14 | Tema değişimi (Koyu/Açık/Sistem) |
| 10 | Tester-10 | Motorola Edge 40 | Android 13 | 30+ kitaplık yoğun raf taraması |
| 11 | Tester-11 | Samsung Galaxy S21 FE | Android 14 | Kütüphane arama ve filtreleme |
| 12 | Tester-12 | Vivo V29 | Android 13 | CSV/JSON dışa aktarma doğrulaması |
| 13 | Tester-13 (Yedek) | Redmi Note 12 | Android 12 | Minimum desteklenen sürüm testi |
| 14 | Tester-14 (Yedek) | Samsung Tab S8 | Android 14 | Tablet geniş ekran / adaptive test |

---

## 3. Günlük Test Senaryoları ve Kontrol Noktaları

### Faz 1 (Gün 1-3): Kurulum & Kamera Kapısı
- Google Play Kapalı Test bağlantısından uygulamanın indirilmesi.
- Kamera izni akışının test edilmesi (İzin verildi / Reddedildi durumları).
- Roll & pitch su terazisi (±7° tolerans) kontrolü: Cihaz eğildiğinde kırmızı, düzken yeşil geri bildirim.

### Faz 2 (Gün 4-7): Tarama ve Perspektif Düzeltme
- Farklı aydınlatma (gün ışığı, loş sarı ışık, LED) koşullarında 3 farklı raf taraması.
- 4-köşeli perspektif seçicinin sürüklenmesi ve raf sınırlarına oturtulması.
- OCR ve segmentasyonun doğruluğu; yatay ve dikey yazılmış sırtların tanınması.

### Faz 3 (Gün 8-11): İnceleme ve Kütüphane
- Sonuç ekranında güven bantlarının (`Matched`, `Needs Review`, `Unrecognized`) doğruluğu.
- `ReviewBottomSheet` üzerinden alternatif baskı seçimi ve "Kitap Değil" butonu testi.
- `Proof of Capture` görselinin kitap detayında düzgün görüntülenmesi.
- Özel raf oluşturma ve kitapların raflara taşınması.

### Faz 4 (Gün 12-14): Paylaşım, Ayarlar ve Kararlılık
- Koleksiyon paylaşım kartı (Image 13) oluşturma ve görsel kaydetme.
- Ayarlar üzerinden kütüphaneyi CSV ve JSON olarak dışa aktarma; dosyaların e-tablo uygulamasında açılması.
- Çökme veya takılma yaşanıp yaşanmadığının Telemetry logları üzerinden doğrulanması.

---

## 4. Geri Bildirim Toplama ve İzleme
- **Google Play Geri Bildirim Formu:** Kapalı test kanalında doğrudan mağaza içi özel geri bildirimler.
- **İletişim Kanalı:** Özel Telegram/WhatsApp test grubu veya e-posta (`tester@rafca.app`).
- **14. Gün Sonu:** 14 gün kesintisiz aktiflik tamamlandıktan sonra Play Console üzerinden "Apply for production" adımı tetiklenecektir.
