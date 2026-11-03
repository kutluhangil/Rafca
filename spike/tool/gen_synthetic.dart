// Synthetic shelf image generator for Rafça Faz 0 spike.
//
// Produces 20 PNG files under spike/dataset/ — one per annotated shelf photo
// in ground_truth.json. Each image is 3000×800 px with a black background and
// white vertical text simulating book spines. The images contain only ASCII
// and simple Latin characters that the bitmap font can render; Türkçe
// characters (İ, Ş, Ğ, Ü, Ç, Ö, ı) that fall outside the font charset are
// transliterated to their ASCII equivalents.
//
// Usage (run from spike/ directory):
//   dart run tool/gen_synthetic.dart
//
// Output: dataset/shelf_01.jpg … dataset/shelf_20.jpg
// The files are named .jpg for ground_truth compatibility but saved as PNG.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

// ---------------------------------------------------------------------------
// Book data per group

// Each entry: (title, author)
const _goodLight = [
  // shelf_01
  [
    ('Suc ve Ceza', 'Dostoyevski'),
    ('1984', 'Orwell'),
    ('Dune', 'Herbert'),
    ('Simyaci', 'Coelho'),
    ('Kucuk Prens', 'Saint-Exupery'),
  ],
  // shelf_02
  [
    ('Cesur Yeni Dunya', 'Huxley'),
    ('Hayvan Cercevesi', 'Orwell'),
    ('Fahrenheit 451', 'Bradbury'),
    ('Siddhartha', 'Hesse'),
  ],
  // shelf_03
  [
    ('Don Kisot', 'Cervantes'),
    ('Ulysses', 'Joyce'),
    ('Gurur ve Ongoru', 'Austen'),
    ('Jane Eyre', 'Bronte'),
    ('Vadideki Zambak', 'Balzac'),
    ('Buyuk Umutlar', 'Dickens'),
  ],
  // shelf_04
  [
    ('Savas ve Baris', 'Tolstoy'),
    ('Karamazov Kardesler', 'Dostoyevski'),
    ('Idiot', 'Dostoyevski'),
    ('Anna Karenina', 'Tolstoy'),
    ('Dirilis', 'Tolstoy'),
  ],
  // shelf_05
  [
    ('Dava', 'Kafka'),
    ('Donusun', 'Kafka'),
    ('Sinyal ve Gurultu', 'Silver'),
    ('Sapiens', 'Harari'),
    ('Homo Deus', 'Harari'),
    ('21 Ders', 'Harari'),
  ],
  // shelf_06
  [
    ('Sherlock Holmes', 'Doyle'),
    ('Yabanci', 'Camus'),
    ('Bulanti', 'Sartre'),
    ('Varlik ve Hiclik', 'Sartre'),
  ],
];

const _warmAngled = [
  // shelf_07
  [
    ('Ici Bizi Bitiren', 'Sabahattin Ali'),
    ('Kuyucakli Yusuf', 'Sabahattin Ali'),
    ('Masum', 'Pamuk'),
    ('Kara Kitap', 'Pamuk'),
  ],
  // shelf_08
  [
    ('Benim Adim Kirmizi', 'Pamuk'),
    ('Kar', 'Pamuk'),
    ('Sessiz Ev', 'Pamuk'),
    ('Yeni Hayat', 'Pamuk'),
    ('Cevdet Bey', 'Pamuk'),
  ],
  // shelf_09
  [
    ('Tutunamayanlar', 'Atay'),
    ('Tehlikeli Oyunlar', 'Atay'),
    ('Gunluk', 'Atay'),
    ('Bir Bilim Adaminin Romani', 'Atay'),
  ],
  // shelf_10
  [
    ('Mavi ve Siyah', 'Halit Ziya'),
    ('Kirac Insan', 'Kemal Tahir'),
    ('Devlet Ana', 'Kemal Tahir'),
    ('Yorgun Savasci', 'Kemal Tahir'),
    ('Esir Sehrin Insanlari', 'Kemal Tahir'),
  ],
  // shelf_11
  [
    ('Ince Memed', 'Yashar Kemal'),
    ('Ortadirek', 'Yashar Kemal'),
    ('Demirciler Carisi Cinayeti', 'Yashar Kemal'),
    ('Yilan Olduran', 'Yashar Kemal'),
  ],
  // shelf_12
  [
    ('Ciragan Sarayi', 'Nedim Gursel'),
    ('Bogazkesen', 'Nedim Gursel'),
    ('Gece Yarisi Express', 'Hayes'),
    ('Into the Wild', 'Krakauer'),
    ('Vahsi Cagri', 'London'),
  ],
];

const _thinSpines = [
  // shelf_13 — thin / pocket books
  [
    ('Demir', 'Atwood'),
    ('Mavi Sakalli', 'Pullman'),
    ('Nehir', 'Coetzee'),
    ('Ziyaret', 'Durrenmatt'),
    ('Sis', 'Kafka'),
    ('Ceza Kolonisi', 'Kafka'),
    ('Kumaci Bebek', 'Simenon'),
  ],
  // shelf_14
  [
    ('Troya Savasi', 'Homer'),
    ('Odisseia', 'Homer'),
    ('Aeneas', 'Vergilius'),
    ('Meditasyonlar', 'Aurelius'),
    ('Zerdust', 'Nietzsche'),
  ],
  // shelf_15
  [
    ('Bir Delinin Gunlugu', 'Gogol'),
    ('Palto', 'Gogol'),
    ('Burun', 'Gogol'),
    ('Beyaz Geceler', 'Dostoyevski'),
    ('Kumarbaz', 'Dostoyevski'),
    ('Memurun Olumu', 'Chekhov'),
    ('Golge', 'Andersen'),
  ],
  // shelf_16
  [
    ('Genova Kisi', 'Saramago'),
    ('Kor', 'Saramago'),
    ('Ada', 'Saramago'),
    ('Tum Adlar', 'Saramago'),
  ],
];

const _turkish = [
  // shelf_17 — Turkish heavy
  [
    ('Nutuk', 'Ataturk'),
    ('Insan Manzaralari', 'Nazim Hikmet'),
    ('Memleketimden Insan Manzaralari', 'Nazim Hikmet'),
    ('Yesil Gece', 'Resat Nuri'),
    ('Calikusu', 'Resat Nuri'),
  ],
  // shelf_18
  [
    ('Cocuklugu Olmayan Cocuk', 'Atay'),
    ('Anarsin Kardesler', 'Adalet Agaoglu'),
    ('Bir Dusunu Gormek', 'Adalet Agaoglu'),
    ('Olmeye Yatmak', 'Adalet Agaoglu'),
    ('Fikrimin Ince Gulu', 'Adalet Agaoglu'),
    ('Cok Uzak Mecnun Colu', 'Adalet Agaoglu'),
  ],
  // shelf_19
  [
    ('Yedi Kapili Babil', 'Iskender Pala'),
    ('Katre-i Matem', 'Iskender Pala'),
    ('Fatih Harbiye', 'Sezai Karakoc'),
    ('Mona Rosa', 'Sezai Karakoc'),
    ('Hicr', 'Arif Ay'),
  ],
  // shelf_20
  [
    ('Gece Yolculugu', 'Attila Ilhan'),
    ('Ben Sana Mecburum', 'Attila Ilhan'),
    ('Alacakaranlik Yolculari', 'Necip Fazil'),
    ('Buyuk Dogu', 'Necip Fazil'),
    ('Sacak', 'Necip Fazil'),
    ('Esir Sehrin Esiri', 'Necip Fazil'),
  ],
];

// ---------------------------------------------------------------------------

final _allGroups = [
  ('good_light', _goodLight, 'shelf_01.jpg'),
  ('warm_angled', _warmAngled, 'shelf_07.jpg'),
  ('thin_spines', _thinSpines, 'shelf_13.jpg'),
  ('turkish', _turkish, 'shelf_17.jpg'),
];

const _imageWidth = 3000;
const _imageHeight = 800;

/// Transliterate Turkish chars outside the bitmap font charset.
String _ascii(String s) => s
    .replaceAll('İ', 'I')
    .replaceAll('Ş', 'S')
    .replaceAll('Ğ', 'G')
    .replaceAll('Ü', 'U')
    .replaceAll('Ç', 'C')
    .replaceAll('Ö', 'O')
    .replaceAll('ş', 's')
    .replaceAll('ğ', 'g')
    .replaceAll('ü', 'u')
    .replaceAll('ç', 'c')
    .replaceAll('ö', 'o')
    .replaceAll('ı', 'i')
    .replaceAll('â', 'a')
    .replaceAll('î', 'i')
    .replaceAll('û', 'u')
    .replaceAll('é', 'e')
    .replaceAll(''', "'")
    .replaceAll(''', "'");

// Palette of background colours — slightly varied so the groups look distinct.
final _bgColors = [
  img.ColorRgb8(10, 10, 10), // good_light — nearly black
  img.ColorRgb8(25, 18, 8), // warm_angled — warm dark
  img.ColorRgb8(8, 8, 12), // thin_spines — cool dark
  img.ColorRgb8(12, 10, 8), // turkish — dark brown
];

// Spine background colours per group (subtle variation to look like real spines).
final _rng = Random(42);

img.ColorRgb8 _spineColor(int groupIdx) {
  final base = [
    [40, 38, 35],
    [55, 42, 28],
    [32, 32, 42],
    [48, 38, 30],
  ][groupIdx];
  final v = _rng.nextInt(30) - 15;
  return img.ColorRgb8(
    (base[0] + v).clamp(0, 255),
    (base[1] + v).clamp(0, 255),
    (base[2] + v).clamp(0, 255),
  );
}

/// Rotate an image 90° clockwise.
img.Image _rotateCW90(img.Image src) {
  final dst = img.Image(width: src.height, height: src.width);
  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      dst.setPixel(src.height - 1 - y, x, src.getPixel(x, y));
    }
  }
  return dst;
}

/// Draw a single book spine as a tall narrow strip with vertical text.
/// [x] is the left edge of the strip, [spineWidth] its pixel width.
void _drawSpine(
  img.Image canvas,
  int x,
  int spineWidth,
  String title,
  String author,
  int groupIdx,
) {
  const spineTop = 40;
  const spineBottom = 760;
  const spineHeight = spineBottom - spineTop;

  // Spine background.
  final bgColor = _spineColor(groupIdx);
  img.fillRect(
    canvas,
    x1: x,
    y1: spineTop,
    x2: x + spineWidth - 1,
    y2: spineBottom,
    color: bgColor,
  );

  // Hairline border.
  img.drawRect(
    canvas,
    x1: x,
    y1: spineTop,
    x2: x + spineWidth - 1,
    y2: spineBottom,
    color: img.ColorRgb8(80, 72, 60),
  );

  // --- Render text vertically ---
  // Strategy: draw onto a temporary horizontal strip, then rotate 90° CW and
  // blit onto the canvas. This gives clean text without per-pixel rotation.
  const fontSize = 24; // use arial24 font
  final font = img.arial24;
  final textColor = img.ColorRgb8(230, 220, 205);

  // Temporary strip: height = spineWidth, width = spineHeight
  final strip = img.Image(width: spineHeight, height: spineWidth);
  img.fill(strip, color: bgColor);

  final titleStr = _ascii(title.toUpperCase());
  final authorStr = _ascii(author);

  // Draw title centred vertically in the strip.
  const titleY = 4;
  img.drawString(
    strip,
    titleStr,
    font: font,
    x: 8,
    y: titleY,
    color: textColor,
  );

  // Draw author below title.
  final authorY = titleY + fontSize + 6;
  img.drawString(
    strip,
    authorStr,
    font: font,
    x: 8,
    y: authorY,
    color: img.ColorRgb8(170, 160, 148),
  );

  // Rotate 90° clockwise: the strip becomes a vertical column.
  final rotated = _rotateCW90(strip);

  // Blit onto canvas at (x, spineTop).
  img.compositeImage(
    canvas,
    rotated,
    dstX: x,
    dstY: spineTop,
    blend: img.BlendMode.alpha,
  );
}

/// Generate one shelf image for the given book list.
img.Image _buildShelfImage(
  List<(String, String)> books,
  int groupIdx,
) {
  final canvas = img.Image(width: _imageWidth, height: _imageHeight);
  img.fill(canvas, color: _bgColors[groupIdx]);

  final n = books.length;
  // Each spine gets an equal share of the width, with small gaps.
  const gap = 6;
  final totalGap = gap * (n + 1);
  final spineWidth = (_imageWidth - totalGap) ~/ n;

  for (var i = 0; i < n; i++) {
    final x = gap + i * (spineWidth + gap);
    final (title, author) = books[i];
    _drawSpine(canvas, x, spineWidth, title, author, groupIdx);
  }

  return canvas;
}

// ---------------------------------------------------------------------------
// Ground truth JSON builder

Map<String, dynamic> _buildGroundTruth() {
  final photos = <Map<String, dynamic>>[];

  final groupData = [
    ('good_light', _goodLight, 1),
    ('warm_angled', _warmAngled, 7),
    ('thin_spines', _thinSpines, 13),
    ('turkish', _turkish, 17),
  ];

  for (final (groupId, shelves, firstNum) in groupData) {
    for (var s = 0; s < shelves.length; s++) {
      final fileNum = firstNum + s;
      final fileName = 'shelf_${fileNum.toString().padLeft(2, '0')}.jpg';
      final books = shelves[s]
          .map<Map<String, dynamic>>(
            (b) => {
              'title': b.$1,
              'author': b.$2,
              'language': (groupId == 'turkish') ? 'tur' : 'eng',
            },
          )
          .toList();

      photos.add({
        'file': fileName,
        'group': groupId,
        'language_hint': (groupId == 'turkish') ? 'tur' : 'eng',
        'notes': 'Sentetik görüntü — gerçek raf fotoğrafı değil',
        'books': books,
      });
    }
  }

  return {'version': 1, 'photos': photos};
}

// ---------------------------------------------------------------------------

Future<void> main() async {
  final datasetDir = Directory('dataset');
  if (!datasetDir.existsSync()) {
    datasetDir.createSync(recursive: true);
  }

  stdout.writeln('Generating synthetic shelf images …');

  for (var g = 0; g < _allGroups.length; g++) {
    final (groupId, shelves, firstFile) = _allGroups[g];
    final firstNum =
        int.parse(firstFile.replaceAll(RegExp(r'[^0-9]'), '').substring(0, 2));

    for (var s = 0; s < shelves.length; s++) {
      final fileNum = firstNum + s;
      final fileName = 'shelf_${fileNum.toString().padLeft(2, '0')}.jpg';
      final outputPath = '${datasetDir.path}/$fileName';

      stdout.write('  [$groupId] $fileName … ');
      final image = _buildShelfImage(shelves[s], g);
      final pngBytes = img.encodePng(image);
      await File(outputPath).writeAsBytes(pngBytes);
      stdout.writeln('done (${pngBytes.length ~/ 1024} KB)');
    }
  }

  // Write ground_truth.json
  final gtData = _buildGroundTruth();
  final gtJson = const JsonEncoder.withIndent('  ').convert(gtData);
  await File('${datasetDir.path}/ground_truth.json').writeAsString(gtJson);
  stdout.writeln('\nground_truth.json written.');
  stdout.writeln('Done. ${gtData['photos'].length} images generated.');
}
