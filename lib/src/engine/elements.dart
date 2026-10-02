import 'dart:math';
import '../expressions/expressions.dart';
import '../expressions/format.dart';
import '../model/types.dart';
import 'barcode.dart';
import 'chart.dart';

class RenderCtx {
  final String mode; // 'design' | 'data'
  final dynamic ctx;
  final bool blankValue;
  final bool autoHeight;
  final double fontScale;
  final String? scriptOverrideText;
  final String? scriptOverrideColor;
  final String? scriptOverrideBackground;

  const RenderCtx({
    this.mode = 'data',
    required this.ctx,
    this.blankValue = false,
    this.autoHeight = false,
    this.fontScale = 1.0,
    this.scriptOverrideText,
    this.scriptOverrideColor,
    this.scriptOverrideBackground,
  });

  RenderCtx copyWith({
    String? mode,
    dynamic ctx,
    bool? blankValue,
    bool? autoHeight,
    double? fontScale,
    String? scriptOverrideText,
    String? scriptOverrideColor,
    String? scriptOverrideBackground,
  }) {
    return RenderCtx(
      mode: mode ?? this.mode,
      ctx: ctx ?? this.ctx,
      blankValue: blankValue ?? this.blankValue,
      autoHeight: autoHeight ?? this.autoHeight,
      fontScale: fontScale ?? this.fontScale,
      scriptOverrideText: scriptOverrideText ?? this.scriptOverrideText,
      scriptOverrideColor: scriptOverrideColor ?? this.scriptOverrideColor,
      scriptOverrideBackground:
          scriptOverrideBackground ?? this.scriptOverrideBackground,
    );
  }
}

String n3(num v) => ((v * 1000).round() / 1000).toString();
const ptToMm = 25.4 / 72.0;

String fontFamilyCss(String family) {
  final clean = family.replaceAll("'", "");
  final mono = RegExp(r'mono|courier', caseSensitive: false).hasMatch(family);
  final serif =
      RegExp(r'times|georgia|merriweather|playfair', caseSensitive: false)
          .hasMatch(family);
  return "'$clean', ${mono ? 'monospace' : serif ? 'serif' : 'sans-serif'}";
}

String textCss(TextStyle s, [double scale = 1.0]) {
  final deco = [
    if (s.underline) 'underline',
    if (s.strike) 'line-through',
  ].join(' ');

  final parts = <String>[
    'font-family:${fontFamilyCss(s.fontFamily)}',
    'font-size:${n3(s.fontSize * scale)}pt',
    'font-weight:${s.bold ? 700 : 400}',
    'font-style:${s.italic ? 'italic' : 'normal'}',
    if (deco.isNotEmpty) 'text-decoration:$deco',
    'color:${s.color}',
    'line-height:${n3(s.lineHeight)}',
    if (s.letterSpacing > 0) 'letter-spacing:${n3(s.letterSpacing)}pt',
  ];
  return parts.join(';');
}

List<String> strokeCss(BoxStyle b) {
  if (b.borderWidth <= 0) return [];
  final stroke =
      '${n3(b.borderWidth)}pt ${b.borderStyle.name} ${b.borderColor}';
  return [
    if (b.borderTop) 'border-top:$stroke',
    if (b.borderRight) 'border-right:$stroke',
    if (b.borderBottom) 'border-bottom:$stroke',
    if (b.borderLeft) 'border-left:$stroke',
  ];
}

String boxCss(BoxStyle b, [bool withPadding = true]) {
  final parts = <String>[];
  if (b.background.isNotEmpty) parts.add('background:${b.background}');
  parts.addAll(strokeCss(b));
  if (b.borderRadius > 0) parts.add('border-radius:${n3(b.borderRadius)}mm');
  if (withPadding && b.padding > 0) parts.add('padding:${n3(b.padding)}mm');
  if (b.shadow) parts.add('box-shadow:0.6mm 0.6mm 1.2mm rgba(0,0,0,0.25)');
  return parts.join(';');
}

String _vAlignCss(VAlign a) {
  switch (a) {
    case VAlign.top:
      return 'flex-start';
    case VAlign.bottom:
      return 'flex-end';
    case VAlign.middle:
      return 'center';
  }
}

String _escapeKeepingExpressions(String text) {
  final regex = RegExp(r'(\{\{[\s\S]*?\}\})');
  return text.splitMapJoin(
    regex,
    onMatch: (m) => m.group(0)!,
    onNonMatch: (n) => escapeHtml(n),
  );
}

({T el, bool hidden}) applyHighlights<T extends LayoutElement>(
    T el, RenderCtx rc) {
  if (rc.mode != 'data' || el.highlights.isEmpty)
    return (el: el, hidden: false);
  var style = el.style;
  var box = el.box;
  var hidden = false;

  for (final h in el.highlights) {
    if (h.condition.isEmpty || !evalCondition(h.condition, rc.ctx)) continue;
    if (h.hide) hidden = true;
    if (h.color.isNotEmpty) style = style.copyWith(color: h.color);
    if (h.bold) style = style.copyWith(bold: true);
    if (h.italic) style = style.copyWith(italic: true);
    if (h.background.isNotEmpty) box = box.copyWith(background: h.background);
  }

  final updated = el.copyWith(style: style, box: box) as T;
  return (el: updated, hidden: hidden);
}

String textBlock(TextStyle style, BoxStyle box, String inner, RenderCtx rc) {
  final outer = [
    'width:100%',
    rc.autoHeight ? 'height:auto' : 'height:100%',
    'box-sizing:border-box',
    rc.autoHeight ? '' : 'overflow:hidden',
    'display:flex',
    'flex-direction:column',
    'justify-content:${_vAlignCss(style.vAlign)}',
    boxCss(box),
    textCss(style, rc.fontScale),
  ].where((s) => s.isNotEmpty).join(';');

  final innerCss =
      'text-align:${style.align.name};${style.wrap ? 'white-space:pre-wrap;overflow-wrap:anywhere' : 'white-space:pre;overflow:hidden'}';
  return '<div style="$outer"><div style="$innerCss">$inner</div></div>';
}

dynamic _rowValue(dynamic row, String path, String alias) {
  final p = path.startsWith('$alias.')
      ? path.substring(alias.length + 1)
      : path.replaceAll(RegExp(r'^item\.'), '');
  return getPath(row, p);
}

num aggregate(String kind, List<dynamic> rows, String path, String alias) {
  if (kind == 'count') return rows.length;
  final vals = rows
      .map((r) => num.tryParse(_rowValue(r, path, alias)?.toString() ?? ''))
      .whereType<num>()
      .toList();
  if (vals.isEmpty) return 0;

  switch (kind) {
    case 'sum':
      return vals.reduce((a, b) => a + b);
    case 'avg':
      return vals.reduce((a, b) => a + b) / vals.length;
    case 'min':
      return vals.reduce(min);
    case 'max':
      return vals.reduce(max);
    default:
      return 0;
  }
}

String fieldText(FieldElement el, dynamic ctx) {
  dynamic raw;
  if (el.aggregate.isNotEmpty && el.aggregate != 'none') {
    final rows = (ctx is Map ? ctx['_rows'] : null) as List<dynamic>? ?? [];
    final alias = (ctx is Map ? ctx['_alias'] : null) as String? ?? 'item';
    raw = aggregate(el.aggregate, rows, el.path, alias);
  } else {
    raw = getPath(ctx, el.path);
  }

  if (raw == null || raw == '') return el.nullText;
  if (el.hideZeros && num.tryParse(raw.toString()) == 0) return '';
  final kind = resolveFormatKind(el.format, el.dataType);
  final fmt = (el.aggregate != 'none' && kind == 'text')
      ? el.format.copyWith(format: 'number')
      : el.format;
  return formatValue(raw, fmt, el.dataType);
}

String _renderImage(ImageElement el, RenderCtx rc) {
  var src = el.src;
  if (el.path.isNotEmpty) {
    if (rc.mode == 'data') {
      src = getPath(rc.ctx, el.path)?.toString() ?? el.src;
    }
  }

  final outer =
      'width:100%;height:100%;box-sizing:border-box;overflow:hidden;${boxCss(el.box)}';
  if (src.isEmpty) {
    if (rc.mode == 'data') return '';
    final label = el.path.isNotEmpty ? '[${escapeHtml(el.path)}]' : 'Picture';
    return '<div style="$outer;display:flex;align-items:center;justify-content:center;background:#f1f5f9;color:#94a3b8;font:8pt sans-serif">$label</div>';
  }

  final pos =
      '${el.hAlignImage} ${el.vAlignImage == 'middle' ? 'center' : el.vAlignImage}';
  final filters = el.grayscale ? 'grayscale(1)' : '';
  final img =
      'display:block;width:100%;height:100%;object-fit:${el.fit == 'none' ? 'none' : el.fit};object-position:$pos;${filters.isNotEmpty ? 'filter:$filters;' : ''}${el.opacity < 1 ? 'opacity:${el.opacity};' : ''}';
  return '<div style="$outer"><img src="${escapeHtml(src)}" style="$img" alt=""></div>';
}

String _dashArray(StrokeStyle style, double w) {
  if (style == StrokeStyle.dashed)
    return 'stroke-dasharray="${w * 4} ${w * 2.5}"';
  if (style == StrokeStyle.dotted)
    return 'stroke-dasharray="$w ${w * 1.8}" stroke-linecap="round"';
  return '';
}

String _renderLine(LineElement el) {
  final w = (el.w * 10).toDouble();
  final h = (el.h * 10).toDouble();
  final sw = el.thickness * ptToMm * 10;
  var x1 = 0.0, y1 = 0.0, x2 = 0.0, y2 = 0.0;

  if (el.direction == 'horizontal') {
    x1 = 0;
    y1 = h / 2;
    x2 = w;
    y2 = h / 2;
  } else if (el.direction == 'vertical') {
    x1 = w / 2;
    y1 = 0;
    x2 = w / 2;
    y2 = h;
  } else if (el.direction == 'diagonal-down') {
    x1 = 0;
    y1 = 0;
    x2 = w;
    y2 = h;
  } else {
    x1 = 0;
    y1 = h;
    x2 = w;
    y2 = 0;
  }

  final markerId = 'm${el.id}';
  final marker = (el.arrowStart || el.arrowEnd)
      ? '<defs><marker id="$markerId" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="5" markerHeight="5" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="${el.color}"/></marker></defs>'
      : '';
  final common =
      'stroke="${el.color}" stroke-width="$sw" ${_dashArray(el.lineStyle, sw)}';
  final mk =
      '${el.arrowStart ? 'marker-start="url(#$markerId)"' : ''} ${el.arrowEnd ? 'marker-end="url(#$markerId)"' : ''}';
  var lines = '<line x1="$x1" y1="$y1" x2="$x2" y2="$y2" $common $mk/>';

  if (el.lineStyle == StrokeStyle.double &&
      (el.direction == 'horizontal' || el.direction == 'vertical')) {
    final off = sw * 1.5;
    final dx = el.direction == 'horizontal' ? 0.0 : off;
    final dy = el.direction == 'horizontal' ? off : 0.0;
    final thin = 'stroke="${el.color}" stroke-width="$sw"';
    lines =
        '<line x1="${x1 - dx}" y1="${y1 - dy}" x2="${x2 - dx}" y2="${y2 - dy}" $thin/><line x1="${x1 + dx}" y1="${y1 + dy}" x2="${x2 + dx}" y2="${y2 + dy}" $thin/>';
  }

  return '<svg viewBox="0 0 $w $h" preserveAspectRatio="none" style="display:block;width:100%;height:100%;overflow:visible">$marker$lines</svg>';
}

String _renderShape(ShapeElement el) {
  final b = el.box;
  if (el.shape == 'rect' || el.shape == 'roundrect') {
    final radius = el.shape == 'roundrect' && b.borderRadius == 0
        ? 'border-radius:3mm;'
        : '';
    return '<div style="width:100%;height:100%;box-sizing:border-box;$radius${boxCss(b, false)}"></div>';
  }

  final w = (el.w * 10).toDouble();
  final h = (el.h * 10).toDouble();
  final sw = b.borderWidth * ptToMm * 10;
  final i = sw / 2;
  final fill = b.background.isNotEmpty ? b.background : 'none';
  final stroke = b.borderWidth > 0
      ? 'stroke="${b.borderColor}" stroke-width="$sw" ${_dashArray(b.borderStyle, sw)}'
      : '';

  String shape;
  if (el.shape == 'ellipse') {
    shape =
        '<ellipse cx="${w / 2}" cy="${h / 2}" rx="${max(0.0, w / 2 - i)}" ry="${max(0.0, h / 2 - i)}" fill="$fill" $stroke/>';
  } else if (el.shape == 'triangle') {
    shape =
        '<polygon points="${w / 2},$i ${w - i},${h - i} $i,${h - i}" fill="$fill" $stroke stroke-linejoin="round"/>';
  } else {
    shape =
        '<polygon points="${w / 2},$i ${w - i},${h / 2} ${w / 2},${h - i} $i,${h / 2}" fill="$fill" $stroke stroke-linejoin="round"/>';
  }

  return '<svg viewBox="0 0 $w $h" preserveAspectRatio="none" style="display:block;width:100%;height:100%">$shape</svg>';
}

String _renderCheckbox(CheckboxElement el, RenderCtx rc) {
  final checked = rc.mode == 'design' ? true : evalCondition(el.expr, rc.ctx);
  final outer =
      'width:100%;height:100%;box-sizing:border-box;${boxCss(el.box, false)}';
  if (!checked) return el.uncheckedHidden ? '' : '<div style="$outer"></div>';

  final c = el.markColor;
  String mark;
  if (el.mark == 'fill') {
    mark = '<rect x="20" y="20" width="60" height="60" fill="$c"/>';
  } else if (el.mark == 'cross') {
    mark =
        '<path d="M22 22 L78 78 M78 22 L22 78" stroke="$c" stroke-width="12" stroke-linecap="round"/>';
  } else {
    mark =
        '<path d="M20 52 L42 74 L82 26" fill="none" stroke="$c" stroke-width="12" stroke-linecap="round" stroke-linejoin="round"/>';
  }

  return '<div style="$outer"><svg viewBox="0 0 100 100" preserveAspectRatio="none" style="display:block;width:100%;height:100%">$mark</svg></div>';
}

String _renderTable(TableElement el, RenderCtx rc) {
  final totalColWidth =
      el.columns.fold<double>(0.0, (acc, c) => acc + max(0.1, c.width)) == 0
          ? 1.0
          : el.columns.fold<double>(0.0, (acc, c) => acc + max(0.1, c.width));

  final stroke = '${n3(el.lineWidth)}pt solid ${el.lineColor}';
  final cellBorder = el.gridLines == 'all'
      ? 'border:$stroke'
      : (el.gridLines == 'horizontal' ? 'border-bottom:$stroke' : '');
  final cellBase = [
    'padding:0 ${n3(el.cellPadding)}mm',
    'overflow:hidden',
    'vertical-align:middle',
    'box-sizing:border-box',
    el.style.wrap
        ? 'white-space:normal;overflow-wrap:anywhere'
        : 'white-space:nowrap',
    if (cellBorder.isNotEmpty) cellBorder,
  ].join(';');

  final colTags = el.columns
      .map((c) =>
          '<col style="width:${n3((max(0.1, c.width) / totalColWidth) * 100)}%">')
      .join();

  var head = '';
  if (el.showHeader) {
    final ths = el.columns.map((c) {
      final bg = el.headerBackground.isNotEmpty
          ? 'background:${el.headerBackground}'
          : '';
      return '<th style="$cellBase;text-align:${c.align.name};font-weight:${el.headerBold ? 700 : 400};color:${el.headerColor};$bg">${escapeHtml(c.header)}</th>';
    }).join();
    head =
        '<thead><tr style="height:${n3(el.headerHeight)}mm">$ths</tr></thead>';
  }

  final rows = (rc.mode == 'design')
      ? [{}, {}]
      : (getPath(rc.ctx, el.arrayPath) as List<dynamic>? ?? []);

  final bodyRows = <String>[];
  for (int i = 0; i < rows.length; i++) {
    final row = rows[i];
    final tds = el.columns.map((c) {
      final val = rc.mode == 'design'
          ? '[${c.field}]'
          : formatValue(getPath(row, c.field), c.format, c.dataType);
      final stripe = el.stripeColor.isNotEmpty && i % 2 == 1
          ? 'background:${el.stripeColor}'
          : '';
      return '<td style="$cellBase;text-align:${c.align.name};height:${n3(el.rowHeight)}mm;$stripe">${escapeHtml(val)}</td>';
    }).join();
    bodyRows.add('<tr>$tds</tr>');
  }
  final body = bodyRows.join();

  var foot = '';
  if (el.showFooter) {
    final ftds = <String>[];
    for (int i = 0; i < el.columns.length; i++) {
      final c = el.columns[i];
      var content = '';
      if (c.aggregate != 'none') {
        final v = aggregate(c.aggregate, rows, c.field, '');
        content = escapeHtml(formatValue(v, c.format, c.dataType));
      } else if (i == 0) {
        content = escapeHtml(el.footerLabel);
      }
      ftds.add(
          '<td style="$cellBase;text-align:${c.align.name};font-weight:700;height:${n3(el.rowHeight)}mm">$content</td>');
    }
    foot = '<tfoot><tr>${ftds.join()}</tr></tfoot>';
  }

  final outer = [
    'width:100%',
    rc.autoHeight ? 'height:auto' : 'height:100%',
    'box-sizing:border-box',
    'overflow:hidden',
    boxCss(el.box),
  ].join(';');

  return '<div style="$outer"><table style="width:100%;border-collapse:collapse;table-layout:fixed;margin:0;${textCss(el.style)}"><colgroup>$colTags</colgroup>$head<tbody>$body</tbody>$foot</table></div>';
}

String _renderChart(ChartElement el, RenderCtx rc) {
  List<String> labels;
  List<num> values;

  if (rc.mode == 'design' &&
      (el.dataPath.isEmpty || getPath(rc.ctx, el.dataPath) == null)) {
    labels = ['A', 'B', 'C', 'D'];
    values = [4, 7, 3, 6];
  } else {
    final rows = (getPath(rc.ctx, el.dataPath) as List<dynamic>? ?? []);
    labels = rows
        .map((r) => _rowValue(r, el.labelField, 'item')?.toString() ?? '')
        .toList();
    values = rows
        .map((r) =>
            num.tryParse(
                _rowValue(r, el.valueField, 'item')?.toString() ?? '') ??
            0)
        .toList();
  }

  final outer =
      'width:100%;height:100%;box-sizing:border-box;overflow:hidden;${boxCss(el.box, false)}';
  return '<div style="$outer">${chartSvg(el, labels, values)}</div>';
}

String? renderVisual(LayoutElement source, RenderCtx rc) {
  if (rc.mode == 'data' &&
      source.visibleExpr.isNotEmpty &&
      !evalCondition(source.visibleExpr, rc.ctx)) {
    return null;
  }

  final highlightRes = applyHighlights(source, rc);
  if (highlightRes.hidden) return null;
  var el = highlightRes.el;

  if (rc.scriptOverrideColor != null) {
    el = el.copyWith(style: el.style.copyWith(color: rc.scriptOverrideColor));
  }
  if (rc.scriptOverrideBackground != null &&
      el.type != 'line' &&
      el.type != 'shape') {
    el = el.copyWith(
        box: el.box.copyWith(background: rc.scriptOverrideBackground));
  }

  switch (el.type) {
    case 'text':
      final tEl = el as TextElement;
      String inner;
      if (rc.scriptOverrideText != null) {
        inner = escapeHtml(rc.scriptOverrideText!);
      } else if (rc.mode == 'design') {
        inner = tEl.allowHtml ? tEl.text : escapeHtml(tEl.text);
      } else if (rc.blankValue) {
        inner = '';
      } else {
        inner = evalTemplate(
            tEl.allowHtml ? tEl.text : _escapeKeepingExpressions(tEl.text),
            rc.ctx);
      }
      return textBlock(tEl.style, tEl.box, inner, rc);

    case 'field':
      final fEl = el as FieldElement;
      String inner;
      if (rc.scriptOverrideText != null) {
        inner = escapeHtml(rc.scriptOverrideText!);
      } else if (rc.mode == 'design') {
        final lbl = fEl.path.isNotEmpty ? fEl.label : 'unbound';
        inner = '${escapeHtml(fEl.prefix)}[$lbl]${escapeHtml(fEl.suffix)}';
      } else if (rc.blankValue) {
        inner = '';
      } else {
        final t = fieldText(fEl, rc.ctx);
        inner = t.isNotEmpty
            ? escapeHtml(
                evalText(fEl.prefix, rc.ctx) + t + evalText(fEl.suffix, rc.ctx))
            : '';
      }
      return textBlock(fEl.style, fEl.box, inner, rc);

    case 'image':
      return _renderImage(el as ImageElement, rc);
    case 'line':
      return _renderLine(el as LineElement);
    case 'shape':
      return _renderShape(el as ShapeElement);
    case 'checkbox':
      return _renderCheckbox(el as CheckboxElement, rc);
    case 'table':
      return _renderTable(el as TableElement, rc);
    case 'chart':
      return _renderChart(el as ChartElement, rc);
    case 'barcode':
      final bEl = el as BarcodeElement;
      final val = rc.scriptOverrideText ??
          (rc.mode == 'design' ? bEl.value : evalText(bEl.value, rc.ctx));
      if (val.isEmpty) return '';
      return barcodeHtml(bEl, val);
    case 'subreport':
      return '<!--subreport:${el.id}-->';
    default:
      return null;
  }
}

String positioned(
    LayoutElement el, double x, double y, double h, String inner, dynamic ctx) {
  final r = ((el.rotation % 360) + 360) % 360;
  var content = inner;
  if (r != 0) {
    final swap = r == 90 || r == 270;
    final iw = swap ? h : el.w;
    final ih = swap ? el.w : h;
    content =
        '<div style="position:absolute;left:50%;top:50%;width:${n3(iw)}mm;height:${n3(ih)}mm;transform:translate(-50%,-50%) rotate(${r}deg)">$inner</div>';
  }

  if (el.hyperlink.isNotEmpty) {
    final href = evalText(el.hyperlink, ctx);
    if (href.isNotEmpty) {
      content =
          '<a href="${escapeHtml(href)}" style="color:inherit;text-decoration:none;display:block;width:100%;height:100%">$content</a>';
    }
  }

  return '<div class="rd-el" style="left:${n3(x)}mm;top:${n3(y)}mm;width:${n3(el.w)}mm;height:${n3(h)}mm">$content</div>';
}
