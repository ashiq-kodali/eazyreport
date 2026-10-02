import 'dart:math';
import 'document.dart';
import 'model_helpers.dart';
import 'schema.dart';
import 'types.dart';

class ResolvedReport {
  final LayoutDocument doc;
  final Set<String> inheritedElements;
  final Set<String> inheritedBands;

  const ResolvedReport({
    required this.doc,
    required this.inheritedElements,
    required this.inheritedBands,
  });
}

const singletons = [
  'reportTitle',
  'pageHeader',
  'reportSummary',
  'pageFooter',
  'overlay'
];

ResolvedReport resolveInheritance(LayoutDocument doc) {
  if (doc.base?.doc == null) {
    return ResolvedReport(
      doc: doc,
      inheritedElements: const {},
      inheritedBands: const {},
    );
  }

  final baseR = resolveInheritance(doc.base!.doc);
  final base = baseR.doc;
  final hidden = Set<String>.from(doc.hiddenBaseIds);
  final inheritedElements = <String>{};
  final inheritedBands = Set<String>.from(baseR.inheritedBands);

  Band visibleBand(Band b) {
    return b.copyWith(
        elements: b.elements.where((e) => !hidden.contains(e.id)).toList());
  }

  DataBand stripData(DataBand db) {
    final filtered = db.elements.where((e) => !hidden.contains(e.id)).toList();
    return db.copyWith(elements: filtered);
  }

  final mergedPages = <LayoutPage>[];
  for (int i = 0; i < doc.pages.length; i++) {
    final cp = doc.pages[i];
    final bp = (i < base.pages.length) ? base.pages[i] : base.pages.firstOrNull;
    if (bp == null) {
      mergedPages.add(cp);
      continue;
    }

    for (final item in allElements(bp)) {
      if (!hidden.contains(item.el.id)) {
        inheritedElements.add(item.el.id);
      }
    }

    var merged = cp;
    if (cp.inheritPage) {
      merged = merged.copyWith(
        size: bp.size,
        orientation: bp.orientation,
        width: bp.width,
        height: bp.height,
        margins: bp.margins,
        watermark: cp.watermark.enabled ? cp.watermark : bp.watermark,
        printOffsetX: bp.printOffsetX,
        printOffsetY: bp.printOffsetY,
        titleBeforeHeader: bp.titleBeforeHeader,
      );
    }

    Band? mergeSingleton(Band? b, Band? c) {
      if (b == null) return c;
      if (c == null) {
        inheritedBands.add(b.id);
        return visibleBand(b);
      }
      return c.copyWith(
        height: max(c.height, 0.0),
        elements: [...visibleBand(b).elements, ...c.elements],
      );
    }

    merged = merged.copyWith(
      reportTitle: mergeSingleton(bp.reportTitle, cp.reportTitle),
      pageHeader: mergeSingleton(bp.pageHeader, cp.pageHeader),
      reportSummary: mergeSingleton(bp.reportSummary, cp.reportSummary),
      pageFooter: mergeSingleton(bp.pageFooter, cp.pageFooter),
      overlay: mergeSingleton(bp.overlay, cp.overlay),
    );

    final baseData = bp.dataBands.map(stripData).toList();
    for (final db in baseData) {
      final flattened = flattenBands(bp.copyWith(dataBands: [db]));
      for (final s in flattened) {
        inheritedBands.add(s.band.id);
      }
    }
    merged = merged.copyWith(dataBands: [...baseData, ...cp.dataBands]);
    mergedPages.add(merged);
  }

  inheritedElements.addAll(baseR.inheritedElements);

  final paramMap = <String, ReportParameter>{};
  for (final p in base.parameters) {
    paramMap[p.name] = p;
  }
  for (final p in doc.parameters) {
    paramMap[p.name] = p;
  }

  final sourceMap = <String, DataSourceRef>{};
  for (final s in base.extraSources) {
    sourceMap[s.alias] = s;
  }
  for (final s in doc.extraSources) {
    sourceMap[s.alias] = s;
  }

  return ResolvedReport(
    doc: doc.copyWith(
      base: null,
      hiddenBaseIds: const [],
      pages: mergedPages,
      parameters: paramMap.values.toList(),
      extraSources: sourceMap.values.toList(),
      dataSourceId: doc.dataSourceId ?? base.dataSourceId,
    ),
    inheritedElements: inheritedElements,
    inheritedBands: inheritedBands,
  );
}

LayoutDocument attachBase(
    LayoutDocument doc, LayoutDocument base, String fileName) {
  final resolvedBase = resolveInheritance(base).doc;
  final updatedPages = <LayoutPage>[];
  for (int i = 0; i < doc.pages.length; i++) {
    final cp = doc.pages[i];
    final bp = (i < resolvedBase.pages.length)
        ? resolvedBase.pages[i]
        : resolvedBase.pages.firstOrNull;
    if (bp == null) {
      updatedPages.add(cp);
      continue;
    }
    var next = cp.copyWith(inheritPage: cp.inheritPage);

    Band? ensureChildBand(Band? b, Band? c) {
      if (b != null && c == null) {
        return createBand(b.type, b.height).copyWith(id: '${b.id}-c');
      } else if (b != null && c != null && c.height < b.height) {
        return c.copyWith(height: b.height);
      }
      return c;
    }

    next = next.copyWith(
      reportTitle: ensureChildBand(bp.reportTitle, cp.reportTitle),
      pageHeader: ensureChildBand(bp.pageHeader, cp.pageHeader),
      reportSummary: ensureChildBand(bp.reportSummary, cp.reportSummary),
      pageFooter: ensureChildBand(bp.pageFooter, cp.pageFooter),
      overlay: ensureChildBand(bp.overlay, cp.overlay),
    );
    updatedPages.add(next);
  }

  return doc.copyWith(
    pages: updatedPages,
    base: BaseReportRef(
      fileName: fileName,
      importedAt: DateTime.now().toUtc().toIso8601String(),
      doc: base,
    ),
  );
}

LayoutDocument detachBase(LayoutDocument doc) {
  final r = resolveInheritance(doc).doc;
  return r.copyWith(base: null, hiddenBaseIds: const []);
}
