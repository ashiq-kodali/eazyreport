import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../engine/barcode.dart';
import '../engine/elements.dart';
import '../engine/paginate.dart';
import '../expressions/expressions.dart';
import '../expressions/format.dart';
import '../model/document.dart';
import '../model/inheritance.dart';
import '../model/types.dart';

class PdfRenderOptions extends RenderOptions {
  final pw.Font? regularFont;
  final pw.Font? boldFont;
  final pw.Font? italicFont;
  final pw.Font? boldItalicFont;

  const PdfRenderOptions({
    super.params,
    super.applyOffset = true,
    super.maxPages = 2000,
    this.regularFont,
    this.boldFont,
    this.italicFont,
    this.boldItalicFont,
  });
}

PdfColor parsePdfColor(String? colorStr,
    [PdfColor defaultColor = PdfColors.black]) {
  if (colorStr == null || colorStr.trim().isEmpty) return defaultColor;
  final s = colorStr.trim().toLowerCase();
  if (s == 'transparent') return const PdfColor(0, 0, 0, 0);
  if (s == 'white') return PdfColors.white;
  if (s == 'black') return PdfColors.black;
  if (s == 'red') return PdfColors.red;
  if (s == 'green') return PdfColors.green;
  if (s == 'blue') return PdfColors.blue;
  if (s == 'grey' || s == 'gray') return PdfColors.grey;
  if (s == 'amber') return PdfColors.amber;
  if (s == 'orange') return PdfColors.orange;
  if (s == 'purple') return PdfColors.purple;

  if (s.startsWith('#')) {
    var clean = s.replaceAll('#', '').trim();
    if (clean.length == 3) {
      clean = clean.split('').map((c) => '$c$c').join();
    }
    if (clean.length == 6) {
      clean = 'ff$clean';
    }
    final val = int.tryParse(clean, radix: 16);
    if (val != null) return PdfColor.fromInt(val);
    return defaultColor;
  }

  if (s.startsWith('rgb')) {
    final match = RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)')
        .firstMatch(s);
    if (match != null) {
      final r = int.parse(match.group(1)!) / 255.0;
      final g = int.parse(match.group(2)!) / 255.0;
      final b = int.parse(match.group(3)!) / 255.0;
      final a = match.group(4) != null ? double.parse(match.group(4)!) : 1.0;
      return PdfColor(r, g, b, a);
    }
  }

  return defaultColor;
}

pw.TextAlign _toPdfTextAlign(HAlign align) {
  switch (align) {
    case HAlign.left:
      return pw.TextAlign.left;
    case HAlign.center:
      return pw.TextAlign.center;
    case HAlign.right:
      return pw.TextAlign.right;
    case HAlign.justify:
      return pw.TextAlign.justify;
  }
}

pw.MainAxisAlignment _toPdfVAlign(VAlign vAlign) {
  switch (vAlign) {
    case VAlign.top:
      return pw.MainAxisAlignment.start;
    case VAlign.middle:
      return pw.MainAxisAlignment.center;
    case VAlign.bottom:
      return pw.MainAxisAlignment.end;
  }
}

pw.BoxFit _toPdfBoxFit(String fit) {
  switch (fit.toLowerCase()) {
    case 'cover':
      return pw.BoxFit.cover;
    case 'fill':
      return pw.BoxFit.fill;
    case 'scale-down':
      return pw.BoxFit.scaleDown;
    case 'none':
      return pw.BoxFit.none;
    case 'contain':
    default:
      return pw.BoxFit.contain;
  }
}

pw.Font _selectFont(TextStyle style, PdfRenderOptions opts) {
  final isMono =
      RegExp(r'mono|courier', caseSensitive: false).hasMatch(style.fontFamily);
  final isSerif =
      RegExp(r'times|georgia|merriweather|playfair', caseSensitive: false)
          .hasMatch(style.fontFamily);

  if (opts.regularFont != null) {
    if (style.bold && style.italic && opts.boldItalicFont != null)
      return opts.boldItalicFont!;
    if (style.bold && opts.boldFont != null) return opts.boldFont!;
    if (style.italic && opts.italicFont != null) return opts.italicFont!;
    return opts.regularFont!;
  }

  if (isMono) {
    if (style.bold && style.italic) return pw.Font.courierBoldOblique();
    if (style.bold) return pw.Font.courierBold();
    if (style.italic) return pw.Font.courierOblique();
    return pw.Font.courier();
  }

  if (isSerif) {
    if (style.bold && style.italic) return pw.Font.timesBoldItalic();
    if (style.bold) return pw.Font.timesBold();
    if (style.italic) return pw.Font.timesItalic();
    return pw.Font.times();
  }

  if (style.bold && style.italic) return pw.Font.helveticaBoldOblique();
  if (style.bold) return pw.Font.helveticaBold();
  if (style.italic) return pw.Font.helveticaOblique();
  return pw.Font.helvetica();
}

pw.Widget _renderPdfTextOrField(
    PlacedElementRecord rec, PdfRenderOptions opts) {
  final el = rec.el;
  final style = el.style;
  final box = el.box;

  final textColor = rec.rc.scriptOverrideColor != null
      ? parsePdfColor(rec.rc.scriptOverrideColor)
      : parsePdfColor(style.color, PdfColors.black);

  final textDecoration = pw.TextDecoration.combine([
    if (style.underline) pw.TextDecoration.underline,
    if (style.strike) pw.TextDecoration.lineThrough,
  ]);

  final font = _selectFont(style, opts);
  final textWidget = pw.Text(
    rec.text,
    textAlign: _toPdfTextAlign(style.align),
    style: pw.TextStyle(
      font: font,
      fontSize: style.fontSize * rec.rc.fontScale,
      color: textColor,
      lineSpacing:
          style.lineHeight > 1 ? (style.lineHeight - 1) * style.fontSize : 0,
      letterSpacing: style.letterSpacing > 0 ? style.letterSpacing : null,
      decoration: textDecoration,
    ),
  );

  pw.BoxBorder? border;
  if (box.borderWidth > 0) {
    final borderColor = parsePdfColor(box.borderColor, PdfColors.black);
    final width = box.borderWidth;
    border = pw.Border(
      top: box.borderTop
          ? pw.BorderSide(color: borderColor, width: width)
          : pw.BorderSide.none,
      right: box.borderRight
          ? pw.BorderSide(color: borderColor, width: width)
          : pw.BorderSide.none,
      bottom: box.borderBottom
          ? pw.BorderSide(color: borderColor, width: width)
          : pw.BorderSide.none,
      left: box.borderLeft
          ? pw.BorderSide(color: borderColor, width: width)
          : pw.BorderSide.none,
    );
  }

  final bgColor = rec.rc.scriptOverrideBackground != null
      ? parsePdfColor(rec.rc.scriptOverrideBackground)
      : (box.background.isNotEmpty ? parsePdfColor(box.background) : null);

  final padding = box.padding > 0
      ? pw.EdgeInsets.all(box.padding * PdfPageFormat.mm)
      : pw.EdgeInsets.zero;
  final borderRadius = box.borderRadius > 0
      ? pw.BorderRadius.circular(box.borderRadius * PdfPageFormat.mm)
      : null;

  return pw.Container(
    width: rec.w * PdfPageFormat.mm,
    height: rec.h * PdfPageFormat.mm,
    padding: padding,
    decoration: pw.BoxDecoration(
      color: bgColor,
      border: border,
      borderRadius: borderRadius,
    ),
    child: pw.Column(
      mainAxisAlignment: _toPdfVAlign(style.vAlign),
      crossAxisAlignment: style.align == HAlign.center
          ? pw.CrossAxisAlignment.center
          : (style.align == HAlign.right
              ? pw.CrossAxisAlignment.end
              : pw.CrossAxisAlignment.start),
      children: [textWidget],
    ),
  );
}

pw.Widget _renderPdfBarcode(PlacedElementRecord rec) {
  final el = rec.el as BarcodeElement;
  final val = rec.text.isNotEmpty ? rec.text : el.value;
  if (val.isEmpty) return pw.SizedBox();

  final barColor = parsePdfColor(el.barColor, PdfColors.black);
  final bgColor =
      el.background.isNotEmpty ? parsePdfColor(el.background) : null;
  final bc = resolveBarcodeSymbology(el.symbology);
  final is2D = isTwoDimensional(el.symbology);

  return pw.Container(
    width: rec.w * PdfPageFormat.mm,
    height: rec.h * PdfPageFormat.mm,
    color: bgColor,
    child: pw.BarcodeWidget(
      barcode: bc,
      data: val,
      color: barColor,
      backgroundColor: bgColor,
      drawText: el.showText && !is2D,
    ),
  );
}

pw.Widget _renderPdfShape(PlacedElementRecord rec) {
  final el = rec.el as ShapeElement;
  final b = el.box;
  final fill = b.background.isNotEmpty ? parsePdfColor(b.background) : null;
  final strokeColor = parsePdfColor(b.borderColor, PdfColors.black);
  final strokeWidth = b.borderWidth;

  pw.BoxDecoration decoration;
  if (el.shape == 'circle' || el.shape == 'ellipse') {
    decoration = pw.BoxDecoration(
      color: fill,
      shape: pw.BoxShape.circle,
      border: strokeWidth > 0
          ? pw.Border.all(color: strokeColor, width: strokeWidth)
          : null,
    );
  } else if (el.shape == 'roundrect') {
    final r = b.borderRadius > 0 ? b.borderRadius : 3.0;
    decoration = pw.BoxDecoration(
      color: fill,
      borderRadius: pw.BorderRadius.circular(r * PdfPageFormat.mm),
      border: strokeWidth > 0
          ? pw.Border.all(color: strokeColor, width: strokeWidth)
          : null,
    );
  } else {
    decoration = pw.BoxDecoration(
      color: fill,
      borderRadius: b.borderRadius > 0
          ? pw.BorderRadius.circular(b.borderRadius * PdfPageFormat.mm)
          : null,
      border: strokeWidth > 0
          ? pw.Border.all(color: strokeColor, width: strokeWidth)
          : null,
    );
  }

  return pw.Container(
    width: rec.w * PdfPageFormat.mm,
    height: rec.h * PdfPageFormat.mm,
    decoration: decoration,
  );
}

pw.Widget _renderPdfLine(PlacedElementRecord rec) {
  final el = rec.el as LineElement;
  final color = parsePdfColor(el.color, PdfColors.black);
  final thickness = max(0.5, el.thickness);

  if (el.direction == 'vertical') {
    return pw.Container(
      width: thickness,
      height: rec.h * PdfPageFormat.mm,
      color: color,
    );
  }

  return pw.Container(
    width: rec.w * PdfPageFormat.mm,
    height: thickness,
    color: color,
  );
}

pw.Widget _renderPdfCheckbox(PlacedElementRecord rec) {
  final el = rec.el as CheckboxElement;
  final isChecked = evalCondition(el.expr, rec.rc.ctx);

  final size = min(rec.w, rec.h) * PdfPageFormat.mm;
  final color = parsePdfColor(el.markColor, PdfColors.black);

  return pw.Container(
    width: size,
    height: size,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: color, width: 1.0),
      borderRadius: pw.BorderRadius.circular(1.5),
    ),
    child: isChecked
        ? pw.Center(
            child: pw.Text(
              el.mark == 'cross' ? 'X' : 'v',
              style: pw.TextStyle(
                fontSize: size * 0.7,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          )
        : pw.SizedBox(),
  );
}

pw.Widget _renderPdfImage(PlacedElementRecord rec) {
  final el = rec.el as ImageElement;
  var src = el.src;
  if (src.isEmpty && el.path.isNotEmpty) {
    final val = getPath(rec.rc.ctx, el.path);
    if (val != null) src = val.toString();
  }
  if (src.isEmpty) return pw.SizedBox();

  try {
    if (src.startsWith('data:image')) {
      final comma = src.indexOf(',');
      if (comma != -1) {
        final b64 = src.substring(comma + 1);
        final bytes = base64Decode(b64);
        final img = pw.MemoryImage(bytes);
        return pw.Image(img, fit: _toPdfBoxFit(el.fit));
      }
    }
  } catch (_) {}

  return pw.SizedBox();
}

pw.Widget _renderPdfTable(PlacedElementRecord rec, PdfRenderOptions opts) {
  final el = rec.el as TableElement;
  final ctx = rec.rc.ctx;
  var rows = getPath(ctx, el.arrayPath);
  if (rows is! List) rows = (rows != null) ? [rows] : [];

  final tableRows = <pw.TableRow>[];

  // Table Header
  if (el.showHeader) {
    final headerCells = <pw.Widget>[];
    for (final col in el.columns) {
      headerCells.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(3),
          color: el.headerBackground.isNotEmpty
              ? parsePdfColor(el.headerBackground)
              : PdfColors.grey200,
          child: pw.Text(
            col.header,
            textAlign: _toPdfTextAlign(col.align),
            style: pw.TextStyle(
              font: _selectFont(el.style.copyWith(bold: true), opts),
              fontSize: el.style.fontSize,
              fontWeight: pw.FontWeight.bold,
              color: el.headerColor.isNotEmpty
                  ? parsePdfColor(el.headerColor)
                  : PdfColors.black,
            ),
          ),
        ),
      );
    }
    tableRows.add(pw.TableRow(children: headerCells));
  }

  // Table Body Rows
  for (var rIdx = 0; rIdx < rows.length; rIdx++) {
    final row = rows[rIdx];
    final cells = <pw.Widget>[];
    final isEven = rIdx % 2 == 1;
    final rowBg = isEven && el.stripeColor.isNotEmpty
        ? parsePdfColor(el.stripeColor)
        : null;

    for (final col in el.columns) {
      final raw = getPath(row, col.field);
      final text = formatValue(raw, col.format, col.dataType);

      cells.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(3),
          color: rowBg,
          child: pw.Text(
            text,
            textAlign: _toPdfTextAlign(col.align),
            style: pw.TextStyle(
              font: _selectFont(el.style, opts),
              fontSize: el.style.fontSize,
              color: parsePdfColor(el.style.color, PdfColors.black),
            ),
          ),
        ),
      );
    }
    tableRows.add(pw.TableRow(children: cells));
  }

  // Table Footer
  if (el.showFooter && rows.isNotEmpty) {
    final footerCells = <pw.Widget>[];
    for (int i = 0; i < el.columns.length; i++) {
      final col = el.columns[i];
      var text = '';
      if (col.aggregate != 'none') {
        final v = aggregate(col.aggregate, rows, col.field, 'item');
        text = formatValue(v, col.format, col.dataType);
      } else if (i == 0) {
        text = el.footerLabel;
      }

      footerCells.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(3),
          color: PdfColors.grey100,
          child: pw.Text(
            text,
            textAlign: _toPdfTextAlign(col.align),
            style: pw.TextStyle(
              font: _selectFont(el.style.copyWith(bold: true), opts),
              fontSize: el.style.fontSize,
              fontWeight: pw.FontWeight.bold,
              color: parsePdfColor(el.style.color, PdfColors.black),
            ),
          ),
        ),
      );
    }
    tableRows.add(pw.TableRow(children: footerCells));
  }

  return pw.Table(
    border: pw.TableBorder.all(
        color: parsePdfColor(el.lineColor, PdfColors.grey400),
        width: el.lineWidth > 0 ? el.lineWidth : 0.5),
    children: tableRows,
  );
}

pw.Widget _renderPdfChart(PlacedElementRecord rec, PdfRenderOptions opts) {
  final el = rec.el as ChartElement;
  final ctx = rec.rc.ctx;
  final rows = (getPath(ctx, el.dataPath) as List<dynamic>? ?? []);
  final labels =
      rows.map((r) => getPath(r, el.labelField)?.toString() ?? '').toList();
  final values = rows
      .map(
          (r) => num.tryParse(getPath(r, el.valueField)?.toString() ?? '') ?? 0)
      .toList();

  final chartColors = [
    PdfColors.blue,
    PdfColors.green,
    PdfColors.amber,
    PdfColors.red,
    PdfColors.purple,
    PdfColors.indigo,
  ];

  final maxVal = values.fold<num>(0, (m, v) => max(m, v));
  final safeMax = maxVal > 0 ? maxVal : 1;

  final bars = <pw.Widget>[];
  for (int i = 0; i < values.length; i++) {
    final v = values[i];
    final lbl = i < labels.length ? labels[i] : '';
    final barColor = chartColors[i % chartColors.length];
    final pct = (v / safeMax).clamp(0.0, 1.0);

    bars.add(
      pw.Expanded(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              v.toString(),
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 2),
            pw.Container(
              height: (rec.h * 0.55 * PdfPageFormat.mm) * pct,
              color: barColor,
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              lbl,
              maxLines: 1,
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey800),
            ),
          ],
        ),
      ),
    );
  }

  return pw.Container(
    width: rec.w * PdfPageFormat.mm,
    height: rec.h * PdfPageFormat.mm,
    padding: const pw.EdgeInsets.all(4),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      borderRadius: pw.BorderRadius.circular(3),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (el.title.isNotEmpty)
          pw.Text(
            el.title,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: bars,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _renderPdfElement(PlacedElementRecord rec, PdfRenderOptions opts) {
  pw.Widget content;
  switch (rec.el.type) {
    case 'text':
    case 'field':
      content = _renderPdfTextOrField(rec, opts);
      break;
    case 'barcode':
      content = _renderPdfBarcode(rec);
      break;
    case 'shape':
      content = _renderPdfShape(rec);
      break;
    case 'line':
      content = _renderPdfLine(rec);
      break;
    case 'checkbox':
      content = _renderPdfCheckbox(rec);
      break;
    case 'image':
      content = _renderPdfImage(rec);
      break;
    case 'table':
      content = _renderPdfTable(rec, opts);
      break;
    case 'chart':
      content = _renderPdfChart(rec, opts);
      break;
    default:
      content = pw.SizedBox();
  }

  if (rec.el.rotation != 0) {
    final r = ((rec.el.rotation % 360) + 360) % 360;
    content = pw.Transform.rotate(
      angle: -r * (pi / 180.0),
      child: content,
    );
  }

  return content;
}

pw.Widget _buildPdfWatermark(Watermark wm) {
  if (!wm.enabled || wm.text.isEmpty) return pw.SizedBox();

  return pw.Positioned.fill(
    child: pw.Center(
      child: pw.Transform.rotate(
        angle: -wm.angle * (pi / 180.0),
        child: pw.Opacity(
          opacity: wm.opacity,
          child: pw.Text(
            wm.text,
            style: pw.TextStyle(
              fontSize: wm.fontSize,
              fontWeight: pw.FontWeight.bold,
              color: parsePdfColor(wm.color, PdfColors.grey400),
            ),
          ),
        ),
      ),
    ),
  );
}

pw.Document renderReportPdfDocument(
  LayoutDocument source,
  dynamic data, [
  PdfRenderOptions opts = const PdfRenderOptions(),
]) {
  final resolved = resolveInheritance(source).doc;
  final renderedPages = renderReport(resolved, data, opts);

  final pdf = pw.Document(
    title: resolved.title,
    author: 'EazyReport',
  );

  for (final p in renderedPages) {
    final stackChildren = <pw.Widget>[];

    // Under-watermark
    if (p.watermark.enabled && !p.watermark.onTop) {
      stackChildren.add(_buildPdfWatermark(p.watermark));
    }

    // Placed Bands & Elements
    for (final band in p.placedBands) {
      // Band background fill
      if (band.fill.isNotEmpty) {
        stackChildren.add(
          pw.Positioned(
            left: band.x * PdfPageFormat.mm,
            top: band.y * PdfPageFormat.mm,
            child: pw.Container(
              width: band.width * PdfPageFormat.mm,
              height: band.height * PdfPageFormat.mm,
              color: parsePdfColor(band.fill),
            ),
          ),
        );
      }

      // Band Elements
      for (final elRec in band.elements) {
        final absX = band.x + elRec.x;
        final absY = band.y + elRec.y;

        stackChildren.add(
          pw.Positioned(
            left: absX * PdfPageFormat.mm,
            top: absY * PdfPageFormat.mm,
            child: pw.SizedBox(
              width: elRec.w * PdfPageFormat.mm,
              height: elRec.h * PdfPageFormat.mm,
              child: _renderPdfElement(elRec, opts),
            ),
          ),
        );
      }
    }

    // Over-watermark
    if (p.watermark.enabled && p.watermark.onTop) {
      stackChildren.add(_buildPdfWatermark(p.watermark));
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          p.width * PdfPageFormat.mm,
          p.height * PdfPageFormat.mm,
          marginAll: 0,
        ),
        build: (pw.Context context) {
          return pw.Stack(children: stackChildren);
        },
      ),
    );
  }

  return pdf;
}

Future<Uint8List> renderReportPdf(
  LayoutDocument source,
  dynamic data, [
  PdfRenderOptions opts = const PdfRenderOptions(),
]) async {
  final pdf = renderReportPdfDocument(source, data, opts);
  return await pdf.save();
}
