import 'package:eazyreport/eazyreport.dart';
import 'package:test/test.dart';

void main() {
  group('Models & JSON serialization', () {
    test('Blank document creation & serialization', () {
      final doc = createBlankDocument('Test Invoice');
      expect(doc.title, equals('Test Invoice'));
      expect(doc.pages.length, equals(1));
      expect(doc.pages[0].reportTitle, isNotNull);

      final json = doc.toJson();
      final decoded = LayoutDocument.fromJson(json);
      expect(decoded.title, equals('Test Invoice'));
      expect(decoded.pages.length, equals(1));
    });

    test('Default base report resolution', () {
      final base = createDefaultBase('portrait');
      expect(base.description, contains('Company letterhead'));
      expect(base.parameters.any((p) => p.name == 'companyName'), isTrue);

      final blank = createBlankDocument('Customer Statement');
      final attached = attachBase(blank, base, 'base-portrait.rtpl');
      expect(attached.base, isNotNull);

      final resolved = resolveInheritance(attached);
      expect(resolved.doc.pages[0].pageHeader, isNotNull);
      expect(
          resolved.doc.parameters.any((p) => p.name == 'companyName'), isTrue);
    });

    test('Round-trip element JSON serialization', () {
      final textEl = TextElement(
        id: 't1',
        name: 'Header',
        x: 10,
        y: 15,
        w: 50,
        h: 10,
        text: 'Hello World',
        canGrow: true,
      );

      final json = textEl.toJson();
      final parsed = LayoutElement.fromJson(json) as TextElement;
      expect(parsed.id, equals('t1'));
      expect(parsed.name, equals('Header'));
      expect(parsed.text, equals('Hello World'));
      expect(parsed.canGrow, isTrue);

      final barcodeEl = BarcodeElement(
        id: 'b1',
        name: 'QR1',
        x: 0,
        y: 0,
        w: 30,
        h: 30,
        symbology: 'qrcode',
        value: 'https://example.com',
      );
      final bcJson = barcodeEl.toJson();
      final parsedBc = LayoutElement.fromJson(bcJson) as BarcodeElement;
      expect(parsedBc.symbology, equals('qrcode'));
      expect(parsedBc.value, equals('https://example.com'));
    });
  });
}
