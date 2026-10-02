import 'dart:io';
import 'dart:typed_data';
import 'package:eazyreport/eazyreport.dart';
import 'package:test/test.dart';

void main() {
  test('Renders test_invoice.rtpl with real dataset to HTML and PDF', () async {
    final possiblePaths = [
      'test/fixtures/test_invoice.rtpl',
      'fixtures/test_invoice.rtpl',
      '../test_invoice.rtpl',
      'test_invoice.rtpl',
    ];
    String? foundPath;
    for (final p in possiblePaths) {
      if (File(p).existsSync()) {
        foundPath = p;
        break;
      }
    }

    expect(foundPath, isNotNull, reason: 'Could not find test_invoice.rtpl in test/fixtures');
    final rtplFile = File(foundPath!);
    final rtplJson = await rtplFile.readAsString();
    final doc = loadTemplate(rtplJson);
    expect(doc.title, isNotEmpty);

    final data = {
      'invoice': {
        'number': 'INV-2026-88219',
        'issueDate': '2026-09-15',
        'dueDate': '2026-10-15',
        'currency': 'USD',
        'status': 'UNPAID',
        'subtotal': 5450.00,
        'taxRate': 8.5,
        'taxAmount': 463.25,
        'discountAmount': 100.00,
        'total': 5813.25,
        'notes':
            'Payment due within 30 days. Thank you for partnering with us!',
        'terms':
            'Net 30 days. Late fees of 1.5% per month applicable after due date.',
      },
      'customer': {
        'name': 'Eleanor Vance',
        'company': 'Starlight Innovations Ltd.',
        'email': 'e.vance@starlight-tech.com',
        'phone': '+1 (555) 349-9210',
        'taxId': 'US-94829104',
        'address': '742 Evergreen Terrace, Suite 400',
        'city': 'San Francisco, CA',
        'zipCode': '94105',
        'country': 'United States',
      },
      'sender': {
        'name': 'Apex HyperScale Solutions Inc.',
        'taxId': 'EIN-83-2947192',
        'email': 'billing@apexsolutions.io',
        'phone': '+1 (800) 555-0199',
        'address': '100 Montgomery Street, Floor 28',
        'city': 'San Francisco, CA 94104',
        'bankName': 'Silicon Valley Reserve Bank',
        'iban': 'US94 SVBR 0001 2345 6789 00',
        'swift': 'SVBRUS33',
        'website': 'https://www.apexsolutions.io',
      },
      'items': [
        {
          'sku': 'SRV-ARCH-01',
          'description':
              'Cloud Architecture Audit & High-Availability Consulting (40 hrs)',
          'quantity': 1,
          'unitPrice': 3200.00,
          'taxPercent': 8.5,
          'discount': 0,
          'total': 3200.00,
        },
        {
          'sku': 'LIC-ENT-05',
          'description':
              'Antigravity Realtime Rendering Engine Enterprise License (Q3)',
          'quantity': 3,
          'unitPrice': 650.00,
          'taxPercent': 8.5,
          'discount': 100.00,
          'total': 1850.00,
        },
        {
          'sku': 'SPT-PRI-247',
          'description':
              'Mission-Critical 24/7 Priority SLA On-Call Support Package',
          'quantity': 1,
          'unitPrice': 400.00,
          'taxPercent': 8.5,
          'discount': 0,
          'total': 400.00,
        },
      ],
      'shipping': {
        'carrier': 'FedEx International Priority',
        'trackingNumber': 'FX-992-019-3841',
        'deliveryDate': '2026-09-18',
        'recipientName': 'Eleanor Vance',
        'address': '742 Evergreen Terrace, Suite 400, San Francisco, CA 94105',
      },
    };

    final params = {
      'paymentTerms': 'Net 30 Days',
      'supportEmail': 'support@apexsolutions.io',
      'applyDiscount': true,
    };

    final builder = ReportBuilder.fromTemplate(doc)
      ..data(data)
      ..params(params);

    final pageCount = builder.pageCount();
    print('Rendered Page Count: $pageCount');
    expect(pageCount, greaterThanOrEqualTo(1));

    final html = builder.toHtml();
    expect(html, contains('INV-2026-88219'));
    expect(html, contains('Apex HyperScale Solutions Inc.'));
    expect(html, contains('Eleanor Vance'));

    final Uint8List pdfBytes = await builder.toPdf();
    expect(pdfBytes.isNotEmpty, isTrue);
    expect(String.fromCharCodes(pdfBytes.sublist(0, 5)), '%PDF-');
    print('Generated PDF Bytes: ${pdfBytes.length}');
  });
}
