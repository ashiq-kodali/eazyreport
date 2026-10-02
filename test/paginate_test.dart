import 'package:eazyreport/eazyreport.dart';
import 'package:test/test.dart';

void main() {
  group('Pagination & Report Rendering', () {
    test('Renders simple document with title and data rows', () {
      final doc = createBlankDocument('Sales Report');
      final page = doc.pages[0];

      final titleBand = Band(
        id: 'title1',
        type: 'reportTitle',
        name: 'Title',
        height: 20,
        elements: [
          TextElement(
              id: 'el_title',
              name: 'Title',
              x: 0,
              y: 0,
              w: 100,
              h: 10,
              text: 'Sales Report: {{params.quarter}}'),
        ],
      );

      final dataBand = DataBand(
        id: 'data1',
        name: 'Sales Data',
        height: 8,
        dataPath: 'sales',
        alias: 'sale',
        elements: [
          TextElement(
              id: 'el_rep',
              name: 'Rep',
              x: 0,
              y: 0,
              w: 50,
              h: 8,
              text: '{{sale.rep}}'),
          FieldElement(
              id: 'el_amount',
              name: 'Amount',
              x: 60,
              y: 0,
              w: 40,
              h: 8,
              path: 'sale.amount',
              dataType: 'currency'),
        ],
      );

      final updatedDoc = doc.copyWith(
        pages: [
          page.copyWith(
            reportTitle: titleBand,
            dataBands: [dataBand],
          ),
        ],
      );

      final data = {
        'params': {'quarter': 'Q3 2026'},
        'sales': [
          {'rep': 'Alice', 'amount': 1500},
          {'rep': 'Bob', 'amount': 2400},
          {'rep': 'Charlie', 'amount': 1800},
        ],
      };

      final pages = renderReport(updatedDoc, data);
      expect(pages.length, equals(1));
      expect(pages[0].html, contains('Sales Report: Q3 2026'));
      expect(pages[0].html, contains('Alice'));
      expect(pages[0].html, contains('Bob'));
      expect(pages[0].html, contains('Charlie'));
    });

    test('Two-pass pagination resolves TotalPages', () {
      final doc = createBlankDocument('Invoice');
      final page = doc.pages[0];

      final footer = Band(
        id: 'footer1',
        type: 'pageFooter',
        name: 'Footer',
        height: 10,
        elements: [
          TextElement(
              id: 'pg',
              name: 'PageNo',
              x: 0,
              y: 0,
              w: 60,
              h: 5,
              text: 'Page {{Page}} of {{TotalPages}}'),
        ],
      );

      final updatedDoc = doc.copyWith(
        pages: [page.copyWith(pageFooter: footer)],
      );

      final html = renderReportHtml(updatedDoc, {});
      expect(html, contains('Page 1 of 1'));
    });

    test('Barcode rendering generates SVG in HTML', () {
      final doc = createBlankDocument('QR Test');
      final page = doc.pages[0];

      final title = Band(
        id: 't1',
        type: 'reportTitle',
        name: 'Title',
        height: 40,
        elements: [
          BarcodeElement(
            id: 'bc1',
            name: 'QR',
            x: 10,
            y: 5,
            w: 30,
            h: 30,
            symbology: 'qrcode',
            value: 'https://eazyreport.in',
          ),
        ],
      );

      final updatedDoc =
          doc.copyWith(pages: [page.copyWith(reportTitle: title)]);
      final html = renderReportHtml(updatedDoc, {});
      expect(html, contains('<svg'));
      expect(html, contains('preserveAspectRatio'));
    });

    test('Vector chart rendering generates SVG in HTML', () {
      final doc = createBlankDocument('Chart Test');
      final page = doc.pages[0];

      final title = Band(
        id: 't1',
        type: 'reportTitle',
        name: 'Title',
        height: 60,
        elements: [
          ChartElement(
            id: 'chart1',
            name: 'MonthlyChart',
            x: 0,
            y: 0,
            w: 100,
            h: 50,
            chartType: 'column',
            dataPath: 'revenue',
            labelField: 'month',
            valueField: 'val',
          ),
        ],
      );

      final updatedDoc =
          doc.copyWith(pages: [page.copyWith(reportTitle: title)]);
      final html = renderReportHtml(updatedDoc, {
        'revenue': [
          {'month': 'Jan', 'val': 100},
          {'month': 'Feb', 'val': 150},
          {'month': 'Mar', 'val': 120},
        ]
      });

      expect(html, contains('<svg'));
      expect(html, contains('Jan'));
      expect(html, contains('Feb'));
      expect(html, contains('Mar'));
    });
  });
}
