import 'dart:math';
import 'document.dart';
import 'schema.dart';
import 'types.dart';

const double pxPerMm = 96.0 / 25.4;

class PageSizeDimensions {
  final String label;
  final double w;
  final double h;
  const PageSizeDimensions(this.label, this.w, this.h);
}

const Map<String, PageSizeDimensions> pageSizes = {
  'A3': PageSizeDimensions('A3 (297 × 420 mm)', 297, 420),
  'A4': PageSizeDimensions('A4 (210 × 297 mm)', 210, 297),
  'A5': PageSizeDimensions('A5 (148 × 210 mm)', 148, 210),
  'A6': PageSizeDimensions('A6 (105 × 148 mm)', 105, 148),
  'B5': PageSizeDimensions('B5 (176 × 250 mm)', 176, 250),
  'LETTER': PageSizeDimensions('US Letter (8.5 × 11 in)', 215.9, 279.4),
  'LEGAL': PageSizeDimensions('US Legal (8.5 × 14 in)', 215.9, 355.6),
  'EXECUTIVE': PageSizeDimensions('Executive (7.25 × 10.5 in)', 184.2, 266.7),
};

double r1(double v) => (v * 10.0).roundToDouble() / 10.0;

String uid() {
  final rnd = Random();
  return (rnd.nextInt(1 << 30)).toRadixString(36);
}

Map<String, dynamic> resolvePage(
  String size,
  String orientation, [
  double? currentWidth,
  double? currentHeight,
]) {
  if (size == 'CUSTOM') {
    return {
      'size': size,
      'orientation': orientation,
      'width': currentWidth ?? 210.0,
      'height': currentHeight ?? 297.0,
    };
  }
  final base = pageSizes[size] ?? pageSizes['A4']!;
  final w = orientation == 'portrait' ? base.w : base.h;
  final h = orientation == 'portrait' ? base.h : base.w;
  return {'size': size, 'orientation': orientation, 'width': w, 'height': h};
}

Band createBand(String type, [double height = 10.0, String? name]) {
  return Band(
    id: uid(),
    type: type,
    name: name ?? _bandLabel(type),
    height: height,
    canGrow: false,
    canShrink: false,
    visibleExpr: '',
    fill: '',
    startNewPage: false,
    printOnFirstPage: true,
    printOnLastPage: true,
    repeatOnEveryPage: false,
    elements: [],
  );
}

String _bandLabel(String type) {
  switch (type) {
    case 'reportTitle':
      return 'Report Title';
    case 'pageHeader':
      return 'Page Header';
    case 'dataHeader':
      return 'Data Header';
    case 'groupHeader':
      return 'Group Header';
    case 'data':
      return 'Data';
    case 'groupFooter':
      return 'Group Footer';
    case 'dataFooter':
      return 'Data Footer';
    case 'reportSummary':
      return 'Report Summary';
    case 'pageFooter':
      return 'Page Footer';
    case 'overlay':
      return 'Overlay';
    case 'child':
      return 'Child';
    default:
      return type;
  }
}

Band createChildBand([String? parentName, double height = 8.0]) {
  return Band(
    id: uid(),
    type: 'child',
    name: parentName != null ? 'Child: $parentName' : 'Child',
    height: height,
    fillUnusedSpace: false,
    keepWithParent: false,
    printIfDatabandEmpty: false,
    elements: [],
  );
}

DataBand createDataBand(
    [String dataPath = '', String alias = 'item', double height = 7.0]) {
  return DataBand(
    id: uid(),
    type: 'data',
    name: dataPath.isNotEmpty ? 'Data: $dataPath' : 'Data',
    height: height,
    dataPath: dataPath,
    alias: alias,
    sortBy: '',
    sortDesc: false,
    filterExpr: '',
    maxRows: 0,
    printIfEmpty: false,
    evenFill: '',
    columns: 1,
    columnGap: 0,
    groups: [],
    elements: [],
  );
}

GroupLevel createGroup(String condition) {
  return GroupLevel(
    id: uid(),
    condition: condition,
    header: createBand('groupHeader', 8.0),
    footer: createBand('groupFooter', 8.0),
  );
}

class BandSlot {
  final Band band;
  final int depth;
  final DataBand? dataBand;
  final GroupLevel? group;
  final String label;

  BandSlot({
    required this.band,
    required this.depth,
    this.dataBand,
    this.group,
    required this.label,
  });
}

List<BandSlot> flattenBands(LayoutPage page) {
  final out = <BandSlot>[];
  void add(Band? band, int depth, String label,
      [DataBand? dataBand, GroupLevel? group]) {
    if (band == null) return;
    out.add(BandSlot(
        band: band,
        depth: depth,
        label: label,
        dataBand: dataBand,
        group: group));
    if (band.child != null) {
      add(
          band.child,
          depth + 1,
          'Child · ${band.name.isNotEmpty ? band.name : label}',
          dataBand,
          group);
    }
  }

  if (page.titleBeforeHeader) {
    add(page.reportTitle, 0, 'Report Title');
    add(page.pageHeader, 0, 'Page Header');
  } else {
    add(page.pageHeader, 0, 'Page Header');
    add(page.reportTitle, 0, 'Report Title');
  }

  void walk(DataBand db, int depth) {
    add(db.header, depth, 'Data Header · ${db.dataPath}', db);
    for (int i = 0; i < db.groups.length; i++) {
      final g = db.groups[i];
      add(g.header, depth + i, 'Group Header · ${g.condition}', db, g);
    }
    final gd = depth + db.groups.length;
    add(db, gd, 'Data · ${db.dataPath} as ${db.alias}', db);
    if (db.detail != null) walk(db.detail!, gd + 1);
    final reversedGroups = db.groups.reversed.toList();
    for (int i = 0; i < reversedGroups.length; i++) {
      final g = reversedGroups[i];
      add(g.footer, depth + db.groups.length - 1 - i,
          'Group Footer · ${g.condition}', db, g);
    }
    add(db.footer, depth, 'Data Footer · ${db.dataPath}', db);
  }

  for (final db in page.dataBands) {
    walk(db, 0);
  }

  add(page.reportSummary, 0, 'Report Summary');
  add(page.pageFooter, 0, 'Page Footer');
  add(page.overlay, 0, 'Overlay (every page, behind)');

  return out;
}

List<({LayoutElement el, Band band})> allElements(LayoutPage page) {
  final result = <({LayoutElement el, Band band})>[];
  for (final slot in flattenBands(page)) {
    for (final el in slot.band.elements) {
      result.add((el: el, band: slot.band));
    }
  }
  return result;
}

double bandWidth(LayoutPage page) =>
    r1(page.width - page.margins.left - page.margins.right);

LayoutPage createPage([String name = 'Page1']) {
  final resolved = resolvePage('A4', 'portrait');
  return LayoutPage(
    id: uid(),
    name: name,
    size: 'A4',
    orientation: 'portrait',
    width: resolved['width'] as double,
    height: resolved['height'] as double,
    margins: const PageMargins(top: 10, right: 10, bottom: 10, left: 10),
    reportTitle: createBand('reportTitle', 30.0),
    pageFooter: createBand('pageFooter', 8.0),
  );
}

LayoutDocument createBlankDocument([String title = 'Untitled Report']) {
  final now = DateTime.now().toUtc().toIso8601String();
  return LayoutDocument(
    format: 'report-designer-layout',
    version: 2,
    title: title,
    pages: [createPage()],
    createdAt: now,
    updatedAt: now,
  );
}

LayoutElement createElement(
    String tool, double x, double y, List<LayoutElement> existing) {
  switch (tool) {
    case 'text':
      return createText('Text', x, y, existing);
    case 'field':
      return createFieldElement('field', '', x, y, existing);
    case 'image':
      return ImageElement(
          id: uid(), name: 'Picture', x: r1(x), y: r1(y), w: 35, h: 25);
    case 'hline':
      return LineElement(
          id: uid(),
          name: 'Line',
          x: r1(x),
          y: r1(y),
          w: 60,
          h: 2,
          direction: 'horizontal');
    case 'vline':
      return LineElement(
          id: uid(),
          name: 'Line',
          x: r1(x),
          y: r1(y),
          w: 2,
          h: 20,
          direction: 'vertical');
    case 'rect':
      return ShapeElement(
          id: uid(),
          name: 'Shape',
          x: r1(x),
          y: r1(y),
          w: 40,
          h: 20,
          shape: 'rect');
    case 'roundrect':
      return ShapeElement(
          id: uid(),
          name: 'Shape',
          x: r1(x),
          y: r1(y),
          w: 40,
          h: 20,
          shape: 'roundrect');
    case 'ellipse':
      return ShapeElement(
          id: uid(),
          name: 'Shape',
          x: r1(x),
          y: r1(y),
          w: 30,
          h: 20,
          shape: 'ellipse');
    case 'table':
      return TableElement(
          id: uid(), name: 'Table', x: r1(x), y: r1(y), w: 120, h: 50);
    case 'barcode':
      return BarcodeElement(
          id: uid(),
          name: 'Barcode',
          x: r1(x),
          y: r1(y),
          w: 50,
          h: 15,
          symbology: 'code128');
    case 'qrcode':
      return BarcodeElement(
          id: uid(),
          name: 'QR',
          x: r1(x),
          y: r1(y),
          w: 25,
          h: 25,
          symbology: 'qrcode',
          showText: false);
    case 'checkbox':
      return CheckboxElement(
          id: uid(), name: 'CheckBox', x: r1(x), y: r1(y), w: 4, h: 4);
    case 'chart':
      return ChartElement(
          id: uid(), name: 'Chart', x: r1(x), y: r1(y), w: 90, h: 55);
    case 'subreport':
      return SubReportElement(
          id: uid(), name: 'SubReport', x: r1(x), y: r1(y), w: 80, h: 40);
    default:
      return createText('Text', x, y, existing);
  }
}

TextElement createText(
    String text, double x, double y, List<LayoutElement> existing,
    [double w = 50.0, double h = 6.0]) {
  return TextElement(
    id: uid(),
    name: 'Text',
    x: r1(x),
    y: r1(y),
    w: w,
    h: h,
    text: text,
  );
}

FieldElement createFieldElement(
    String path, String label, double x, double y, List<LayoutElement> existing,
    [double w = 45.0, double h = 6.0]) {
  return FieldElement(
    id: uid(),
    name: label.isNotEmpty ? label.replaceAll(RegExp(r'\W+'), '') : 'Field',
    x: r1(x),
    y: r1(y),
    w: w,
    h: h,
    path: path,
    label: label,
  );
}

TableColumn createColumn(
    String header, String field, String dataType, double width) {
  final numeric = dataType == 'number' || dataType == 'currency';
  return TableColumn(
    id: uid(),
    header: header,
    field: field,
    dataType: dataType,
    width: width,
    align: numeric ? HAlign.right : HAlign.left,
  );
}

DataBand createDataSection(SchemaField arrayField, double bandWidth,
    [String alias = 'item']) {
  final children = (arrayField.children ?? []).take(7).toList();
  var db = createDataBand(arrayField.path, alias, 7.0)
      .copyWith(name: 'Data: ${arrayField.label}');
  final header =
      createBand('dataHeader', 8.0, 'Header: ${arrayField.label}').copyWith(
    repeatOnEveryPage: true,
    fill: '#eef2ff',
  );
  final footer = createBand('dataFooter', 8.0, 'Footer: ${arrayField.label}');
  if (children.isEmpty) {
    return db.copyWith(header: header);
  }

  final weights = children.map((c) => c.type == 'string' ? 3.0 : 1.4).toList();
  final totalWeight = weights.reduce((a, b) => a + b);
  double curX = 0.0;
  final headerEls = <LayoutElement>[];
  final dataEls = <LayoutElement>[];
  final footerEls = <LayoutElement>[];

  int totalIdx = -1;
  for (int i = 0; i < children.length; i++) {
    if (children[i].type == 'currency') totalIdx = i;
  }

  for (int i = 0; i < children.length; i++) {
    final c = children[i];
    final w = (i == children.length - 1)
        ? r1(bandWidth - curX)
        : r1((weights[i] / totalWeight) * bandWidth);
    final numeric = c.type == 'number' || c.type == 'currency';

    final cap = createText(c.label, curX, 1.0, headerEls, w, 6.0);
    final styledCap = cap.copyWith(
      style: cap.style.copyWith(
          bold: true,
          fontSize: 9.0,
          color: '#3730a3',
          align: numeric ? HAlign.right : HAlign.left),
      name: 'Hdr${c.key}',
    );
    headerEls.add(styledCap);

    final cleanPath = c.path.startsWith('item.') ? c.path.substring(5) : c.path;
    final f = createFieldElement(
        '$alias.$cleanPath', c.label, curX, 0.5, dataEls, w, 6.0);
    dataEls.add(f);

    if (i == totalIdx) {
      final t = createFieldElement('$alias.$cleanPath', 'Total ${c.label}',
              curX, 1.0, footerEls, w, 6.0)
          .copyWith(
        aggregate: 'sum',
        style: f.style.copyWith(bold: true, fontSize: 9.0),
      );
      footerEls.add(t);
    }
    curX = r1(curX + w);
  }

  return db.copyWith(
    header: header.copyWith(elements: headerEls),
    elements: dataEls,
    footer: footerEls.isNotEmpty ? footer.copyWith(elements: footerEls) : null,
    evenFill: '#f8fafc',
  );
}

LayoutDocument normalizeDocument(Map<String, dynamic> raw) {
  return LayoutDocument.fromJson(raw);
}
