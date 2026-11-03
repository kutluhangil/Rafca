/// Data structure representing a shareable shelf / library collection.
class ShareCollectionData {
  const ShareCollectionData({
    required this.title,
    required this.subtitle,
    required this.bookCount,
    required this.spineColors,
    this.categories = const [],
    this.captureDate,
  });

  final String title;
  final String subtitle;
  final int bookCount;
  final List<String> spineColors;
  final List<String> categories;
  final DateTime? captureDate;
}
