import 'dart:math';
import '../expressions/expressions.dart';
import '../expressions/format.dart';
import '../model/document.dart';
import '../model/inheritance.dart';
import '../model/types.dart';
import 'elements.dart';
import 'logic_compiler.dart';
import 'print_on.dart';

const fontLink =
    'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Merriweather:wght@400;700&family=Playfair+Display:wght@600;700&family=Roboto+Mono:wght@400;500&display=swap';

class PlacedElementRecord {
  final LayoutElement el;
  final double x;
  final double y;
  final double w;
  final double h;
  final String text;
  final RenderCtx rc;

  const PlacedElementRecord({
    required this.el,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.text,
    required this.rc,
  });
}

class PlacedBandRecord {
  final Band band;
  final double x;
  final double y;
  final double width;
  final double height;
  final String fill;
  final List<PlacedElementRecord> elements;

  const PlacedBandRecord({
    required this.band,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.fill,
    required this.elements,
  });
}

class RenderedPage {
  final String id;
  final double width;
  final double height;
  final String html;
  final List<PlacedBandRecord> placedBands;
  final Watermark watermark;
  final PageMargins margins;

  const RenderedPage({
    required this.id,
    required this.width,
    required this.height,
    required this.html,
    this.placedBands = const [],
    this.watermark = const Watermark(),
    this.margins = const PageMargins(),
  });
}

class RenderOptions {
  final Map<String, dynamic>? params;
  final bool applyOffset;
  final int maxPages;

  const RenderOptions({
    this.params,
    this.applyOffset = true,
    this.maxPages = 2000,
  });
}

class LaidOutBand {
  final String html;
  final double height;
  final List<PlacedElementRecord> elements;
  const LaidOutBand({
    required this.html,
    required this.height,
    this.elements = const [],
  });
}

class _LayoutState {
  final Map<String, String> dups = {};
}

String _valueKey(LayoutElement el, dynamic ctx) {
  if (el is FieldElement) return fieldText(el, ctx);
  if (el is TextElement) return evalText(el.text, ctx);
  return '';
}

LaidOutBand? layoutBand(
  Band band,
  dynamic ctx,
  double width,
  _LayoutState state, [
  String extraFill = '',
  PrintOnContext? meta,
]) {
  if (band.visibleExpr.isNotEmpty && !evalCondition(band.visibleExpr, ctx)) {
    return null;
  }
  if (meta != null && band.printOn != null && band.printOn!.isNotEmpty) {
    if (!shouldPrintWithFlags(band.printOn, meta, true)) return null;
  }

  var bandFill = extraFill.isNotEmpty ? extraFill : band.fill;

  // Evaluate visual rules for band
  if (band.rules != null && band.rules!.isNotEmpty) {
    for (final rule in band.rules!) {
      final res = evaluateRule(rule, ctx);
      if (res.triggered) {
        if (res.action == 'hide' || res.action == 'skip') return null;
        if (res.action == 'background' && res.actionValue != null) {
          bandFill = res.actionValue!;
        }
      }
    }
  }

  final items = <({
    LayoutElement el,
    String html,
    double y,
    double h,
    RenderCtx rc,
    String text
  })>[];
  for (var el in band.elements) {
    if (!el.printable) continue;
    if (meta != null && el.printOn != null && el.printOn!.isNotEmpty) {
      if (!shouldPrintWithFlags(el.printOn, meta, true)) continue;
    }

    var rc = RenderCtx(mode: 'data', ctx: ctx);

    // Evaluate visual rules for element
    if (el.rules != null && el.rules!.isNotEmpty) {
      var skipEl = false;
      for (final rule in el.rules!) {
        final res = evaluateRule(rule, ctx);
        if (res.triggered) {
          if (res.action == 'hide' || res.action == 'skip') {
            skipEl = true;
            break;
          }
          if (res.action == 'text_color' && res.actionValue != null) {
            rc = rc.copyWith(scriptOverrideColor: res.actionValue);
          }
          if (res.action == 'background' && res.actionValue != null) {
            rc = rc.copyWith(scriptOverrideBackground: res.actionValue);
          }
          if (res.action == 'set_text' && res.actionValue != null) {
            rc = rc.copyWith(scriptOverrideText: res.actionValue);
          }
        }
      }
      if (skipEl) continue;
    }

    if ((el is FieldElement && el.hideDuplicates) ||
        (el is TextElement && el.hideDuplicates)) {
      final key = _valueKey(el, ctx);
      if (state.dups[el.id] == key) {
        rc = rc.copyWith(blankValue: true);
      }
      state.dups[el.id] = key;
    }

    final html = renderVisual(el, rc);
    if (html == null) continue;

    String evaluatedText = '';
    if (rc.scriptOverrideText != null) {
      evaluatedText = rc.scriptOverrideText!;
    } else if (rc.blankValue) {
      evaluatedText = '';
    } else if (el is TextElement) {
      evaluatedText = evalTemplate(el.text, ctx);
    } else if (el is FieldElement) {
      final t = fieldText(el, ctx);
      evaluatedText = t.isNotEmpty
          ? evalText(el.prefix, ctx) + t + evalText(el.suffix, ctx)
          : '';
    } else if (el is BarcodeElement) {
      evaluatedText = evalText(el.value, ctx);
    }

    items.add(
        (el: el, html: html, y: el.y, h: el.h, rc: rc, text: evaluatedText));
  }

  var height = band.height;
  final contentBottom = items.fold<double>(0.0, (m, it) => max(m, it.y + it.h));
  if (band.canGrow && contentBottom > height) height = contentBottom;
  if (band.canShrink && contentBottom < height) height = contentBottom;

  final parts = <String>[];
  final placedElements = <PlacedElementRecord>[];
  if (bandFill.isNotEmpty) {
    parts.add(
        '<div style="position:absolute;inset:0;background:$bandFill"></div>');
  }

  for (final it in items) {
    var h = it.h;
    if (it.el.growToBottom) {
      h = max(h, height - it.y);
    }
    parts.add(positioned(it.el, it.el.x, it.y, h, it.html, ctx));
    placedElements.add(PlacedElementRecord(
      el: it.el,
      x: it.el.x,
      y: it.y,
      w: it.el.w,
      h: h,
      text: it.text,
      rc: it.rc,
    ));
  }

  return LaidOutBand(
    html:
        '<div class="rd-band" style="width:${n3(width)}mm;height:${n3(height)}mm">${parts.join()}</div>',
    height: height,
    elements: placedElements,
  );
}

class _PageBuf {
  final LayoutPage tpl;
  final List<String> parts = [];
  final List<PlacedBandRecord> placedBands = [];
  final int number;
  final List<dynamic> rows = [];
  String rowAlias = 'item';
  _PageBuf({required this.tpl, required this.number});
}

class _Repeat {
  final Band band;
  final dynamic ctx;
  const _Repeat(this.band, this.ctx);
}

class Paginator {
  final dynamic root;
  final RenderOptions opts;
  final List<RenderedPage> pages = [];
  _PageBuf? _cur;
  double _y = 0.0;
  bool _hasContent = false;
  final List<_Repeat> _repeats = [];
  final _LayoutState _state = _LayoutState();
  int _pageNumber = 0;

  Paginator(this.root, this.opts);

  LayoutPage get _tpl => _cur!.tpl;
  double get _width => _tpl.width - _tpl.margins.left - _tpl.margins.right;
  double get _limit {
    final footer = _tpl.pageFooter != null ? _tpl.pageFooter!.height : 0.0;
    return _tpl.height - _tpl.margins.top - _tpl.margins.bottom - footer;
  }

  PrintOnContext _getPrintMeta([bool isRepeated = false, bool? isLast]) {
    final total = root is Map && root['TotalPages'] is int
        ? root['TotalPages'] as int
        : null;
    return PrintOnContext(
      pageNumber: _pageNumber,
      totalPages: total,
      isFirst: _pageNumber == 1,
      isLast: isLast ?? (total != null ? _pageNumber == total : null),
      isRepeated: isRepeated,
    );
  }

  Map<String, dynamic> _ctx([Map<String, dynamic> extra = const {}]) {
    final baseMap = (root is Map)
        ? Map<String, dynamic>.from(root as Map)
        : <String, dynamic>{};
    baseMap['Page'] = _pageNumber;
    baseMap.addAll(extra);
    return baseMap;
  }

  void renderTemplatePage(LayoutPage tpl) {
    _startPage(tpl, true);
    final firstRows =
        tpl.dataBands.isNotEmpty ? _resolveRows(tpl.dataBands[0], root) : [];
    final reportScope = {
      '_rows': firstRows,
      '_alias': tpl.dataBands.isNotEmpty ? tpl.dataBands[0].alias : 'item',
    };

    for (final db in tpl.dataBands) {
      _printDataBand(db, root);
    }

    if (tpl.reportSummary != null) {
      _printBand(
          tpl.reportSummary!, (page) => _ctx({...reportScope, 'Page': page}));
    }

    _endPage(true);
  }

  void _startPage(LayoutPage tpl, bool first) {
    if (pages.length >= opts.maxPages)
      throw Exception('Too many pages (limit reached).');
    _pageNumber += 1;
    _cur = _PageBuf(tpl: tpl, number: _pageNumber);
    _y = 0.0;
    _hasContent = false;

    void title() {
      if (tpl.reportTitle == null) return;
      final rt = tpl.reportTitle!;
      final isRepeated = !first;
      final meta = _getPrintMeta(isRepeated);
      final defaultPrint = rt.repeatOnEveryPage ? true : first;
      if (!shouldPrintWithFlags(rt.printOn, meta, defaultPrint)) return;
      final rows =
          tpl.dataBands.isNotEmpty ? _resolveRows(tpl.dataBands[0], root) : [];
      _place(
          rt,
          _ctx({
            '_rows': rows,
            '_alias': tpl.dataBands.isNotEmpty ? tpl.dataBands[0].alias : 'item'
          }),
          0,
          null,
          '',
          meta);
    }

    void header() {
      if (tpl.pageHeader == null) return;
      final ph = tpl.pageHeader!;
      final isRepeated = !first;
      final meta = _getPrintMeta(isRepeated);
      final defaultPrint = !first || ph.printOnFirstPage;
      if (!shouldPrintWithFlags(ph.printOn, meta, defaultPrint)) return;
      _place(ph, _ctx(), 0, null, '', meta);
    }

    if (tpl.titleBeforeHeader) {
      title();
      header();
    } else {
      header();
      title();
    }

    for (final r in _repeats) {
      final repeatMeta = _getPrintMeta(true);
      if (shouldPrintWithFlags(r.band.printOn, repeatMeta, true)) {
        _place(r.band, {...(r.ctx as Map), 'Page': _pageNumber}, 0, null, '',
            repeatMeta);
      }
    }
    _hasContent = false;
  }

  void _endPage(bool last) {
    final buf = _cur!;
    final t = buf.tpl;
    final w = _width;
    final parts = <String>[];
    final ox = opts.applyOffset ? t.printOffsetX : 0.0;
    final oy = opts.applyOffset ? t.printOffsetY : 0.0;

    final wm = t.watermark;
    var watermark = '';
    if (wm.enabled) {
      if (wm.image.isNotEmpty) {
        watermark =
            '<img src="${escapeHtml(wm.image)}" style="position:absolute;left:50%;top:50%;max-width:80%;max-height:80%;transform:translate(-50%,-50%) rotate(${wm.angle}deg);opacity:${wm.opacity}" alt="">';
      } else {
        watermark =
            '<div style="position:absolute;left:50%;top:50%;transform:translate(-50%,-50%) rotate(${wm.angle}deg);font:700 ${wm.fontSize}pt Inter,sans-serif;color:${wm.color};opacity:${wm.opacity};white-space:nowrap">${escapeHtml(evalText(wm.text, _ctx()))}</div>';
      }
    }

    if (watermark.isNotEmpty && !wm.onTop) parts.add(watermark);

    if (t.overlay != null) {
      final overlayMeta = _getPrintMeta(false, last);
      if (shouldPrintWithFlags(t.overlay!.printOn, overlayMeta, true)) {
        final laid = layoutBand(t.overlay!, _ctx(), w, _state, '', overlayMeta);
        if (laid != null) {
          final bx = t.margins.left;
          final by = t.margins.top;
          parts.add(_at(bx, by, laid.html));
          buf.placedBands.insert(
              0,
              PlacedBandRecord(
                band: t.overlay!,
                x: bx,
                y: by,
                width: w,
                height: laid.height,
                fill: t.overlay!.fill,
                elements: laid.elements,
              ));
        }
      }
    }

    parts.addAll(buf.parts);

    if (t.pageFooter != null) {
      final footerMeta = _getPrintMeta(buf.number > 1, last);
      final defaultPrint = (!last || t.pageFooter!.printOnLastPage) &&
          (buf.number != 1 || t.pageFooter!.printOnFirstPage);
      if (shouldPrintWithFlags(
          t.pageFooter!.printOn, footerMeta, defaultPrint)) {
        final laid = layoutBand(
            t.pageFooter!,
            _ctx({'_rows': buf.rows, '_alias': buf.rowAlias}),
            w,
            _state,
            '',
            footerMeta);
        if (laid != null) {
          final bx = t.margins.left;
          final by = t.height - t.margins.bottom - t.pageFooter!.height;
          parts.add(_at(bx, by, laid.html));
          buf.placedBands.add(PlacedBandRecord(
            band: t.pageFooter!,
            x: bx,
            y: by,
            width: w,
            height: laid.height,
            fill: t.pageFooter!.fill,
            elements: laid.elements,
          ));
        }
      }
    }

    if (watermark.isNotEmpty && wm.onTop) parts.add(watermark);

    final offset = (ox != 0 || oy != 0)
        ? ' style="transform:translate(${n3(ox)}mm,${n3(oy)}mm)"'
        : '';
    pages.add(RenderedPage(
      id: t.id,
      width: t.width,
      height: t.height,
      html: '<div class="rd-layer"$offset>${parts.join()}</div>',
      placedBands: List.unmodifiable(buf.placedBands),
      watermark: t.watermark,
      margins: t.margins,
    ));
    _cur = null;
  }

  void _newPage() {
    final tpl = _tpl;
    _endPage(false);
    _startPage(tpl, false);
  }

  String _at(double x, double y, String html) {
    return '<div style="position:absolute;left:${n3(x)}mm;top:${n3(y)}mm">$html</div>';
  }

  double _place(Band band, dynamic ctx,
      [double xOffset = 0.0,
      double? width,
      String fill = '',
      PrintOnContext? meta]) {
    final pageMeta = meta ?? _getPrintMeta();
    if (band.printOn != null &&
        band.printOn!.isNotEmpty &&
        !shouldPrintWithFlags(band.printOn, pageMeta, true)) {
      return 0.0;
    }
    final laid = layoutBand(band, ctx, width ?? _width, _state, fill, pageMeta);
    if (laid == null) return 0.0;
    final t = _tpl;
    final bx = t.margins.left + xOffset;
    final by = t.margins.top + _y;
    _cur!.parts.add(_at(bx, by, laid.html));
    _cur!.placedBands.add(PlacedBandRecord(
      band: band,
      x: bx,
      y: by,
      width: width ?? _width,
      height: laid.height,
      fill: fill.isNotEmpty ? fill : band.fill,
      elements: laid.elements,
    ));
    _y += laid.height;
    var totalHeight = laid.height;
    if (band.child != null) {
      totalHeight += _place(band.child!, ctx, xOffset, width, '', pageMeta);
    }
    return totalHeight;
  }

  double _printBand(
    Band band,
    dynamic Function(int page) ctxFor, {
    double xOffset = 0.0,
    double? width,
    String fill = '',
    bool advance = true,
  }) {
    final initialMeta = _getPrintMeta();
    if (band.printOn != null &&
        band.printOn!.isNotEmpty &&
        !shouldPrintWithFlags(band.printOn, initialMeta, true)) {
      return 0.0;
    }
    if (band.startNewPage && _hasContent) _newPage();

    var checkBand = band as Band?;
    var requiredHeight = 0.0;
    while (checkBand != null) {
      requiredHeight += checkBand.height;
      if (checkBand.child == null || !checkBand.child!.keepWithParent) break;
      checkBand = checkBand.child;
    }

    if (requiredHeight > band.height &&
        _y + requiredHeight > _limit + 0.01 &&
        _hasContent) {
      _newPage();
    }

    var ctx = ctxFor(_pageNumber);
    final snapshot = Map<String, String>.from(_state.dups);
    var meta = _getPrintMeta();
    var laid = layoutBand(band, ctx, width ?? _width, _state, fill, meta);
    if (laid == null) return 0.0;

    if (_y + laid.height > _limit + 0.01 && _hasContent) {
      _state.dups.clear();
      _state.dups.addAll(snapshot);
      _newPage();
      _state.dups.clear();
      ctx = ctxFor(_pageNumber);
      meta = _getPrintMeta();
      laid = layoutBand(band, ctx, width ?? _width, _state, fill, meta);
      if (laid == null) return 0.0;
    }

    final t = _tpl;
    final bx = t.margins.left + xOffset;
    final by = t.margins.top + _y;
    _cur!.parts.add(_at(bx, by, laid.html));
    _cur!.placedBands.add(PlacedBandRecord(
      band: band,
      x: bx,
      y: by,
      width: width ?? _width,
      height: laid.height,
      fill: fill.isNotEmpty ? fill : band.fill,
      elements: laid.elements,
    ));
    if (advance) _y += laid.height;
    _hasContent = true;
    var totalHeight = laid.height;

    if (band.child != null) {
      totalHeight +=
          _printBand(band.child!, ctxFor, xOffset: xOffset, width: width);
    }

    return totalHeight;
  }

  List<dynamic> _resolveRows(DataBand db, dynamic parentCtx) {
    var rows = getPath(parentCtx, db.dataPath);
    if (rows is! List) {
      rows = (rows != null) ? [rows] : [];
    }
    var out = List<dynamic>.from(rows);
    if (db.filterExpr.isNotEmpty) {
      out = out
          .where((row) => evalCondition(
              db.filterExpr, {...(parentCtx as Map), db.alias: row}))
          .toList();
    }
    if (db.sortBy.isNotEmpty) {
      final cleanSortBy = db.sortBy.startsWith('${db.alias}.')
          ? db.sortBy.substring(db.alias.length + 1)
          : db.sortBy;
      out.sort((a, b) {
        final va = getPath(a, cleanSortBy);
        final vb = getPath(b, cleanSortBy);
        if (va is num && vb is num) {
          return db.sortDesc ? vb.compareTo(va) : va.compareTo(vb);
        }
        final sa = va?.toString() ?? '';
        final sb = vb?.toString() ?? '';
        return db.sortDesc ? sb.compareTo(sa) : sa.compareTo(sb);
      });
    }
    if (db.maxRows > 0 && out.length > db.maxRows) {
      out = out.sublist(0, db.maxRows);
    }
    return out;
  }

  void _fillUnusedSpaceWithChild(
      DataBand db, dynamic parentCtx, List<dynamic> rows) {
    var childBand = db.child;
    while (childBand != null && !childBand.fillUnusedSpace) {
      childBand = childBand.child;
    }
    if (childBand == null ||
        !childBand.fillUnusedSpace ||
        childBand.height <= 0) return;

    final footerH = db.footer != null ? db.footer!.height : 0.0;
    final maxFillY = _limit - footerH;
    final lastRow = rows.isNotEmpty ? rows.last : {};

    Map<String, dynamic> fillCtx(int page) => {
          ...(parentCtx as Map),
          '_rows': rows,
          '_alias': db.alias,
          db.alias: lastRow,
          'isUnusedSpace': true,
          'Page': page,
        };

    var count = 0;
    while (_y + childBand.height <= maxFillY + 0.01 && count < 100) {
      count++;
      final printedH = _printBand(childBand, fillCtx);
      if (printedH <= 0) break;
    }
  }

  void _printDataBand(DataBand db, dynamic parentCtx) {
    final rows = _resolveRows(db, parentCtx);
    if (rows.isEmpty) {
      if (db.child != null && db.child!.printIfDatabandEmpty) {
        _printBand(db.child!,
            (page) => {...(parentCtx as Map), db.alias: {}, 'Page': page});
      }
      if (!db.printIfEmpty) return;
    }

    final scope = {'_rows': rows, '_alias': db.alias};
    final first = rows.isNotEmpty ? rows[0] : null;
    Map<String, dynamic> headerCtx(int page) =>
        {...(parentCtx as Map), ...scope, db.alias: first, 'Page': page};

    _state.dups.clear();

    var pushed = 0;
    if (db.header != null) {
      _printBand(db.header!, headerCtx);
      if (db.header!.repeatOnEveryPage) {
        _repeats.add(_Repeat(db.header!, headerCtx(_pageNumber)));
        pushed++;
      }
    }

    var rowNo = 0;
    _printGroups(db, rows, 0, parentCtx, () => ++rowNo);
    _flushColumns();

    _fillUnusedSpaceWithChild(db, parentCtx, rows);

    if (pushed > 0) {
      _repeats.removeRange(_repeats.length - pushed, _repeats.length);
    }

    if (db.footer != null) {
      _printBand(
          db.footer!,
          (page) => {
                ...(parentCtx as Map),
                ...scope,
                db.alias: rows.isNotEmpty ? rows.last : null,
                'Page': page
              });
    }
  }

  List<({String key, List<dynamic> rows})> _groupRuns(
      DataBand db, int level, List<dynamic> rows, dynamic parentCtx) {
    final cond = db.groups[level].condition;
    final runs = <({String key, List<dynamic> rows})>[];
    for (final row in rows) {
      final v = evalValue(cond, {...(parentCtx as Map), db.alias: row});
      final key = v?.toString() ?? '';
      if (runs.isNotEmpty && runs.last.key == key) {
        runs.last.rows.add(row);
      } else {
        runs.add((key: key, rows: [row]));
      }
    }
    return runs;
  }

  void _printGroups(DataBand db, List<dynamic> rows, int level,
      dynamic parentCtx, int Function() nextRow) {
    if (level >= db.groups.length) {
      for (final row in rows) {
        _printRow(db, row, rows, parentCtx, nextRow());
      }
      return;
    }
    final g = db.groups[level];
    final runs = _groupRuns(db, level, rows, parentCtx);

    for (int index = 0; index < runs.length; index++) {
      final run = runs[index];
      _flushColumns();
      Map<String, dynamic> gctx(int page) => {
            ...(parentCtx as Map),
            '_rows': run.rows,
            '_alias': db.alias,
            db.alias: run.rows.isNotEmpty ? run.rows[0] : null,
            'Group': {
              'key': run.key,
              'count': run.rows.length,
              'index': index + 1
            },
            'Page': page,
          };

      if (g.header.startNewPage && index > 0 && _hasContent) _newPage();
      _printBand(g.header, gctx);
      final repeat = g.header.repeatOnEveryPage;
      if (repeat) _repeats.add(_Repeat(g.header, gctx(_pageNumber)));

      _printGroups(db, run.rows, level + 1, parentCtx, nextRow);
      _flushColumns();

      if (repeat) _repeats.removeLast();
      if (g.footer != null) _printBand(g.footer!, gctx);
    }
  }

  int _col = 0;
  double _colRowHeight = 0.0;

  void _flushColumns() {
    if (_col > 0) {
      _y += _colRowHeight;
      _col = 0;
      _colRowHeight = 0.0;
    }
  }

  void _printRow(DataBand db, dynamic row, List<dynamic> all, dynamic parentCtx,
      int rowNo) {
    Map<String, dynamic> ctxFor(int page) => {
          ...(parentCtx as Map),
          '_rows': all,
          '_alias': db.alias,
          db.alias: row,
          'Row': rowNo,
          'RowIndex': rowNo - 1,
          'Page': page,
        };

    final fill = (db.evenFill.isNotEmpty && rowNo % 2 == 0) ? db.evenFill : '';
    void recordRow() {
      if (_cur!.rows.isEmpty) _cur!.rowAlias = db.alias;
      _cur!.rows.add(row);
    }

    if (db.columns > 1 && db.detail == null) {
      final n = db.columns;
      final colW = (_width - db.columnGap * (n - 1)) / n;
      final x = _col * (colW + db.columnGap);
      final laid = layoutBand(db, ctxFor(_pageNumber), colW, _state, fill);
      if (laid == null) return;
      if (_col == 0 && _y + laid.height > _limit + 0.01 && _hasContent)
        _newPage();
      final t = _tpl;
      final bx = t.margins.left + x;
      final by = t.margins.top + _y;
      _cur!.parts.add(_at(bx, by, laid.html));
      _cur!.placedBands.add(PlacedBandRecord(
        band: db,
        x: bx,
        y: by,
        width: colW,
        height: laid.height,
        fill: fill.isNotEmpty ? fill : db.fill,
        elements: laid.elements,
      ));
      _colRowHeight = max(_colRowHeight, laid.height);
      _hasContent = true;
      recordRow();
      _col += 1;
      if (_col >= n) _flushColumns();
      return;
    }

    _printBand(db, ctxFor, fill: fill);
    recordRow();
    if (db.detail != null) _printDataBand(db.detail!, ctxFor(_pageNumber));
  }
}

Map<String, dynamic> _buildRoot(
    LayoutDocument doc, dynamic data, RenderOptions opts, dynamic totalPages) {
  final params = <String, dynamic>{};
  for (final p in doc.parameters) {
    params[p.name] = (opts.params != null && opts.params!.containsKey(p.name))
        ? opts.params![p.name]
        : p.defaultValue;
  }
  final now = DateTime.now().toUtc();
  final dataMap =
      (data is Map) ? Map<String, dynamic>.from(data) : <String, dynamic>{};

  return {
    ...dataMap,
    'params': {...params, if (dataMap['params'] is Map) ...dataMap['params']},
    'Now': now.toIso8601String(),
    'Today': now.toIso8601String().substring(0, 10),
    'ReportTitle': doc.title,
    'TotalPages': totalPages,
    'Page': 1,
    'Row': 0,
  };
}

bool _needsSecondPass(LayoutDocument doc) {
  final jsonStr = doc.toJson().toString();
  return jsonStr.contains('TotalPages') || jsonStr.contains('LastPage');
}

List<RenderedPage> renderReport(
  LayoutDocument source,
  dynamic data, [
  RenderOptions opts = const RenderOptions(),
]) {
  final doc = resolveInheritance(source).doc;
  if (data is List) {
    return data
        .expand((record) => renderReport(doc, record ?? {}, opts))
        .toList();
  }

  List<RenderedPage> run(dynamic total) {
    final p = Paginator(_buildRoot(doc, data, opts, total), opts);
    for (final tpl in doc.pages) {
      p.renderTemplatePage(tpl);
    }
    return p.pages;
  }

  var pages = run('?');
  if (_needsSecondPass(doc)) {
    pages = run(pages.length);
  }
  return pages;
}

String reportCss(LayoutDocument source) {
  final doc = resolveInheritance(source).doc;
  final named = doc.pages.asMap().entries.map((entry) {
    final i = entry.key;
    final p = entry.value;
    return '@page p$i { size: ${n3(p.width)}mm ${n3(p.height)}mm; margin: 0; }\n.rd-page.p$i { page: p$i; }';
  }).join('\n');

  final first = doc.pages.isNotEmpty ? doc.pages[0] : null;
  final defW = first != null ? first.width : 210.0;
  final defH = first != null ? first.height : 297.0;

  return '''
@page { size: ${n3(defW)}mm ${n3(defH)}mm; margin: 0; }
$named
html, body { margin: 0; padding: 0; }
body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
.rd-page { position: relative; overflow: hidden; background: #fff; break-after: page; page-break-after: always; }
.rd-page:last-child { break-after: auto; page-break-after: auto; }
.rd-layer { position: absolute; inset: 0; }
.rd-band { position: relative; }
.rd-el { position: absolute; box-sizing: border-box; }
.rd-el table { margin: 0; }
@media screen {
  body { background: #e2e8f0; padding: 8mm 0; }
  .rd-page { margin: 0 auto 8mm; box-shadow: 0 2px 12px rgba(0,0,0,.18); }
}''';
}

String pagesHtml(LayoutDocument source, List<RenderedPage> pages) {
  final doc = resolveInheritance(source).doc;
  final sb = StringBuffer();
  for (final p in pages) {
    final idx = max(0, doc.pages.indexWhere((t) => t.id == p.id));
    sb.writeln(
        '<div class="rd-page p$idx" style="width:${n3(p.width)}mm;height:${n3(p.height)}mm">${p.html}</div>');
  }
  return sb.toString();
}

String renderReportHtml(
  LayoutDocument doc,
  dynamic data, [
  RenderOptions opts = const RenderOptions(applyOffset: true),
]) {
  final pages = renderReport(doc, data, opts);
  return '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>${escapeHtml(doc.title)}</title>
<link rel="stylesheet" href="$fontLink">
<style>
${reportCss(doc)}
</style>
</head>
<body>
${pagesHtml(doc, pages)}
</body>
</html>''';
}
