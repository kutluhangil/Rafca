import 'ground_truth.dart';
import 'matcher.dart';
import 'metrics.dart';

/// The GO/NO-GO gate, SPINE_BLUEPRINT.md 2.2.
enum GateVerdict {
  proceed,
  proceedCorrectionFirst,
  proceedWithVlm,
  stop;

  static GateVerdict forAccuracy(double accuracy) {
    if (accuracy >= 0.70) return GateVerdict.proceed;
    if (accuracy >= 0.50) return GateVerdict.proceedCorrectionFirst;
    if (accuracy >= 0.35) return GateVerdict.proceedWithVlm;
    return GateVerdict.stop;
  }

  String get summary => switch (this) {
        GateVerdict.proceed =>
          'Devam. Plan aynen uygulanır.',
        GateVerdict.proceedCorrectionFirst =>
          'Devam, ama düzeltme akışı (Faz 7) ürünün merkezi kabul edilir; '
              'pazarlama dili "asistan" olur, "otomatik" olmaz.',
        GateVerdict.proceedWithVlm =>
          'VLM katmanı v1\'e alınır, cihaz-içi OCR yalnızca ön eleme olur. '
              'Maliyet modeli ve ücretli plan Faz 1\'den önce tanımlanır.',
        GateVerdict.stop =>
          'DUR. Ürün bu haliyle yapılmaz.',
      };
}

/// One evaluated configuration: a strategy label plus its per-photo metrics.
class RunResult {
  const RunResult({required this.label, required this.photos});

  final String label;
  final List<PhotoMetrics> photos;

  Aggregate get overall => Aggregate.of(photos);
}

/// Renders `spike/report.md`.
String renderReport({
  required List<RunResult> runs,
  required String engineName,
  required String catalogProvenance,
  required GroundTruth truth,
  required DateTime generatedAt,
  int worstCandidatesShown = 25,
}) {
  if (runs.isEmpty) {
    throw ArgumentError.value(runs, 'runs', 'needs at least one run');
  }
  final buffer = StringBuffer();
  final best = runs.reduce(
    (a, b) => b.overall.endToEndAccuracy > a.overall.endToEndAccuracy ? b : a,
  );
  final verdict = GateVerdict.forAccuracy(best.overall.endToEndAccuracy);
  final warnings = truth.coverageWarnings();

  buffer.writeln('# Faz 0 — Doğruluk Spike Raporu');
  buffer.writeln();
  buffer.writeln('> Üretildi: ${generatedAt.toIso8601String()}');
  buffer.writeln('> OCR motoru: `$engineName`');
  buffer.writeln('> Katalog: $catalogProvenance');
  buffer.writeln('> Dataset: ${truth.photos.length} fotoğraf, '
      '${truth.bookCount} kitap');
  buffer.writeln();

  if (warnings.isNotEmpty) {
    buffer.writeln('## ⚠️ Dataset eksik — kapı kapatılamaz');
    buffer.writeln();
    for (final warning in warnings) {
      buffer.writeln('- $warning');
    }
    buffer.writeln();
    buffer.writeln('Aşağıdaki sayılar eldeki fotoğraflar için geçerlidir, '
        'GO/NO-GO kararı için yeterli değildir.');
    buffer.writeln();
  }

  buffer.writeln('## Kapı kararı (SPINE_BLUEPRINT.md §2.2)');
  buffer.writeln();
  buffer.writeln('En iyi yapılandırma: **${best.label}**');
  buffer.writeln();
  buffer.writeln('| Uçtan uca doğruluk | Karar |');
  buffer.writeln('|---|---|');
  buffer.writeln('| ${_pct(best.overall.endToEndAccuracy)} | '
      '${verdict.summary} |');
  buffer.writeln();
  buffer.writeln('> Bu kapıyı Claude Code kendi başına geçemez. '
      'Karar kullanıcıya aittir.');
  buffer.writeln();

  buffer.writeln('## Metrik tanımları');
  buffer.writeln();
  buffer.writeln('Blueprint oranları adlandırıyor ama nasıl hesaplandıklarını '
      'söylemiyor. Kapı bu sayılara bağlı olduğu için tanımlar burada sabit:');
  buffer.writeln();
  buffer.writeln('- **Segmentasyon recall** — bir gerçek kitap, herhangi bir '
      'kümenin ona `$linkThreshold` üstü trigram benzerliğiyle bağlanması '
      'durumunda "segmente edilmiş" sayılır. Bağlama birebirdir: iki kitabı '
      'kapsayan tek küme bir puan alır, iki değil.');
  buffer.writeln('- **Metin yakalama oranı** — gerçek başlığın en az iki '
      'anlamlı kelimesinin okunduğu kitaplar. İki kelimeden kısa başlıklarda '
      '(örn. "1984") hepsi gerekir.');
  buffer.writeln('- **Uçtan uca doğruluk** — doğru katalog kaydının birinci '
      'sırada geldiği ve bandın UNKNOWN olmadığı kitaplar.');
  buffer.writeln('- **Segmentasyon oranı** — kitap başına üretilen küme. '
      '1 üstü aşırı bölme, 1 altı sırtların birleşmesi demektir.');
  buffer.writeln();

  buffer.writeln('## Yapılandırma karşılaştırması');
  buffer.writeln();
  buffer.writeln('| Yapılandırma | Segmentasyon recall | Metin yakalama | '
      'Uçtan uca | Segmentasyon oranı |');
  buffer.writeln('|---|---|---|---|---|');
  for (final run in runs) {
    final a = run.overall;
    buffer.writeln('| ${run.label} | ${_pct(a.segmentationRecall)} | '
        '${_pct(a.textCaptureRate)} | ${_pct(a.endToEndAccuracy)} | '
        '${a.segmentationRatio.toStringAsFixed(2)} |');
  }
  buffer.writeln();

  for (final run in runs) {
    buffer.writeln('## ${run.label}');
    buffer.writeln();
    _writeGroupBreakdown(buffer, run);
    _writeBandDistribution(buffer, run);
    _writePhotoTable(buffer, run);
    _writeWorstCandidates(buffer, run, worstCandidatesShown);
  }

  return buffer.toString();
}

void _writeGroupBreakdown(StringBuffer buffer, RunResult run) {
  buffer.writeln('### Fotoğraf grubuna göre kırılım');
  buffer.writeln();
  buffer.writeln('| Grup | Fotoğraf | Kitap | Segmentasyon | Metin | Uçtan uca |');
  buffer.writeln('|---|---|---|---|---|---|');
  for (final group in PhotoGroup.values) {
    final subset = run.photos.where((p) => p.photo.group == group).toList();
    if (subset.isEmpty) {
      buffer.writeln('| `${group.id}` | 0 | 0 | — | — | — |');
      continue;
    }
    final a = Aggregate.of(subset);
    buffer.writeln('| `${group.id}` | ${a.photoCount} | ${a.bookCount} | '
        '${_pct(a.segmentationRecall)} | ${_pct(a.textCaptureRate)} | '
        '${_pct(a.endToEndAccuracy)} |');
  }
  buffer.writeln();
}

void _writeBandDistribution(StringBuffer buffer, RunResult run) {
  final counts = <Confidence, int>{
    for (final band in Confidence.values) band: 0,
  };
  var total = 0;
  for (final photo in run.photos) {
    for (final outcome in photo.outcomes) {
      counts[outcome.result.confidence] = counts[outcome.result.confidence]! + 1;
      total++;
    }
  }

  buffer.writeln('### Güven bandı dağılımı (§8.4)');
  buffer.writeln();
  buffer.writeln('| Band | Küme | Pay |');
  buffer.writeln('|---|---|---|');
  for (final band in Confidence.values) {
    final count = counts[band]!;
    buffer.writeln('| `${band.name.toUpperCase()}` | $count | '
        '${_pct(total == 0 ? 0 : count / total)} |');
  }
  buffer.writeln();
  buffer.writeln('REVIEW payı, Faz 7 düzeltme akışının kullanıcıya kaç kez '
      'görüneceğidir. Bu oran ürünün asıl yükünü belirler.');
  buffer.writeln();
}

void _writePhotoTable(StringBuffer buffer, RunResult run) {
  buffer.writeln('### Fotoğraf başına');
  buffer.writeln();
  buffer.writeln('| Dosya | Grup | Kitap | Küme | Segmente | Metin | Doğru |');
  buffer.writeln('|---|---|---|---|---|---|---|');
  for (final photo in run.photos) {
    buffer.writeln('| `${photo.photo.file}` | `${photo.photo.group.id}` | '
        '${photo.bookCount} | ${photo.candidateCount} | '
        '${photo.segmentedBooks} | ${photo.textCapturedBooks} | '
        '${photo.correctBooks} |');
  }
  buffer.writeln();
}

void _writeWorstCandidates(StringBuffer buffer, RunResult run, int limit) {
  final failures = [
    for (final photo in run.photos)
      for (final outcome in photo.outcomes)
        if (!outcome.isCorrect) outcome,
  ]..sort((a, b) => a.result.bestScore.compareTo(b.result.bestScore));

  buffer.writeln('### Başarısız kümeler (en düşük skordan)');
  buffer.writeln();
  if (failures.isEmpty) {
    buffer.writeln('Yok — her küme doğru kitaba bağlandı.');
    buffer.writeln();
    return;
  }
  buffer.writeln('Toplam ${failures.length} başarısız küme, ilk '
      '${failures.length < limit ? failures.length : limit} tanesi:');
  buffer.writeln();
  buffer.writeln('| Fotoğraf | Küme | Okunan metin | Beklenen | '
      'Birinci aday | Skor | Band |');
  buffer.writeln('|---|---|---|---|---|---|---|');
  for (final outcome in failures.take(limit)) {
    final expected = outcome.linkedBook?.toString() ?? '(bağlanamadı)';
    final top = outcome.result.best?.entry.toString() ?? '(aday yok)';
    buffer.writeln('| `${outcome.photoFile}` | `${outcome.candidateId}` | '
        '${_cell(outcome.rawTextForward)} | ${_cell(expected)} | '
        '${_cell(top)} | ${outcome.result.bestScore.toStringAsFixed(3)} | '
        '`${outcome.result.confidence.name.toUpperCase()}` |');
  }
  buffer.writeln();
}

String _pct(double value) => '${(value * 100).toStringAsFixed(1)}%';

String _cell(String value) {
  final flattened = value.replaceAll('|', '\\|').replaceAll('\n', ' ');
  if (flattened.length <= 60) return flattened;
  return '${flattened.substring(0, 57)}...';
}
