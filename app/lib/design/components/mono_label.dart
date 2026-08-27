import 'package:flutter/material.dart';

import '../tokens/typography.dart';

/// The two sizes of machine output in Rafça.
enum MonoLabelStyle {
  /// 11px, semibold, wide tracking. Status and section metadata — the text you
  /// scan rather than read: `SOURCE CAPTURE — 12 ITEMS DETECTED`.
  caps,

  /// 12px, regular. Data you actually read a value out of: `CONF: 0.98`,
  /// an ISBN, an edition year.
  data,
}

/// Text that came from the system rather than from a person.
///
/// DESIGN.md ("Archival Metadata") gives IBM Plex Mono exactly one job: it
/// marks a string as machine output, and to do that it is always uppercase and
/// letterspaced. Both are applied here so that no call site can render mono
/// text that reads like prose.
class MonoLabel extends StatelessWidget {
  const MonoLabel(
    this.text, {
    this.style = MonoLabelStyle.caps,
    this.color,
    this.maxLines,
    super.key,
  });

  /// The string to render, in the user's language.
  final String text;

  /// Which of the two mono roles this is.
  final MonoLabelStyle style;

  /// Overrides the colour. Defaults to `onSurfaceVariant`, the tone DESIGN.md
  /// uses for metadata that supports the content instead of competing with it.
  final Color? color;

  /// Caps labels are single-line by default because they are chrome; data can
  /// wrap when a value is long.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = switch (style) {
      MonoLabelStyle.caps => SpineTypography.metadataCaps,
      MonoLabelStyle.data => SpineTypography.labelMono,
    };
    final lines = maxLines ?? (style == MonoLabelStyle.caps ? 1 : null);

    return Text(
      uppercaseForLocale(text, Localizations.maybeLocaleOf(context)),
      style: base.copyWith(color: color ?? scheme.onSurfaceVariant),
      maxLines: lines,
      overflow: lines == null ? null : TextOverflow.ellipsis,
    );
  }
}
