# App Store Connect — Dağıtım ve Yayın Hazırlık Kılavuzu

**Uygulama Adı:** Rafça
**Paket Tanımlayıcı (Bundle ID):** `com.kutluhangil.rafca`
**SKU:** `RAFCA-IOS-01`
**Telif Hakkı:** © 2026 Kutluhan Gül

---

## 1. Uygulama Bilgileri (App Information)

| Alan | Değer |
|---|---|
| Birincil Dil | Türkçe (tr) |
| İkincil Dil | English (en-US) |
| Birincil Kategori | Books (Kitaplar) |
| İkincil Kategori | Reference (Referans) |
| Yaş Sınırı | 4+ (Hiçbir sakıncalı içerik, şiddet, kumar veya yetişkin içeriği bulunmaz) |

---

## 2. TestFlight Yapılandırması

### Dahili Test Grubu (Internal Testing)
- **Kullanıcılar:** Kutluhan Gül, çekirdek geliştirme ekibi.
- **Derleme:** Ad-hoc / TestFlight otomatik dağıtım.
- **Odak:** Hızlı hata ayıklama ve yeni özellik doğrulaması.

### Harici Test Grubu (External Testing)
- **Grup Adı:** `Rafça Beta Archivists`
- **Geri Bildirim E-postası:** `beta@rafca.app`
- **Test Edilecek Özellikler:**
  - Kamera raf tesviyesi ve perspektif warp.
  - Sırt kırpımları ve yerel katalog eşleşmesi.
  - Koleksiyon paylaşım kartı PNG dışa aktarma.
  - Dil ve tema değişimi.

---

## 3. İhracat Uyumluluğu (Export Compliance)
- **Soru:** Does your app use encryption?
- **Cevap:** **Yes** (Uygulama yalnızca standart HTTPS/TLS bağlantıları ve yerel SQLite dosya şifrelemesi kullanır).
- **Muafiyet:** App qualifies for encryption exemption under Category 5, Part 2 (Exempt from Export Administration Regulations — EAR). `ITSAppUsesNonExemptEncryption = NO` (`Info.plist` anahtarı).

---

## 4. İnceleme İletişim Bilgileri (App Review Information)
- **Giriş Bilgileri Gerekiyor mu?** Hayır (Uygulama hesap oluşturmadan doğrudan yerel kütüphane tarayıcısı olarak çalışır).
- **Demo Notları:**
  - "Rafça allows scanning physical book spines on a bookshelf using the camera. To test without a physical bookshelf, point the camera at any shelf image on a monitor or printout. The roll/pitch level indicators will guide framing."
- **İletişim:** Kutluhan Gül — `kutluhangul@windowslive.com`
