import 'package:eazyreport/eazyreport.dart';
import 'package:test/test.dart';

void main() {
  group('ReportBuilder API', () {
    test('Fluent builder API works smoothly', () {
      final doc = createBlankDocument('Order Receipt');

      final builder = ReportBuilder.fromTemplate(doc)
        ..data({
          'orderId': 'ORD-999',
          'items': [
            {'sku': 'A1', 'name': 'Item 1'},
            {'sku': 'B2', 'name': 'Item 2'},
          ],
        })
        ..param('store', 'Main Street Outlet')
        ..copies(1)
        ..title('Receipt #999');

      final html = builder.toHtml();
      expect(html, contains('Receipt #999'));
      expect(builder.pageCount(), equals(1));
    });

    test('getReportHtml and countReportPages top-level functions', () {
      final doc = createBlankDocument('Packing Slip');
      final pageCount = countReportPages(doc, {'order': 1});
      expect(pageCount, equals(1));

      final html = getReportHtml(doc, {'order': 1}, {'company': 'Acme'});
      expect(html, contains('<!DOCTYPE html>'));
      expect(html, contains('Packing Slip'));
    });
  });
}
