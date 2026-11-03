// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Rafça';

  @override
  String get cancel => 'İPTAL';

  @override
  String get save => 'KAYDET';

  @override
  String get delete => 'SİL';

  @override
  String get remove => 'KALDIR';

  @override
  String get edit => 'DÜZENLE';

  @override
  String get search => 'Ara...';

  @override
  String get close => 'Kapat';

  @override
  String get confirm => 'ONAYLA';

  @override
  String get retry => 'Yeniden Dene';

  @override
  String get unknown => 'Bilinmiyor';

  @override
  String get notSpecified => 'Belirtilmemiş';

  @override
  String get error => 'Hata';

  @override
  String get success => 'Başarılı';

  @override
  String get libraryTab => 'Kütüphane';

  @override
  String get shelvesTab => 'Raflar';

  @override
  String get scanShelf => 'Raf Tara';

  @override
  String get designGallery => 'Tasarım Galerisi';

  @override
  String get settings => 'Ayarlar';

  @override
  String get cameraTitle => 'Raf Tara';

  @override
  String get levelCamera => 'Kamerayı Düz Tutun';

  @override
  String get cameraLevel => 'Kamera Düz';

  @override
  String get cameraTooTilted => 'Kamera Çok Eğik';

  @override
  String get holdSteady => 'Sabit Tutun';

  @override
  String get adjustCrop => 'Kırpımı Ayarla';

  @override
  String get dragCorners => 'Köşeleri raf kenarlarına sürükleyin';

  @override
  String get scanButton => 'TARA';

  @override
  String get processing => 'İşleniyor...';

  @override
  String get cameraPermissionRequired => 'Kamera İzni Gerekli';

  @override
  String get cameraPermissionDesc =>
      'Kitap sırtlarını tarayabilmek için kamera erişimine ihtiyaç var.';

  @override
  String get grantPermission => 'İzin Ver';

  @override
  String get processingTitle => 'Raf Analiz Ediliyor';

  @override
  String get perspectiveCorrection => 'Perspektif düzeltiliyor';

  @override
  String get runningOcr => 'Sırt metinleri okunuyor (OCR)';

  @override
  String get segmentingSpines => 'Kitap sırtları ayrıştırılıyor';

  @override
  String get matchingCatalog => 'Katalogla eşleştiriliyor';

  @override
  String get processingComplete => 'Tamamlandı';

  @override
  String get scanResultsTitle => 'Tarama Sonuçları';

  @override
  String get viewOriginalPhoto => 'Orijinal Fotoğrafı Göster';

  @override
  String get hideOriginalPhoto => 'Orijinal Fotoğrafı Gizle';

  @override
  String get matchedGroup => 'Eşleşen Kitaplar';

  @override
  String get needsReviewGroup => 'İnceleme Gerekenler';

  @override
  String get unrecognizedGroup => 'Tanınamayanlar';

  @override
  String reviewIssuesButton(int count) {
    return '$count SORUNU İNCELE';
  }

  @override
  String addMatchedBooksButton(int count) {
    return '$count KİTABI EKLE';
  }

  @override
  String get reviewSheetTitle => 'Baskı Düzeltme';

  @override
  String get suggestedEditions => 'Önerilen Baskılar';

  @override
  String get searchManually => 'Manuel Ara';

  @override
  String get notABook => 'Kitap Değil';

  @override
  String get manualSearchTitle => 'Kitap Ara / Ekle';

  @override
  String get searchPlaceholder => 'Kitap adı, yazar veya ISBN...';

  @override
  String get customBookTitle => 'Özel Kitap Girişi';

  @override
  String get titleLabel => 'Kitap Adı';

  @override
  String get authorLabel => 'Yazar';

  @override
  String get publisherLabel => 'Yayınevi';

  @override
  String get yearLabel => 'Basım Yılı';

  @override
  String get isbnLabel => 'ISBN';

  @override
  String get saveToLibrary => 'Kütüphaneye Ekle';

  @override
  String get goodEvening => 'İyi akşamlar.';

  @override
  String get libraryQuiet => 'Kütüphane sessiz.';

  @override
  String get scanFirstShelf => 'İlk Rafınızı Tarayın';

  @override
  String get emptyLibraryDesc =>
      'Fiziksel kitap sırtlarınızı fotoğraflayarak dijital rafınızı oluşturmaya başlayın.';

  @override
  String pendingReviewBanner(int count) {
    return '$count bekleyen öğe — incele ve düzelt';
  }

  @override
  String get filterAll => 'Tümü';

  @override
  String get filterReading => 'Okunuyor';

  @override
  String get filterUnread => 'Okunacak';

  @override
  String get filterRead => 'Okundu';

  @override
  String get filterAbandoned => 'Bırakıldı';

  @override
  String get noResults => 'Aramanızla eşleşen kitap bulunamadı.';

  @override
  String get noSuggestions => 'Öneri bulunamadı. Lütfen manuel arayın.';

  @override
  String bookCount(int count) {
    return '$count Kitap';
  }

  @override
  String get bookDetailTitle => 'Kitap Detayı';

  @override
  String get proofOfCapture => 'PROOF OF CAPTURE';

  @override
  String get proofOfCaptureDesc =>
      'Fiziksel raf taramasından elde edilen sırt kırpımı';

  @override
  String get readingStatusLabel => 'Okuma Durumu';

  @override
  String get shelfLabel => 'Bulunduğu Raf';

  @override
  String get unassignedShelf => 'Sahipsiz / Genel';

  @override
  String get editDetails => 'Bilgileri Düzenle';

  @override
  String get removeFromLibrary => 'Kütüphaneden Kaldır';

  @override
  String get deleteConfirmTitle => 'Kitabı Kaldır';

  @override
  String get deleteConfirmMessage =>
      'Bu kitabı kütüphanenizden kaldırmak istediğinizden emin misiniz?';

  @override
  String get shelvesTitle => 'Raflarım';

  @override
  String get createShelf => 'Yeni Raf Oluştur';

  @override
  String get shelfNamePlaceholder => 'Raf adı (ör. Klasikler, Bilim Kurgu)...';

  @override
  String get noShelves => 'Henüz raf oluşturulmadı.';

  @override
  String get noShelvesDesc =>
      'Kitaplarınızı temalarına veya konumlarına göre organize etmek için yeni bir raf ekleyin.';

  @override
  String get deleteShelfTitle => 'Rafı Sil';

  @override
  String deleteShelfMessage(String name) {
    return '\"$name\" rafını silmek istediğinizden emin misiniz? (Raftaki kitaplar silinmez, sahipsiz kalır.)';
  }

  @override
  String get shareShelf => 'Rafı Paylaş';

  @override
  String get shareCollectionTitle => 'Koleksiyonu Paylaş';

  @override
  String get shareShelfTitle => 'Rafı Paylaş';

  @override
  String get autumnCollection => 'Koleksiyon';

  @override
  String get saveImage => 'Görseli Kaydet';

  @override
  String get shareStory => 'Hikaye';

  @override
  String get shareLink => 'Bağlantı';

  @override
  String get shareMessage => 'Mesaj';

  @override
  String get imageSaved => 'Görsel kaydedildi';

  @override
  String shareTextSummary(int count) {
    return 'Rafça Kütüphanem: $count kitap';
  }

  @override
  String capturedDate(String month, String year) {
    return '$month $year TARİHİNDE YAKALANDI';
  }

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get appearanceSection => 'Görünüm';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeDark => 'Koyu Gece (Dark)';

  @override
  String get themeLight => 'Gündüz (Light)';

  @override
  String get themeSystem => 'Sistem Teması';

  @override
  String get languageSection => 'Dil / Language';

  @override
  String get languageLabel => 'Uygulama Dili';

  @override
  String get langTurkish => 'Türkçe';

  @override
  String get langEnglish => 'English';

  @override
  String get langSystem => 'Sistem Varsayılanı';

  @override
  String get syncSection => 'Bulut ve Yedekleme';

  @override
  String get cloudSync => 'Bulut Senkronizasyonu';

  @override
  String get cloudSyncSubtitle =>
      'Değişiklikleri şifreli Supabase bulutuna yedekle';

  @override
  String get dataSection => 'Veri Yönetimi';

  @override
  String get exportCsv => 'CSV Olarak Dışa Aktar';

  @override
  String get exportCsvSubtitle =>
      'Tüm kütüphanenizi elektronik tablo formatında indirin';

  @override
  String get exportJson => 'JSON Olarak Dışa Aktar';

  @override
  String get exportJsonSubtitle =>
      'Geliştiriciler ve yedekleme için tam veri dökümü';

  @override
  String get clearLibrary => 'Kütüphaneyi Sıfırla';

  @override
  String get clearLibrarySubtitle =>
      'Tüm kitapları, rafları ve taramaları yerel cihazdan sil';

  @override
  String get clearLibraryConfirmTitle => 'Kütüphaneyi Sıfırla?';

  @override
  String get clearLibraryConfirmMessage =>
      'Bu işlem tüm yerel verilerinizi kalıcı olarak silecektir. Bu işlem geri alınamaz!';

  @override
  String get libraryCleared => 'Kütüphane temizlendi.';

  @override
  String get exportSuccess => 'Veriler dışa aktarıldı.';

  @override
  String get aboutSection => 'Hakkında & Gizlilik';

  @override
  String get appVersion => 'Sürüm';

  @override
  String get privacyStatement => 'Gizlilik Sözleşmesi';

  @override
  String get privacyContent =>
      'Fotoğraflar ve sırt kırpımları yalnızca cihazınızda saklanır. Sunucuya yalnızca OCR ile okunan düz metin gönderilir — o da yalnızca eşleştirme için.';

  @override
  String get nocturnalArchivist => 'Nocturnal Archivist Tasarım Sistemi';

  @override
  String get filterOnLoan => 'Ödünçtekiler';

  @override
  String get sortBy => 'Sırala';

  @override
  String get sortShelfPosition => 'Fiziksel Raf Sırası';

  @override
  String get sortAddedDate => 'Eklenme Tarihi (Yeni)';

  @override
  String get sortTitle => 'Kitap Başlığı (A-Z)';

  @override
  String get sortAuthor => 'Yazar (A-Z)';

  @override
  String shelfPositionBadge(int position) {
    return 'Raf Sırası #$position';
  }

  @override
  String get loanSectionTitle => 'ÖDÜNÇ TAKİPÇİSİ';

  @override
  String get loanBook => 'Ödünç Ver';

  @override
  String get returnBook => 'İade Al';

  @override
  String get loanStatusActive => 'Ödünç Verildi';

  @override
  String get loanStatusAvailable => 'Kütüphanede Mevcut';

  @override
  String get borrowerName => 'Ödünç Alan Kişi';

  @override
  String get borrowerNameHint => 'Örn: Ahmet Yılmaz';

  @override
  String get borrowerContact => 'İletişim (Telefon / E-posta)';

  @override
  String get borrowerContactHint => 'İsteğe bağlı';

  @override
  String get loanDueDate => 'Beklenen İade Tarihi';

  @override
  String get loanNotes => 'Notlar';

  @override
  String get loanNotesHint => 'İsteğe bağlı not...';

  @override
  String get loanSuccess => 'Kitap ödünç verildi olarak kaydedildi.';

  @override
  String get returnSuccess => 'Kitap kütüphaneye iade alındı.';

  @override
  String get loanDate => 'Veriliş Tarihi';

  @override
  String get borrowerNameRequired => 'Lütfen ödünç alan kişinin adını girin.';
}
