// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Rafca';

  @override
  String get cancel => 'CANCEL';

  @override
  String get save => 'SAVE';

  @override
  String get delete => 'DELETE';

  @override
  String get remove => 'REMOVE';

  @override
  String get edit => 'EDIT';

  @override
  String get search => 'Search...';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'CONFIRM';

  @override
  String get retry => 'Retry';

  @override
  String get unknown => 'Unknown';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get libraryTab => 'Library';

  @override
  String get shelvesTab => 'Shelves';

  @override
  String get scanShelf => 'Scan Shelf';

  @override
  String get designGallery => 'Design Gallery';

  @override
  String get settings => 'Settings';

  @override
  String get cameraTitle => 'Scan Shelf';

  @override
  String get levelCamera => 'Keep Camera Level';

  @override
  String get cameraLevel => 'Camera Level';

  @override
  String get cameraTooTilted => 'Camera Too Tilted';

  @override
  String get holdSteady => 'Hold Steady';

  @override
  String get adjustCrop => 'Adjust Crop';

  @override
  String get dragCorners => 'Drag corners to match shelf edges';

  @override
  String get scanButton => 'SCAN';

  @override
  String get processing => 'Processing...';

  @override
  String get cameraPermissionRequired => 'Camera Permission Required';

  @override
  String get cameraPermissionDesc =>
      'Camera access is needed to scan book spines.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get processingTitle => 'Analyzing Shelf';

  @override
  String get perspectiveCorrection => 'Correcting perspective';

  @override
  String get runningOcr => 'Reading spine texts (OCR)';

  @override
  String get segmentingSpines => 'Segmenting book spines';

  @override
  String get matchingCatalog => 'Matching against catalog';

  @override
  String get processingComplete => 'Complete';

  @override
  String get scanResultsTitle => 'Scan Results';

  @override
  String get viewOriginalPhoto => 'Show Original Photo';

  @override
  String get hideOriginalPhoto => 'Hide Original Photo';

  @override
  String get matchedGroup => 'Matched Books';

  @override
  String get needsReviewGroup => 'Needs Review';

  @override
  String get unrecognizedGroup => 'Unrecognized';

  @override
  String reviewIssuesButton(int count) {
    return 'REVIEW $count ISSUES';
  }

  @override
  String addMatchedBooksButton(int count) {
    return 'ADD $count BOOKS';
  }

  @override
  String get reviewSheetTitle => 'Correct Edition';

  @override
  String get suggestedEditions => 'Suggested Editions';

  @override
  String get searchManually => 'Search Manually';

  @override
  String get notABook => 'Not a book';

  @override
  String get manualSearchTitle => 'Search / Add Book';

  @override
  String get searchPlaceholder => 'Title, author, or ISBN...';

  @override
  String get customBookTitle => 'Manual Book Entry';

  @override
  String get titleLabel => 'Book Title';

  @override
  String get authorLabel => 'Author';

  @override
  String get publisherLabel => 'Publisher';

  @override
  String get yearLabel => 'Publish Year';

  @override
  String get isbnLabel => 'ISBN';

  @override
  String get saveToLibrary => 'Add to Library';

  @override
  String get goodEvening => 'Good evening.';

  @override
  String get libraryQuiet => 'The library is quiet.';

  @override
  String get scanFirstShelf => 'Scan Your First Shelf';

  @override
  String get emptyLibraryDesc =>
      'Start building your digital shelves by photographing your physical book spines.';

  @override
  String pendingReviewBanner(int count) {
    return '$count pending items — review and correct';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterReading => 'Reading';

  @override
  String get filterUnread => 'Want to Read';

  @override
  String get filterRead => 'Read';

  @override
  String get filterAbandoned => 'Abandoned';

  @override
  String get noResults => 'No books match your search.';

  @override
  String get noSuggestions => 'No suggestions found. Please search manually.';

  @override
  String bookCount(int count) {
    return '$count Books';
  }

  @override
  String get bookDetailTitle => 'Book Detail';

  @override
  String get proofOfCapture => 'PROOF OF CAPTURE';

  @override
  String get proofOfCaptureDesc => 'Spine crop from physical shelf capture';

  @override
  String get readingStatusLabel => 'Reading Status';

  @override
  String get shelfLabel => 'Assigned Shelf';

  @override
  String get unassignedShelf => 'Unassigned / General';

  @override
  String get editDetails => 'Edit Details';

  @override
  String get removeFromLibrary => 'Remove from Library';

  @override
  String get deleteConfirmTitle => 'Remove Book';

  @override
  String get deleteConfirmMessage =>
      'Are you sure you want to remove this book from your library?';

  @override
  String get shelvesTitle => 'My Shelves';

  @override
  String get createShelf => 'Create New Shelf';

  @override
  String get shelfNamePlaceholder => 'Shelf name (e.g. Classics, Sci-Fi)...';

  @override
  String get noShelves => 'No shelves created yet.';

  @override
  String get noShelvesDesc =>
      'Create a new shelf to organize your books by theme or location.';

  @override
  String get deleteShelfTitle => 'Delete Shelf';

  @override
  String deleteShelfMessage(String name) {
    return 'Are you sure you want to delete shelf \"$name\"? (Books will not be deleted, they will become unassigned.)';
  }

  @override
  String get shareShelf => 'Share Shelf';

  @override
  String get shareCollectionTitle => 'Share Collection';

  @override
  String get shareShelfTitle => 'Share Shelf';

  @override
  String get autumnCollection => 'Collection';

  @override
  String get saveImage => 'Save Image';

  @override
  String get shareStory => 'Story';

  @override
  String get shareLink => 'Link';

  @override
  String get shareMessage => 'Message';

  @override
  String get imageSaved => 'Image saved';

  @override
  String shareTextSummary(int count) {
    return 'My Rafca Library: $count books';
  }

  @override
  String capturedDate(String month, String year) {
    return 'CAPTURED $month $year';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeDark => 'Dark Night';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System Theme';

  @override
  String get languageSection => 'Language';

  @override
  String get languageLabel => 'App Language';

  @override
  String get langTurkish => 'Turkish';

  @override
  String get langEnglish => 'English';

  @override
  String get langSystem => 'System Default';

  @override
  String get syncSection => 'Cloud & Backup';

  @override
  String get cloudSync => 'Cloud Sync';

  @override
  String get cloudSyncSubtitle => 'Backup changes to encrypted Supabase cloud';

  @override
  String get dataSection => 'Data Management';

  @override
  String get exportCsv => 'Export as CSV';

  @override
  String get exportCsvSubtitle => 'Download your library in spreadsheet format';

  @override
  String get exportJson => 'Export as JSON';

  @override
  String get exportJsonSubtitle => 'Full data dump for developers and backup';

  @override
  String get clearLibrary => 'Reset Library';

  @override
  String get clearLibrarySubtitle =>
      'Delete all books, shelves, and scans from local device';

  @override
  String get clearLibraryConfirmTitle => 'Reset Library?';

  @override
  String get clearLibraryConfirmMessage =>
      'This action will permanently delete all your local data. This cannot be undone!';

  @override
  String get libraryCleared => 'Library cleared.';

  @override
  String get exportSuccess => 'Data exported successfully.';

  @override
  String get aboutSection => 'About & Privacy';

  @override
  String get appVersion => 'Version';

  @override
  String get privacyStatement => 'Privacy Statement';

  @override
  String get privacyContent =>
      'Photos and spine crops stay on your device. Only plain text read by OCR is sent to the server — and only for matching.';

  @override
  String get nocturnalArchivist => 'Nocturnal Archivist Design System';

  @override
  String get filterOnLoan => 'On Loan';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortShelfPosition => 'Physical Shelf Position';

  @override
  String get sortAddedDate => 'Date Added (Newest)';

  @override
  String get sortTitle => 'Title (A-Z)';

  @override
  String get sortAuthor => 'Author (A-Z)';

  @override
  String shelfPositionBadge(int position) {
    return 'Shelf Position #$position';
  }

  @override
  String get loanSectionTitle => 'LENDING TRACKER';

  @override
  String get loanBook => 'Loan Book';

  @override
  String get returnBook => 'Mark as Returned';

  @override
  String get loanStatusActive => 'Currently On Loan';

  @override
  String get loanStatusAvailable => 'Available in Library';

  @override
  String get borrowerName => 'Borrower Name';

  @override
  String get borrowerNameHint => 'e.g. John Doe';

  @override
  String get borrowerContact => 'Contact (Phone / Email)';

  @override
  String get borrowerContactHint => 'Optional';

  @override
  String get loanDueDate => 'Due Date';

  @override
  String get loanNotes => 'Notes';

  @override
  String get loanNotesHint => 'Optional note...';

  @override
  String get loanSuccess => 'Book marked as loaned.';

  @override
  String get returnSuccess => 'Book marked as returned.';

  @override
  String get loanDate => 'Loan Date';

  @override
  String get borrowerNameRequired => 'Please enter borrower name.';

  @override
  String get archivistWrappedTitle => 'Archivist Wrapped';

  @override
  String shelfMetersEstimate(double meters) {
    return '$meters METERS OF SHELVES';
  }

  @override
  String get colorHarmonyTitle => 'COLOR HARMONY & SPECTRUM';

  @override
  String get dominantPalette => 'Dominant Character';

  @override
  String get topAuthorLabel => 'Top Author: ';

  @override
  String get topPublisherLabel => 'Publisher: ';

  @override
  String get archetypeGrandArchivist => 'Grand Archivist';

  @override
  String get archetypeDevotedReader => 'Devoted Reader';

  @override
  String get archetypePassionateCurator => 'Passionate Curator';

  @override
  String get archetypeNocturnalSeeker => 'Nocturnal Archivist';

  @override
  String get readCountLabel => 'READ';

  @override
  String get authorsLabel => 'AUTHORS';

  @override
  String get onLoanStatLabel => 'ON LOAN';

  @override
  String get shareImage => 'Share Image';

  @override
  String get shareText => 'Share Text';

  @override
  String get copyText => 'Copy Text';

  @override
  String get exporting => 'Exporting...';

  @override
  String get scanBarcode => 'Scan Barcode / ISBN';

  @override
  String get barcodeMode => 'BARCODE (ISBN)';

  @override
  String get spineMode => 'SHELF SPINE';

  @override
  String get isbnNotFound => 'No book found for this ISBN.';

  @override
  String get searchingIsbn => 'Looking up ISBN...';

  @override
  String get invalidIsbn => 'Invalid ISBN number.';

  @override
  String get barcodeScanHint =>
      'Center the ISBN barcode on the back cover inside the frame';

  @override
  String get bookFoundFromBarcode => 'Book found via barcode';

  @override
  String get addToLibrary => 'Add to Library';

  @override
  String get arLensMode => 'LIVE AR';

  @override
  String get arLensTitle => 'LIVE SHELF LENS';

  @override
  String get arStatusOwnedRead => 'In Library (Read)';

  @override
  String get arStatusOwnedUnread => 'In Reading List';

  @override
  String get arStatusNotOwned => 'Not in Library';

  @override
  String get arAddToWishlist => 'Add to Wishlist';

  @override
  String get arBookAddedToWishlist => 'book added to reading list';
}
