import 'dart:math' as math;
import '../expressions/format.dart';
import '../model/types.dart';

/// Renders a simple vector chart as SVG. Units inside the SVG are 0.1 mm.
String chartSvg(ChartElement el, List<String> labels, List<num> values) {
  final w = (el.w * 10).toDouble();
  final h = (el.h * 10).toDouble();
  const pt = 3.528; // 1pt in 0.1 mm
  final fs = el.style.fontSize * pt;
  final font =
      'font-family="${escapeHtml(el.style.fontFamily)}, sans-serif" fill="${el.style.color}"';
  String color(int i) => el.colors[i % el.colors.length];

  final parts = <String>[];
  var top = 4.0;

  if (el.title.isNotEmpty) {
    parts.add(
        '<text x="${w / 2}" y="${top + fs * 1.1}" text-anchor="middle" font-size="${fs * 1.15}" font-weight="700" $font>${escapeHtml(el.title)}</text>');
    top += fs * 1.6;
  }

  if (values.isEmpty) {
    parts.add(
        '<text x="${w / 2}" y="${h / 2}" text-anchor="middle" font-size="$fs" $font>No data</text>');
    return _wrap(w, h, parts);
  }

  if (el.chartType == 'pie' || el.chartType == 'doughnut') {
    final legendW = el.showLegend ? math.min(w * 0.4, 400.0) : 0.0;
    final cx = (w - legendW) / 2;
    final cy = top + (h - top) / 2;
    final r = math.max(10.0, math.min((w - legendW) / 2, (h - top) / 2) - 8);
    final total = values.fold<double>(
                0.0, (acc, v) => acc + math.max(0.0, v.toDouble())) ==
            0
        ? 1.0
        : values.fold<double>(
            0.0, (acc, v) => acc + math.max(0.0, v.toDouble()));

    var a0 = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      final v = values[i].toDouble();
      final a1 = a0 + (math.max(0.0, v) / total) * math.pi * 2;
      final large = (a1 - a0 > math.pi) ? 1 : 0;
      String p(double a, double rr) =>
          '${cx + rr * math.cos(a)},${cy + rr * math.sin(a)}';

      if (values.length == 1) {
        parts.add('<circle cx="$cx" cy="$cy" r="$r" fill="${color(i)}"/>');
      } else {
        parts.add(
            '<path d="M$cx,$cy L${p(a0, r)} A$r,$r 0 $large 1 ${p(a1, r)} Z" fill="${color(i)}" stroke="#fff" stroke-width="3"/>');
      }

      if (el.showValues && v > 0) {
        final am = (a0 + a1) / 2;
        final lr = el.chartType == 'doughnut' ? r * 0.78 : r * 0.62;
        final pct = ((v / total) * 100).round();
        parts.add(
            '<text x="${cx + lr * math.cos(am)}" y="${cy + lr * math.sin(am) + fs / 3}" text-anchor="middle" font-size="${fs * 0.9}" font-family="sans-serif" fill="#fff" font-weight="700">$pct%</text>');
      }
      a0 = a1;
    }

    if (el.chartType == 'doughnut') {
      parts.add('<circle cx="$cx" cy="$cy" r="${r * 0.55}" fill="#fff"/>');
    }

    if (el.showLegend) {
      _legend(parts, labels, w - legendW + 10, top + 10, fs, font, color);
    }
    return _wrap(w, h, parts);
  }

  final horizontal = el.chartType == 'bar';
  final double maxVal = values.map((e) => e.toDouble()).reduce(math.max);
  final double minVal = values.map((e) => e.toDouble()).reduce(math.min);
  final max = math.max(0.0, maxVal);
  final min = math.min(0.0, minVal);
  final range = (max - min == 0) ? 1.0 : (max - min);

  final maxLabelLen =
      labels.isEmpty ? 0 : labels.map((l) => l.length).reduce(math.max);
  final labelSpace =
      horizontal ? math.min(w * 0.3, maxLabelLen * fs * 0.55 + 10) : fs * 1.8;
  final valueSpace = horizontal ? fs * 5 : fs * 5.5;

  final plotX = horizontal ? labelSpace : valueSpace;
  final plotY = horizontal ? top + 6 : top + fs;
  final plotW = horizontal ? w - labelSpace - fs * 4 : w - valueSpace - 10;
  final plotH = horizontal ? h - top - 12 : h - top - fs - labelSpace;

  double scale(num v) =>
      ((v.toDouble() - min) / range) * (horizontal ? plotW : plotH);

  if (el.showGrid) {
    for (int i = 0; i <= 4; i++) {
      final v = min + (range * i) / 4;
      if (horizontal) {
        final x = plotX + scale(v);
        parts.add(
            '<line x1="$x" y1="$plotY" x2="$x" y2="${plotY + plotH}" stroke="#e2e8f0" stroke-width="2"/>');
      } else {
        final y = plotY + plotH - scale(v);
        parts.add(
            '<line x1="$plotX" y1="$y" x2="${plotX + plotW}" y2="$y" stroke="#e2e8f0" stroke-width="2"/>');
        parts.add(
            '<text x="${plotX - 6}" y="${y + fs / 3}" text-anchor="end" font-size="${fs * 0.85}" $font>${formatNumber(v, v % 1 != 0 ? 1 : 0)}</text>');
      }
    }
  }

  final n = values.length;
  final slot = (horizontal ? plotH : plotW) / n;

  if (el.chartType == 'line' || el.chartType == 'area') {
    final pts = <List<double>>[];
    for (int i = 0; i < values.length; i++) {
      pts.add([plotX + slot * (i + 0.5), plotY + plotH - scale(values[i])]);
    }
    if (el.chartType == 'area') {
      final base = plotY + plotH - scale(0);
      final ptsStr = pts.map((p) => 'L${p[0]},${p[1]}').join(' ');
      parts.add(
          '<path d="M${pts[0][0]},$base $ptsStr L${pts[n - 1][0]},$base Z" fill="${color(0)}" opacity="0.25"/>');
    }
    final polyPts = pts.map((p) => '${p[0]},${p[1]}').join(' ');
    parts.add(
        '<polyline points="$polyPts" fill="none" stroke="${color(0)}" stroke-width="6" stroke-linejoin="round"/>');
    for (int i = 0; i < pts.length; i++) {
      final p = pts[i];
      parts.add('<circle cx="${p[0]}" cy="${p[1]}" r="7" fill="${color(0)}"/>');
      if (el.showValues) {
        parts.add(
            '<text x="${p[0]}" y="${p[1] - 12}" text-anchor="middle" font-size="${fs * 0.85}" $font>${formatNumber(values[i], values[i] % 1 != 0 ? 2 : 0)}</text>');
      }
    }
  } else {
    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      final bar = slot * 0.62;
      final len = (scale(v) - scale(0)).abs();
      if (horizontal) {
        final y = plotY + slot * i + (slot - bar) / 2;
        final x = plotX + math.min(scale(0), scale(v));
        parts.add(
            '<rect x="$x" y="$y" width="$len" height="$bar" fill="${color(i)}" rx="3"/>');
        if (el.showValues) {
          parts.add(
              '<text x="${x + len + 6}" y="${y + bar / 2 + fs / 3}" font-size="${fs * 0.85}" $font>${formatNumber(v, v % 1 != 0 ? 2 : 0)}</text>');
        }
      } else {
        final x = plotX + slot * i + (slot - bar) / 2;
        final y = plotY + plotH - math.max(scale(0), scale(v));
        parts.add(
            '<rect x="$x" y="$y" width="$bar" height="$len" fill="${color(i)}" rx="3"/>');
        if (el.showValues) {
          parts.add(
              '<text x="${x + bar / 2}" y="${y - 6}" text-anchor="middle" font-size="${fs * 0.85}" $font>${formatNumber(v, v % 1 != 0 ? 2 : 0)}</text>');
        }
      }
    }
  }

  for (int i = 0; i < labels.length; i++) {
    final l = labels[i];
    final txt = escapeHtml(l.length > 18 ? '${l.substring(0, 17)}…' : l);
    if (horizontal) {
      parts.add(
          '<text x="${plotX - 6}" y="${plotY + slot * (i + 0.5) + fs / 3}" text-anchor="end" font-size="${fs * 0.85}" $font>$txt</text>');
    } else {
      parts.add(
          '<text x="${plotX + slot * (i + 0.5)}" y="${plotY + plotH + fs * 1.2}" text-anchor="middle" font-size="${fs * 0.85}" $font>$txt</text>');
    }
  }

  parts.add(horizontal
      ? '<line x1="$plotX" y1="$plotY" x2="$plotX" y2="${plotY + plotH}" stroke="#94a3b8" stroke-width="2"/>'
      : '<line x1="$plotX" y1="${plotY + plotH - scale(0)}" x2="${plotX + plotW}" y2="${plotY + plotH - scale(0)}" stroke="#94a3b8" stroke-width="2"/>');

  return _wrap(w, h, parts);
}

void _legend(List<String> parts, List<String> labels, double x, double y,
    double fs, String font, String Function(int) color) {
  for (int i = 0; i < labels.length; i++) {
    final yy = y + i * fs * 1.5;
    parts.add(
        '<rect x="$x" y="$yy" width="${fs * 0.9}" height="${fs * 0.9}" fill="${color(i)}" rx="2"/>');
    parts.add(
        '<text x="${x + fs * 1.3}" y="${yy + fs * 0.8}" font-size="${fs * 0.85}" $font>${escapeHtml(labels[i])}</text>');
  }
}

String _wrap(double w, double h, List<String> parts) {
  return '<svg viewBox="0 0 $w $h" preserveAspectRatio="none" style="display:block;width:100%;height:100%" xmlns="http://www.w3.org/2000/svg">${parts.join()}</svg>';
}
