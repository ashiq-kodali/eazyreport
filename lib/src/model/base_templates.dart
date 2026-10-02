import 'document.dart';
import 'model_helpers.dart';
import 'schema.dart';
import 'types.dart';

const companyParams = [
  ReportParameter(
      id: 'bp_name',
      name: 'companyName',
      label: 'Company name',
      type: 'string',
      defaultValue: 'Your Company Ltd.'),
  ReportParameter(
      id: 'bp_addr',
      name: 'companyAddress',
      label: 'Company address',
      type: 'string',
      defaultValue: '1 Business Street, City, Country'),
  ReportParameter(
      id: 'bp_phone',
      name: 'companyPhone',
      label: 'Phone',
      type: 'string',
      defaultValue: '+1 555 0100'),
  ReportParameter(
      id: 'bp_email',
      name: 'companyEmail',
      label: 'Email',
      type: 'string',
      defaultValue: 'info@example.com'),
  ReportParameter(
      id: 'bp_web',
      name: 'companyWebsite',
      label: 'Website',
      type: 'string',
      defaultValue: 'www.example.com'),
  ReportParameter(
      id: 'bp_reg',
      name: 'companyRegNo',
      label: 'Registration / VAT no.',
      type: 'string',
      defaultValue: 'Reg. 0000000 · VAT XX000000'),
  ReportParameter(
      id: 'bp_logo',
      name: 'companyLogo',
      label: 'Logo URL or data URI',
      type: 'string',
      defaultValue: '',
      description: 'Leave empty to print a monogram'),
];

const String accent = '#1e3a8a';

LayoutDocument createDefaultBase(String orientation) {
  final doc = createBlankDocument(orientation == 'portrait'
      ? 'Default base — A4 portrait'
      : 'Default base — A4 landscape');
  final resolved = resolvePage('A4', orientation);
  final margins = orientation == 'portrait'
      ? const PageMargins(top: 10, right: 12, bottom: 10, left: 12)
      : const PageMargins(top: 8, right: 12, bottom: 8, left: 12);

  var page = doc.pages[0].copyWith(
    name: 'Page1',
    size: 'A4',
    orientation: orientation,
    width: resolved['width'] as double,
    height: resolved['height'] as double,
    margins: margins,
    watermark: const Watermark(enabled: false, text: 'DRAFT'),
  );

  final w = bandWidth(page);
  final all = <LayoutElement>[];

  TextElement text(String t, double x, double y, double width, double height,
      [TextStyle? style]) {
    final el = createText(t, x, y, all, width, height)
        .copyWith(style: style ?? const TextStyle());
    all.add(el);
    return el;
  }

  // --- Header ---
  final headerEls = <LayoutElement>[];
  final logo = ImageElement(
    id: 'default-$orientation-CompanyLogo',
    name: 'CompanyLogo',
    x: 0,
    y: 1,
    w: 18,
    h: 18,
    path: 'params.companyLogo',
    fit: 'contain',
    hAlignImage: 'left',
    visibleExpr: 'params.companyLogo',
  );
  headerEls.add(logo);

  final mono = ShapeElement(
    id: 'default-$orientation-MonogramBox',
    name: 'MonogramBox',
    x: 0,
    y: 1,
    w: 18,
    h: 18,
    shape: 'roundrect',
    box: const BoxStyle(background: accent, borderWidth: 0, borderRadius: 3),
    visibleExpr: '{{isEmpty params.companyLogo}}',
  );
  headerEls.add(mono);

  final letter = text(
    '{{uppercase (left params.companyName 1)}}',
    0,
    1,
    18,
    18,
    const TextStyle(
        fontSize: 24, bold: true, color: '#ffffff', align: HAlign.center),
  ).copyWith(
      id: 'default-$orientation-Monogram',
      name: 'Monogram',
      visibleExpr: '{{isEmpty params.companyLogo}}');
  headerEls.add(letter);

  final name = text('{{params.companyName}}', 22, 2, w * 0.5, 8,
          const TextStyle(fontSize: 15, bold: true, color: accent))
      .copyWith(id: 'default-$orientation-CompanyName', name: 'CompanyName');
  final addr = text('{{params.companyAddress}}', 22, 10, w * 0.5, 4.5,
          const TextStyle(fontSize: 8.5, color: '#475569'))
      .copyWith(
          id: 'default-$orientation-CompanyAddress', name: 'CompanyAddress');
  final reg = text('{{params.companyRegNo}}', 22, 14.5, w * 0.5, 4.5,
          const TextStyle(fontSize: 7.5, color: '#94a3b8'))
      .copyWith(id: 'default-$orientation-CompanyRegNo', name: 'CompanyRegNo');
  headerEls.addAll([name, addr, reg]);

  final cw = orientation == 'portrait' ? 60.0 : 80.0;
  final phone = text('{{params.companyPhone}}', w - cw, 3, cw, 4.5,
          const TextStyle(fontSize: 8.5, color: '#475569', align: HAlign.right))
      .copyWith(id: 'default-$orientation-CompanyPhone', name: 'CompanyPhone');
  final email = text('{{params.companyEmail}}', w - cw, 7.5, cw, 4.5,
          const TextStyle(fontSize: 8.5, color: '#475569', align: HAlign.right))
      .copyWith(id: 'default-$orientation-CompanyEmail', name: 'CompanyEmail');
  final web = text(
          '{{params.companyWebsite}}',
          w - cw,
          12,
          cw,
          4.5,
          const TextStyle(
              fontSize: 8.5, color: accent, align: HAlign.right, bold: true))
      .copyWith(
          id: 'default-$orientation-CompanyWebsite',
          name: 'CompanyWebsite',
          hyperlink: 'https://{{params.companyWebsite}}');
  headerEls.addAll([phone, email, web]);

  final rule = LineElement(
    id: 'default-$orientation-HeaderRule',
    name: 'HeaderRule',
    x: 0,
    y: 21,
    w: w,
    h: 2,
    thickness: 1.5,
    color: accent,
  );
  headerEls.add(rule);

  final header = Band(
    id: 'default-$orientation-pageHeader',
    type: 'pageHeader',
    name: 'Letterhead',
    height: 24.0,
    printOnFirstPage: true,
    elements: headerEls,
  );

  // --- Title ---
  final titleEls = <LayoutElement>[
    text('{{ReportTitle}}', 0, 2, w * 0.6, 9,
            const TextStyle(fontSize: 16, bold: true, color: '#0f172a'))
        .copyWith(
            id: 'default-$orientation-DocumentTitle', name: 'DocumentTitle'),
    text('{{formatDate Now "d MMMM yyyy"}}', w - 60, 3, 60, 7,
            const TextStyle(fontSize: 9, color: '#64748b', align: HAlign.right))
        .copyWith(
            id: 'default-$orientation-DocumentDate', name: 'DocumentDate'),
  ];
  final title = Band(
    id: 'default-$orientation-reportTitle',
    type: 'reportTitle',
    name: 'Document title',
    height: 14.0,
    elements: titleEls,
  );

  // --- Footer ---
  final footerEls = <LayoutElement>[
    LineElement(
        id: 'default-$orientation-FooterRule',
        name: 'FooterRule',
        x: 0,
        y: 0,
        w: w,
        h: 1.5,
        thickness: 0.5,
        color: '#cbd5e1'),
    text('{{params.companyName}} · {{params.companyAddress}}', 0, 2.5, w * 0.45,
            5, const TextStyle(fontSize: 7, color: '#64748b', wrap: false))
        .copyWith(
            id: 'default-$orientation-FooterCompany', name: 'FooterCompany'),
    text(
            'Printed {{formatDate Now "dd/MM/yyyy HH:mm"}}',
            w / 2 - 30,
            2.5,
            60,
            5,
            const TextStyle(
                fontSize: 7, color: '#94a3b8', align: HAlign.center))
        .copyWith(
            id: 'default-$orientation-FooterPrinted', name: 'FooterPrinted'),
    text(
            'Page {{Page}} of {{TotalPages}}',
            w - 40,
            2.5,
            40,
            5,
            const TextStyle(
                fontSize: 7.5,
                color: '#475569',
                align: HAlign.right,
                bold: true))
        .copyWith(
            id: 'default-$orientation-FooterPageNo', name: 'FooterPageNo'),
  ];
  final footer = Band(
    id: 'default-$orientation-pageFooter',
    type: 'pageFooter',
    name: 'Footer',
    height: 9.0,
    elements: footerEls,
  );

  page = page.copyWith(
    id: 'default-$orientation-page1',
    pageHeader: header,
    reportTitle: title,
    pageFooter: footer,
  );

  return doc.copyWith(
    description:
        'Company letterhead: header with logo and contact details on every page, footer with page numbers.',
    parameters: companyParams,
    pages: [page],
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-01T00:00:00.000Z',
  );
}
