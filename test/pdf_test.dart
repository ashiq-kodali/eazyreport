import 'dart:typed_data';
import 'package:eazyreport/eazyreport.dart';
import 'package:test/test.dart';

void main() {
  group('EazyReport Native PDF Generation', () {
    test(
        'Generates valid PDF document with header, data band, barcode, and watermark',
        () async {
      final doc = createBlankDocument('Sales Invoice');

      final titleBand = Band(
        id: 'title1',
        type: 'reportTitle',
        name: 'Invoice Header',
        height: 35,
        elements: [
          const TextElement(
            id: 'title',
            name: 'TitleText',
            x: 10,
            y: 5,
            w: 120,
            h: 12,
            text: 'INVOICE: {{invoice_no}}',
            style: TextStyle(fontSize: 18, bold: true),
          ),
          const ShapeElement(
            id: 'accent_line',
            name: 'Line',
            x: 10,
            y: 20,
            w: 170,
            h: 1,
            shape: 'rect',
            box: BoxStyle(background: '#2563eb'),
          ),
          const BarcodeElement(
            id: 'qr',
            name: 'InvoiceQR',
            x: 140,
            y: 5,
            w: 25,
            h: 25,
            symbology: 'QRCode',
            value: 'https://eazyreport.in/inv/{{invoice_no}}',
          ),
        ],
      );

      final dataBand = DataBand(
        id: 'items_band',
        name: 'Item Rows',
        height: 10,
        dataPath: 'items',
        alias: 'item',
        elements: [
          const FieldElement(
            id: 'item_name',
            name: 'Name',
            x: 10,
            y: 0,
            w: 90,
            h: 10,
            path: 'item.name',
            style: TextStyle(fontSize: 10),
          ),
          const FieldElement(
            id: 'item_qty',
            name: 'Qty',
            x: 105,
            y: 0,
            w: 25,
            h: 10,
            path: 'item.qty',
            dataType: 'number',
            style: TextStyle(fontSize: 10, align: HAlign.right),
          ),
          const FieldElement(
            id: 'item_price',
            name: 'Price',
            x: 135,
            y: 0,
            w: 35,
            h: 10,
            path: 'item.price',
            dataType: 'currency',
            style: TextStyle(fontSize: 10, align: HAlign.right),
          ),
        ],
      );

      final page = doc.pages[0].copyWith(
        watermark: const Watermark(
          enabled: true,
          text: 'PAID',
          opacity: 0.15,
          angle: 45,
        ),
        reportTitle: titleBand,
        dataBands: [dataBand],
      );

      final fullDoc = doc.copyWith(pages: [page]);

      final data = {
        'invoice_no': 'INV-2026-001',
        'items': [
          {'name': 'Thermal Printer 80mm', 'qty': 2, 'price': 149.99},
          {'name': 'Roll Paper (Box of 50)', 'qty': 5, 'price': 29.50},
          {'name': 'Barcode Scanner 2D USB', 'qty': 1, 'price': 89.00},
        ],
      };

      // 1. Test builder toPdf()
      final builder = ReportBuilder(fullDoc).data(data);
      final Uint8List pdfBytes = await builder.toPdf();

      expect(pdfBytes.isNotEmpty, isTrue);
      // Valid PDF magic header %PDF-
      expect(String.fromCharCodes(pdfBytes.sublist(0, 5)), '%PDF-');
      expect(pdfBytes.length, greaterThan(1000));

      // 2. Test builder toPdfDocument()
      final pdfDoc = builder.toPdfDocument();
      expect(pdfDoc.document.pdfPageList.pages.length, equals(1));

      // 3. Test top-level getReportPdf API
      final Uint8List topLevelBytes = await getReportPdf(fullDoc, data);
      expect(topLevelBytes.isNotEmpty, isTrue);
      expect(String.fromCharCodes(topLevelBytes.sublist(0, 5)), '%PDF-');
    });

    test('Generates multi-page PDF document correctly with pagination',
        () async {
      final doc = createBlankDocument('Inventory Report');
      final rows = List.generate(
        80,
        (i) => {
          'code': 'SKU-${1000 + i}',
          'desc': 'Product Item Number $i',
          'qty': i + 1,
          'cost': (i + 1) * 12.5
        },
      );

      final dataBand = DataBand(
        id: 'inventory_data',
        name: 'Inventory',
        height: 12,
        dataPath: 'items',
        alias: 'item',
        elements: [
          const FieldElement(
            id: 'f_code',
            name: 'Code',
            x: 10,
            y: 0,
            w: 30,
            h: 12,
            path: 'item.code',
          ),
          const FieldElement(
            id: 'f_desc',
            name: 'Description',
            x: 45,
            y: 0,
            w: 80,
            h: 12,
            path: 'item.desc',
          ),
          const FieldElement(
            id: 'f_qty',
            name: 'Qty',
            x: 130,
            y: 0,
            w: 25,
            h: 12,
            path: 'item.qty',
            dataType: 'number',
          ),
        ],
      );

      final page = doc.pages[0].copyWith(
        dataBands: [dataBand],
      );

      final fullDoc = doc.copyWith(pages: [page]);
      final pdfDoc = getReportPdfDocument(fullDoc, {'items': rows});

      expect(pdfDoc.document.pdfPageList.pages.length, greaterThan(1));
    });
  });
}
