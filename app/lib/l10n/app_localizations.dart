import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Uygulama adı
  ///
  /// In tr, this message translates to:
  /// **'Rafça'**
  String get appName;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İPTAL'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'KAYDET'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'SİL'**
  String get delete;

  /// No description provided for @remove.
  ///
  /// In tr, this message translates to:
  /// **'KALDIR'**
  String get remove;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'DÜZENLE'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In tr, this message translates to:
  /// **'Ara...'**
  String get search;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In tr, this message translates to:
  /// **'ONAYLA'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden Dene'**
  String get retry;

  /// No description provided for @unknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmiyor'**
  String get unknown;

  /// No description provided for @notSpecified.
  ///
  /// In tr, this message translates to:
  /// **'Belirtilmemiş'**
  String get notSpecified;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// No description provided for @success.
  ///
  /// In tr, this message translates to:
  /// **'Başarılı'**
  String get success;

  /// No description provided for @libraryTab.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphane'**
  String get libraryTab;

  /// No description provided for @shelvesTab.
  ///
  /// In tr, this message translates to:
  /// **'Raflar'**
  String get shelvesTab;

  /// No description provided for @scanShelf.
  ///
  /// In tr, this message translates to:
  /// **'Raf Tara'**
  String get scanShelf;

  /// No description provided for @designGallery.
  ///
  /// In tr, this message translates to:
  /// **'Tasarım Galerisi'**
  String get designGallery;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @cameraTitle.
  ///
  /// In tr, this message translates to:
  /// **'Raf Tara'**
  String get cameraTitle;

  /// No description provided for @levelCamera.
  ///
  /// In tr, this message translates to:
  /// **'Kamerayı Düz Tutun'**
  String get levelCamera;

  /// No description provided for @cameraLevel.
  ///
  /// In tr, this message translates to:
  /// **'Kamera Düz'**
  String get cameraLevel;

  /// No description provided for @cameraTooTilted.
  ///
  /// In tr, this message translates to:
  /// **'Kamera Çok Eğik'**
  String get cameraTooTilted;

  /// No description provided for @holdSteady.
  ///
  /// In tr, this message translates to:
  /// **'Sabit Tutun'**
  String get holdSteady;

  /// No description provided for @adjustCrop.
  ///
  /// In tr, this message translates to:
  /// **'Kırpımı Ayarla'**
  String get adjustCrop;

  /// No description provided for @dragCorners.
  ///
  /// In tr, this message translates to:
  /// **'Köşeleri raf kenarlarına sürükleyin'**
  String get dragCorners;

  /// No description provided for @scanButton.
  ///
  /// In tr, this message translates to:
  /// **'TARA'**
  String get scanButton;

  /// No description provided for @processing.
  ///
  /// In tr, this message translates to:
  /// **'İşleniyor...'**
  String get processing;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In tr, this message translates to:
  /// **'Kamera İzni Gerekli'**
  String get cameraPermissionRequired;

  /// No description provided for @cameraPermissionDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kitap sırtlarını tarayabilmek için kamera erişimine ihtiyaç var.'**
  String get cameraPermissionDesc;

  /// No description provided for @grantPermission.
  ///
  /// In tr, this message translates to:
  /// **'İzin Ver'**
  String get grantPermission;

  /// No description provided for @processingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Raf Analiz Ediliyor'**
  String get processingTitle;

  /// No description provided for @perspectiveCorrection.
  ///
  /// In tr, this message translates to:
  /// **'Perspektif düzeltiliyor'**
  String get perspectiveCorrection;

  /// No description provided for @runningOcr.
  ///
  /// In tr, this message translates to:
  /// **'Sırt metinleri okunuyor (OCR)'**
  String get runningOcr;

  /// No description provided for @segmentingSpines.
  ///
  /// In tr, this message translates to:
  /// **'Kitap sırtları ayrıştırılıyor'**
  String get segmentingSpines;

  /// No description provided for @matchingCatalog.
  ///
  /// In tr, this message translates to:
  /// **'Katalogla eşleştiriliyor'**
  String get matchingCatalog;

  /// No description provided for @processingComplete.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get processingComplete;

  /// No description provided for @scanResultsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tarama Sonuçları'**
  String get scanResultsTitle;

  /// No description provided for @viewOriginalPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Orijinal Fotoğrafı Göster'**
  String get viewOriginalPhoto;

  /// No description provided for @hideOriginalPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Orijinal Fotoğrafı Gizle'**
  String get hideOriginalPhoto;

  /// No description provided for @matchedGroup.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen Kitaplar'**
  String get matchedGroup;

  /// No description provided for @needsReviewGroup.
  ///
  /// In tr, this message translates to:
  /// **'İnceleme Gerekenler'**
  String get needsReviewGroup;

  /// No description provided for @unrecognizedGroup.
  ///
  /// In tr, this message translates to:
  /// **'Tanınamayanlar'**
  String get unrecognizedGroup;

  /// No description provided for @reviewIssuesButton.
  ///
  /// In tr, this message translates to:
  /// **'{count} SORUNU İNCELE'**
  String reviewIssuesButton(int count);

  /// No description provided for @addMatchedBooksButton.
  ///
  /// In tr, this message translates to:
  /// **'{count} KİTABI EKLE'**
  String addMatchedBooksButton(int count);

  /// No description provided for @reviewSheetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Baskı Düzeltme'**
  String get reviewSheetTitle;

  /// No description provided for @suggestedEditions.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen Baskılar'**
  String get suggestedEditions;

  /// No description provided for @searchManually.
  ///
  /// In tr, this message translates to:
  /// **'Manuel Ara'**
  String get searchManually;

  /// No description provided for @notABook.
  ///
  /// In tr, this message translates to:
  /// **'Kitap Değil'**
  String get notABook;

  /// No description provided for @manualSearchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kitap Ara / Ekle'**
  String get manualSearchTitle;

  /// No description provided for @searchPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Kitap adı, yazar veya ISBN...'**
  String get searchPlaceholder;

  /// No description provided for @customBookTitle.
  ///
  /// In tr, this message translates to:
  /// **'Özel Kitap Girişi'**
  String get customBookTitle;

  /// No description provided for @titleLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kitap Adı'**
  String get titleLabel;

  /// No description provided for @authorLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yazar'**
  String get authorLabel;

  /// No description provided for @publisherLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yayınevi'**
  String get publisherLabel;

  /// No description provided for @yearLabel.
  ///
  /// In tr, this message translates to:
  /// **'Basım Yılı'**
  String get yearLabel;

  /// No description provided for @isbnLabel.
  ///
  /// In tr, this message translates to:
  /// **'ISBN'**
  String get isbnLabel;

  /// No description provided for @saveToLibrary.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphaneye Ekle'**
  String get saveToLibrary;

  /// No description provided for @goodEvening.
  ///
  /// In tr, this message translates to:
  /// **'İyi akşamlar.'**
  String get goodEvening;

  /// No description provided for @libraryQuiet.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphane sessiz.'**
  String get libraryQuiet;

  /// No description provided for @scanFirstShelf.
  ///
  /// In tr, this message translates to:
  /// **'İlk Rafınızı Tarayın'**
  String get scanFirstShelf;

  /// No description provided for @emptyLibraryDesc.
  ///
  /// In tr, this message translates to:
  /// **'Fiziksel kitap sırtlarınızı fotoğraflayarak dijital rafınızı oluşturmaya başlayın.'**
  String get emptyLibraryDesc;

  /// No description provided for @pendingReviewBanner.
  ///
  /// In tr, this message translates to:
  /// **'{count} bekleyen öğe — incele ve düzelt'**
  String pendingReviewBanner(int count);

  /// No description provided for @filterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get filterAll;

  /// No description provided for @filterReading.
  ///
  /// In tr, this message translates to:
  /// **'Okunuyor'**
  String get filterReading;

  /// No description provided for @filterUnread.
  ///
  /// In tr, this message translates to:
  /// **'Okunacak'**
  String get filterUnread;

  /// No description provided for @filterRead.
  ///
  /// In tr, this message translates to:
  /// **'Okundu'**
  String get filterRead;

  /// No description provided for @filterAbandoned.
  ///
  /// In tr, this message translates to:
  /// **'Bırakıldı'**
  String get filterAbandoned;

  /// No description provided for @noResults.
  ///
  /// In tr, this message translates to:
  /// **'Aramanızla eşleşen kitap bulunamadı.'**
  String get noResults;

  /// No description provided for @noSuggestions.
  ///
  /// In tr, this message translates to:
  /// **'Öneri bulunamadı. Lütfen manuel arayın.'**
  String get noSuggestions;

  /// No description provided for @bookCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Kitap'**
  String bookCount(int count);

  /// No description provided for @bookDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kitap Detayı'**
  String get bookDetailTitle;

  /// No description provided for @proofOfCapture.
  ///
  /// In tr, this message translates to:
  /// **'PROOF OF CAPTURE'**
  String get proofOfCapture;

  /// No description provided for @proofOfCaptureDesc.
  ///
  /// In tr, this message translates to:
  /// **'Fiziksel raf taramasından elde edilen sırt kırpımı'**
  String get proofOfCaptureDesc;

  /// No description provided for @readingStatusLabel.
  ///
  /// In tr, this message translates to:
  /// **'Okuma Durumu'**
  String get readingStatusLabel;

  /// No description provided for @shelfLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bulunduğu Raf'**
  String get shelfLabel;

  /// No description provided for @unassignedShelf.
  ///
  /// In tr, this message translates to:
  /// **'Sahipsiz / Genel'**
  String get unassignedShelf;

  /// No description provided for @editDetails.
  ///
  /// In tr, this message translates to:
  /// **'Bilgileri Düzenle'**
  String get editDetails;

  /// No description provided for @removeFromLibrary.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphaneden Kaldır'**
  String get removeFromLibrary;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kitabı Kaldır'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu kitabı kütüphanenizden kaldırmak istediğinizden emin misiniz?'**
  String get deleteConfirmMessage;

  /// No description provided for @shelvesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Raflarım'**
  String get shelvesTitle;

  /// No description provided for @createShelf.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Raf Oluştur'**
  String get createShelf;

  /// No description provided for @shelfNamePlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Raf adı (ör. Klasikler, Bilim Kurgu)...'**
  String get shelfNamePlaceholder;

  /// No description provided for @noShelves.
  ///
  /// In tr, this message translates to:
  /// **'Henüz raf oluşturulmadı.'**
  String get noShelves;

  /// No description provided for @noShelvesDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kitaplarınızı temalarına veya konumlarına göre organize etmek için yeni bir raf ekleyin.'**
  String get noShelvesDesc;

  /// No description provided for @deleteShelfTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rafı Sil'**
  String get deleteShelfTitle;

  /// No description provided for @deleteShelfMessage.
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" rafını silmek istediğinizden emin misiniz? (Raftaki kitaplar silinmez, sahipsiz kalır.)'**
  String deleteShelfMessage(String name);

  /// No description provided for @shareShelf.
  ///
  /// In tr, this message translates to:
  /// **'Rafı Paylaş'**
  String get shareShelf;

  /// No description provided for @shareCollectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyonu Paylaş'**
  String get shareCollectionTitle;

  /// No description provided for @shareShelfTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rafı Paylaş'**
  String get shareShelfTitle;

  /// No description provided for @autumnCollection.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyon'**
  String get autumnCollection;

  /// No description provided for @saveImage.
  ///
  /// In tr, this message translates to:
  /// **'Görseli Kaydet'**
  String get saveImage;

  /// No description provided for @shareStory.
  ///
  /// In tr, this message translates to:
  /// **'Hikaye'**
  String get shareStory;

  /// No description provided for @shareLink.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı'**
  String get shareLink;

  /// No description provided for @shareMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj'**
  String get shareMessage;

  /// No description provided for @imageSaved.
  ///
  /// In tr, this message translates to:
  /// **'Görsel kaydedildi'**
  String get imageSaved;

  /// No description provided for @shareTextSummary.
  ///
  /// In tr, this message translates to:
  /// **'Rafça Kütüphanem: {count} kitap'**
  String shareTextSummary(int count);

  /// No description provided for @capturedDate.
  ///
  /// In tr, this message translates to:
  /// **'{month} {year} TARİHİNDE YAKALANDI'**
  String capturedDate(String month, String year);

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @appearanceSection.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get appearanceSection;

  /// No description provided for @themeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get themeLabel;

  /// No description provided for @themeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Gece (Dark)'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In tr, this message translates to:
  /// **'Gündüz (Light)'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Teması'**
  String get themeSystem;

  /// No description provided for @languageSection.
  ///
  /// In tr, this message translates to:
  /// **'Dil / Language'**
  String get languageSection;

  /// No description provided for @languageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Dili'**
  String get languageLabel;

  /// No description provided for @langTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get langTurkish;

  /// No description provided for @langEnglish.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Varsayılanı'**
  String get langSystem;

  /// No description provided for @syncSection.
  ///
  /// In tr, this message translates to:
  /// **'Bulut ve Yedekleme'**
  String get syncSection;

  /// No description provided for @cloudSync.
  ///
  /// In tr, this message translates to:
  /// **'Bulut Senkronizasyonu'**
  String get cloudSync;

  /// No description provided for @cloudSyncSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikleri şifreli Supabase bulutuna yedekle'**
  String get cloudSyncSubtitle;

  /// No description provided for @dataSection.
  ///
  /// In tr, this message translates to:
  /// **'Veri Yönetimi'**
  String get dataSection;

  /// No description provided for @exportCsv.
  ///
  /// In tr, this message translates to:
  /// **'CSV Olarak Dışa Aktar'**
  String get exportCsv;

  /// No description provided for @exportCsvSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kütüphanenizi elektronik tablo formatında indirin'**
  String get exportCsvSubtitle;

  /// No description provided for @exportJson.
  ///
  /// In tr, this message translates to:
  /// **'JSON Olarak Dışa Aktar'**
  String get exportJson;

  /// No description provided for @exportJsonSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Geliştiriciler ve yedekleme için tam veri dökümü'**
  String get exportJsonSubtitle;

  /// No description provided for @clearLibrary.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphaneyi Sıfırla'**
  String get clearLibrary;

  /// No description provided for @clearLibrarySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kitapları, rafları ve taramaları yerel cihazdan sil'**
  String get clearLibrarySubtitle;

  /// No description provided for @clearLibraryConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphaneyi Sıfırla?'**
  String get clearLibraryConfirmTitle;

  /// No description provided for @clearLibraryConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem tüm yerel verilerinizi kalıcı olarak silecektir. Bu işlem geri alınamaz!'**
  String get clearLibraryConfirmMessage;

  /// No description provided for @libraryCleared.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphane temizlendi.'**
  String get libraryCleared;

  /// No description provided for @exportSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Veriler dışa aktarıldı.'**
  String get exportSuccess;

  /// No description provided for @aboutSection.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında & Gizlilik'**
  String get aboutSection;

  /// No description provided for @appVersion.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm'**
  String get appVersion;

  /// No description provided for @privacyStatement.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Sözleşmesi'**
  String get privacyStatement;

  /// No description provided for @privacyContent.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflar ve sırt kırpımları yalnızca cihazınızda saklanır. Sunucuya yalnızca OCR ile okunan düz metin gönderilir — o da yalnızca eşleştirme için.'**
  String get privacyContent;

  /// No description provided for @nocturnalArchivist.
  ///
  /// In tr, this message translates to:
  /// **'Nocturnal Archivist Tasarım Sistemi'**
  String get nocturnalArchivist;

  /// No description provided for @filterOnLoan.
  ///
  /// In tr, this message translates to:
  /// **'Ödünçtekiler'**
  String get filterOnLoan;

  /// No description provided for @sortBy.
  ///
  /// In tr, this message translates to:
  /// **'Sırala'**
  String get sortBy;

  /// No description provided for @sortShelfPosition.
  ///
  /// In tr, this message translates to:
  /// **'Fiziksel Raf Sırası'**
  String get sortShelfPosition;

  /// No description provided for @sortAddedDate.
  ///
  /// In tr, this message translates to:
  /// **'Eklenme Tarihi (Yeni)'**
  String get sortAddedDate;

  /// No description provided for @sortTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kitap Başlığı (A-Z)'**
  String get sortTitle;

  /// No description provided for @sortAuthor.
  ///
  /// In tr, this message translates to:
  /// **'Yazar (A-Z)'**
  String get sortAuthor;

  /// No description provided for @shelfPositionBadge.
  ///
  /// In tr, this message translates to:
  /// **'Raf Sırası #{position}'**
  String shelfPositionBadge(int position);

  /// No description provided for @loanSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'ÖDÜNÇ TAKİPÇİSİ'**
  String get loanSectionTitle;

  /// No description provided for @loanBook.
  ///
  /// In tr, this message translates to:
  /// **'Ödünç Ver'**
  String get loanBook;

  /// No description provided for @returnBook.
  ///
  /// In tr, this message translates to:
  /// **'İade Al'**
  String get returnBook;

  /// No description provided for @loanStatusActive.
  ///
  /// In tr, this message translates to:
  /// **'Ödünç Verildi'**
  String get loanStatusActive;

  /// No description provided for @loanStatusAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphanede Mevcut'**
  String get loanStatusAvailable;

  /// No description provided for @borrowerName.
  ///
  /// In tr, this message translates to:
  /// **'Ödünç Alan Kişi'**
  String get borrowerName;

  /// No description provided for @borrowerNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Ahmet Yılmaz'**
  String get borrowerNameHint;

  /// No description provided for @borrowerContact.
  ///
  /// In tr, this message translates to:
  /// **'İletişim (Telefon / E-posta)'**
  String get borrowerContact;

  /// No description provided for @borrowerContactHint.
  ///
  /// In tr, this message translates to:
  /// **'İsteğe bağlı'**
  String get borrowerContactHint;

  /// No description provided for @loanDueDate.
  ///
  /// In tr, this message translates to:
  /// **'Beklenen İade Tarihi'**
  String get loanDueDate;

  /// No description provided for @loanNotes.
  ///
  /// In tr, this message translates to:
  /// **'Notlar'**
  String get loanNotes;

  /// No description provided for @loanNotesHint.
  ///
  /// In tr, this message translates to:
  /// **'İsteğe bağlı not...'**
  String get loanNotesHint;

  /// No description provided for @loanSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kitap ödünç verildi olarak kaydedildi.'**
  String get loanSuccess;

  /// No description provided for @returnSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kitap kütüphaneye iade alındı.'**
  String get returnSuccess;

  /// No description provided for @loanDate.
  ///
  /// In tr, this message translates to:
  /// **'Veriliş Tarihi'**
  String get loanDate;

  /// No description provided for @borrowerNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen ödünç alan kişinin adını girin.'**
  String get borrowerNameRequired;

  /// No description provided for @archivistWrappedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Arşiv Özeti'**
  String get archivistWrappedTitle;

  /// No description provided for @shelfMetersEstimate.
  ///
  /// In tr, this message translates to:
  /// **'{meters} METRE FİZİKSEL RAF'**
  String shelfMetersEstimate(double meters);

  /// No description provided for @colorHarmonyTitle.
  ///
  /// In tr, this message translates to:
  /// **'RENK SPEKTRUMU & AURA'**
  String get colorHarmonyTitle;

  /// No description provided for @dominantPalette.
  ///
  /// In tr, this message translates to:
  /// **'Baskın Karakter'**
  String get dominantPalette;

  /// No description provided for @topAuthorLabel.
  ///
  /// In tr, this message translates to:
  /// **'Baş Yazar: '**
  String get topAuthorLabel;

  /// No description provided for @topPublisherLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yayınevi: '**
  String get topPublisherLabel;

  /// No description provided for @archetypeGrandArchivist.
  ///
  /// In tr, this message translates to:
  /// **'Büyük Arşiv Muhafızı'**
  String get archetypeGrandArchivist;

  /// No description provided for @archetypeDevotedReader.
  ///
  /// In tr, this message translates to:
  /// **'Edebi Gezgin'**
  String get archetypeDevotedReader;

  /// No description provided for @archetypePassionateCurator.
  ///
  /// In tr, this message translates to:
  /// **'Tutkulu Küratör'**
  String get archetypePassionateCurator;

  /// No description provided for @archetypeNocturnalSeeker.
  ///
  /// In tr, this message translates to:
  /// **'Gece Arşivcisi'**
  String get archetypeNocturnalSeeker;

  /// No description provided for @readCountLabel.
  ///
  /// In tr, this message translates to:
  /// **'OKUNDU'**
  String get readCountLabel;

  /// No description provided for @authorsLabel.
  ///
  /// In tr, this message translates to:
  /// **'YAZAR'**
  String get authorsLabel;

  /// No description provided for @onLoanStatLabel.
  ///
  /// In tr, this message translates to:
  /// **'ÖDÜNÇTE'**
  String get onLoanStatLabel;

  /// No description provided for @shareImage.
  ///
  /// In tr, this message translates to:
  /// **'Görseli Paylaş'**
  String get shareImage;

  /// No description provided for @shareText.
  ///
  /// In tr, this message translates to:
  /// **'Metin Paylaş'**
  String get shareText;

  /// No description provided for @copyText.
  ///
  /// In tr, this message translates to:
  /// **'Metni Kopyala'**
  String get copyText;

  /// No description provided for @exporting.
  ///
  /// In tr, this message translates to:
  /// **'Dışa Aktarılıyor...'**
  String get exporting;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
