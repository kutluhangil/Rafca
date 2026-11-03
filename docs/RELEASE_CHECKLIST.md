# Rafça — Mağaza ve Yayın İnceleme Kontrol Listesi (Release Checklist)

**Uygulama Adı:** Rafça (İngilizce: Rafca — Bookshelf Scanner)
**Paket Tanımlayıcı (Package ID / Bundle ID):** `com.kutluhangil.rafca`
**Sürüm:** 1.0.0 (Build 1)
**Tarih:** 3 Kasım 2026
**Kaynak Plan:** `SPINE_BLUEPRINT.md` §448

---

## 1. Apple App Store İnceleme Kontrol Listesi (App Store Review Guidelines)

### A. Kılavuz 2 — Performans ve Kararlılık (Guideline 2.1 & 2.3)
- [x] **Çökme ve Hata Kontrolü:** Uygulama açılışta veya ana akışlarda çökme/hata vermiyor; çevrimdışı hata kuyruğu (`OfflineErrorQueue`) devrede.
- [x] **Tam İşlevsellik:** Uygulama "yapım aşamasında" veya "yakında gelecek" boş butonlar içermiyor.
- [x] **Giriş / Hesap Zorunluluğu Yok:** Giriş yapma zorunluluğu olmadan misafir/yerel kütüphane oluşturulabiliyor. Demo hesap gereksinimi yok.
- [x] **Metaveri Doğruluğu:** Başlık, açıklamalar ve ekran görüntüleri gerçek uygulama işlevselliğini yansıtıyor (`/docs/store/STORE_LISTINGS_TR.md` ve `_EN.md`).
- [x] **Ekran Görüntüleri:** 6.7" ve 6.5" iPhone boyutları spesifikasyona tam uyumlu (`/docs/store/SCREENSHOTS_SPEC.md`).
- [x] **Cold Start Süresi:** Soğuk başlatma süresi < 2.0s performans bütçesinde.

### B. Kılavuz 4 — Tasarım ve Arayüz (Guideline 4.0 & 4.7)
- [x] **Human Interface Guidelines (HIG):** iOS platformunda Cupertino konvansiyonları (`AdaptiveScaffold`, `AdaptiveSheet`, safe area) korunuyor.
- [x] **Karanlık ve Aydınlık Mod:** Koyu Gece (Dark) ve Gündüz (Light) temaları sistem görünümüne göre veya ayarlardan sorunsuz değişiyor.
- [x] **Tipografi Bütünlüğü:** `Literata`, `Inter` ve `IBM Plex Mono` yerel font dosyaları paket içinde; ağ gereksinimi yok.

### C. Kılavuz 5 — Yasal Uyumluluk ve Gizlilik (Guideline 5.1)
- [x] **Gizlilik Politikası:** Şeffaf, yerel öncelikli gizlilik politikası URL'i hazır (`/docs/privacy/PRIVACY_POLICY.md`).
- [x] **App Store Nutrition Label:** "Data Used to Track You = None", "Data Linked to You = None", "Diagnostics = Not Linked" beyanları hazır (`/docs/privacy/APP_STORE_NUTRITION_LABEL.md`).
- [x] **Kamera İzni Açıklaması (`NSCameraUsageDescription`):** Kullanıcıya kameranın yalnızca kitap sırtı tarama amacıyla kullanıldığı ve görsellerin sunucuya yüklenmediği açıkça belirtildi.
- [x] **Fotoğraf Kitaplığı İzni (`NSPhotoLibraryUsageDescription`):** Paylaşım kartı kaydetme gerekçesi belirtildi.
- [x] **Kullanıcı Verisini Silme:** Ayarlar ekranında kütüphaneyi tek dokunuşla sıfırlama (`clearAllData`) mevcut.
- [x] **İhracat Uyumluluğu:** Standart HTTPS şifrelemesi muafiyeti (`ITSAppUsesNonExemptEncryption = NO`).

---

## 2. Google Play Store İnceleme Kontrol Listesi (Google Play Developer Policies)

### A. Veri Güvenliği ve Gizlilik (Play Data Safety)
- [x] **Data Safety Formu:** Form alanları birebir eşleştirildi (`/docs/privacy/PLAY_DATA_SAFETY.md`).
- [x] **Fotoğraf/Video Paylaşımı Yok:** Ham raf fotoğraflarının veya sırt kırpımlarının cihaz dışına çıkmadığı beyan edildi.
- [x] **Üçüncü Tarafla Veri Paylaşımı Yok:** Reklam veya veri simsarlığı SDK'sı bulunmadığı doğrulandı.
- [x] **Veri Silme Mekanizması:** Ayarlar ekranından tüm verilerin tek tıkla silinebilmesi belgelendi.
- [x] **Aktarım Şifrelemesi:** Tüm sunucu trafiği TLS 1.3 / HTTPS ile şifreli.

### B. Kapalı Test Şartı (14 Gün / 12+ Kullanıcı)
- [x] **Test Takvimi:** 14 günlük test planı ve faz senaryoları hazırlandı (`/docs/store/PLAY_CLOSED_TEST_PLAN.md`).
- [x] **Test Kullanıcı Listesi:** 14 aktif cihaz ve kullanıcı tanımlandı.
- [x] **Geri Bildirim Kanalı:** Google Play kapalı test geri bildirim mekanizması ve destek e-postası hazır.

### C. Teknik ve Uygulama Kalitesi (Core App Quality)
- [x] **Hedef SDK (Target API Level):** Android 14 (API 34) hedefliyor; minimum SDK Android 7.0 (API 24).
- [x] **Paket Boyutu (App Bundle / APK):** Boyut bütçesi < 45 MB altında.
- [x] **Bellek Kullanımı:** Tepe RAM tüketimi < 250 MB bütçesi altında.
- [x] **Arka Plan ve Pil:** Arka planda gereksiz kamera veya işlemci uyandırması yapılmıyor.
- [x] **Adaptive Launcher Icon:** `ic_launcher` vektörel foreground ve background hazır (`assets/icons/app_icon_*.svg`).
- [x] **Özellik Grafiği (Feature Graphic):** 1024x500 şablonu ve tasarım parametreleri tanımlandı.

---

## 3. Kod Tabanı ve CI/CD Doğrulama Kontrol Listesi

- [x] **Statik Kod Analizi:** `flutter analyze --fatal-infos` → 0 uyarı, 0 hata.
- [x] **Dart Paketleri Testleri:** `packages/spine_clustering` ve `spike` → 100% yeşil.
- [x] **Flutter Uygulama Testleri:** 118 birim ve widget testinin tamamı yeşil (`flutter test`).
- [x] **Regresyon Kapısı:** 20 fotoğraflık sentetik veri seti ve matcher testi (`spike/test/matcher_test.dart`) %100 başarılı.
- [x] **Performans Bütçeleri Scripti:** `scripts/check_performance_budgets.sh` CI'a entegre edildi ve başarıyla geçti.
- [x] **Sıfır Sabit Kodlanmış Kullanıcı Metni:** TR (`app_tr.arb`) ve EN (`app_en.arb`) üzerinden tüm metinler `AppLocalizations` altında.

---

**Onaylayan:** Kutluhan Gül  
**Sonuç:** Mağaza İnceleme Kontrol Listesi Eksiksiz Tamamlandı ve İmzalandı.
