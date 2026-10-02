import 'package:eazyreport/eazyreport.dart';

void main() async {
  print('========================================');
  print('eazyreport (Pure Dart Package Demo)');
  print('========================================\n');

  // 1. Create a blank template or load from .rtpl JSON
  final doc = createBlankDocument('Invoice Demo');
  final page = doc.pages[0];

  // 2. Add a Report Title band with company details and Payment QR Code
  final titleBand = Band(
    id: 'report_title',
    type: 'reportTitle',
    name: 'Report Title',
    height: 45.0,
    elements: [
      TextElement(
        id: 't_company',
        name: 'CompanyName',
        x: 0,
        y: 2,
        w: 100,
        h: 8,
        text: '{{params.companyName}}',
        style: const TextStyle(fontSize: 16, bold: true, color: '#1e3a8a'),
      ),
      TextElement(
        id: 't_inv_no',
        name: 'InvoiceNum',
        x: 0,
        y: 12,
        w: 100,
        h: 6,
        text:
            'Invoice: #{{invoice.number}} (Date: {{formatDate invoice.date "dd/MM/yyyy"}})',
        style: const TextStyle(fontSize: 10, color: '#475569'),
      ),
      TextElement(
        id: 't_bill_to',
        name: 'Customer',
        x: 0,
        y: 20,
        w: 100,
        h: 6,
        text: 'Billed to: {{customer.name}} ({{customer.city}})',
        style: const TextStyle(fontSize: 10, bold: true),
      ),
      // Pure Dart QR Code (rendered via package:barcode)
      BarcodeElement(
        id: 'bc_qr',
        name: 'PaymentQR',
        x: 140,
        y: 2,
        w: 35,
        h: 35,
        symbology: 'qrcode',
        value: 'PAYMENT:INV-2026-001;TOTAL:1750',
      ),
    ],
  );

  // 3. Add a Data Band with repeating line items
  final dataBand = DataBand(
    id: 'data_items',
    name: 'Items',
    height: 7.0,
    dataPath: 'items',
    alias: 'item',
    header: Band(
      id: 'hdr_items',
      type: 'dataHeader',
      name: 'Items Header',
      height: 7.0,
      fill: '#e2e8f0',
      elements: [
        TextElement(
            id: 'h_desc',
            name: 'HDesc',
            x: 0,
            y: 1,
            w: 100,
            h: 5,
            text: 'Description',
            style: const TextStyle(bold: true, fontSize: 9)),
        TextElement(
            id: 'h_qty',
            name: 'HQty',
            x: 100,
            y: 1,
            w: 30,
            h: 5,
            text: 'Qty',
            style:
                const TextStyle(bold: true, fontSize: 9, align: HAlign.right)),
        TextElement(
            id: 'h_price',
            name: 'HPrice',
            x: 130,
            y: 1,
            w: 40,
            h: 5,
            text: 'Total',
            style:
                const TextStyle(bold: true, fontSize: 9, align: HAlign.right)),
      ],
    ),
    elements: [
      TextElement(
          id: 'f_desc',
          name: 'Desc',
          x: 0,
          y: 0.5,
          w: 100,
          h: 6,
          text: '{{item.description}}',
          style: const TextStyle(fontSize: 9)),
      TextElement(
          id: 'f_qty',
          name: 'Qty',
          x: 100,
          y: 0.5,
          w: 30,
          h: 6,
          text: '{{item.qty}}',
          style: const TextStyle(fontSize: 9, align: HAlign.right)),
      TextElement(
          id: 'f_total',
          name: 'LineTotal',
          x: 130,
          y: 0.5,
          w: 40,
          h: 6,
          text: '{{formatCurrency (mul item.qty item.price) "USD"}}',
          style: const TextStyle(fontSize: 9, align: HAlign.right)),
    ],
    footer: Band(
      id: 'ftr_items',
      type: 'dataFooter',
      name: 'Items Footer',
      height: 8.0,
      elements: [
        TextElement(
            id: 'f_lbl',
            name: 'TotalLabel',
            x: 80,
            y: 1,
            w: 50,
            h: 6,
            text: 'Total Amount:',
            style:
                const TextStyle(bold: true, fontSize: 10, align: HAlign.right)),
        TextElement(
            id: 'f_sum',
            name: 'TotalSum',
            x: 130,
            y: 1,
            w: 40,
            h: 6,
            text: '{{formatCurrency (sum items "price") "USD"}}',
            style: const TextStyle(
                bold: true,
                fontSize: 10,
                align: HAlign.right,
                color: '#1e3a8a')),
      ],
    ),
  );

  // 4. Page Footer with automatic 2-pass page numbering
  final pageFooter = Band(
    id: 'page_footer',
    type: 'pageFooter',
    name: 'Footer',
    height: 8.0,
    elements: [
      TextElement(
        id: 't_page_no',
        name: 'PageNo',
        x: 100,
        y: 2,
        w: 70,
        h: 5,
        text: 'Page {{Page}} of {{TotalPages}}',
        style:
            const TextStyle(fontSize: 8, color: '#64748b', align: HAlign.right),
      ),
    ],
  );

  final invoiceTemplate = doc.copyWith(
    pages: [
      page.copyWith(
        reportTitle: titleBand,
        dataBands: [dataBand],
        pageFooter: pageFooter,
      ),
    ],
  );

  // 5. Input dataset
  final invoiceData = {
    'invoice': {
      'number': 'INV-2026-001',
      'date': '2026-10-01T00:00:00Z',
    },
    'customer': {
      'name': 'Global Tech Industries',
      'city': 'San Francisco',
    },
    'items': [
      {
        'description': 'Flutter Architecture Migration',
        'qty': 1,
        'price': 1200
      },
      {'description': 'Pure Dart Reporting Engine', 'qty': 1, 'price': 550},
    ],
  };

  final reportParams = {
    'companyName': 'Antigravity Enterprise Services',
  };

  // 6. Build report using fluent builder
  final builder = ReportBuilder.fromTemplate(invoiceTemplate)
    ..data(invoiceData)
    ..params(reportParams);

  print('Calculated Total Pages: ${builder.pageCount()}');

  // 7. Get printable HTML (for Web, WebView, or browser window.print())
  final html = builder.toHtml();
  print('Generated HTML Length: ${html.length} characters');
  print('HTML Document starts with:\n${html.substring(0, 160)}...\n');

  // 8. Get Native Binary PDF bytes (for Flutter printing or file saving)
  final pdfBytes = await builder.toPdf();
  print('Generated PDF Bytes: ${pdfBytes.length} bytes');
  print('PDF Magic Header: ${String.fromCharCodes(pdfBytes.sublist(0, 5))}');

  print('\nPrinting in Flutter:');
  print('  import "package:printing/printing.dart";');
  print(
      '  await Printing.layoutPdf(onLayout: (format) async => await builder.toPdf());');
  print('\nSaving to disk in Dart Server / CLI:');
  print('  await File("invoice.pdf").writeAsBytes(pdfBytes);');

  print('\nDone! Package is 100% Pure Dart with zero JavaScript dependencies.');
}
