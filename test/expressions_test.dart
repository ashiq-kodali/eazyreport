import 'package:eazyreport/eazyreport.dart';
import 'package:test/test.dart';

void main() {
  group('Expressions & Helpers', () {
    test('Basic property extraction', () {
      final ctx = {
        'customer': {'name': 'Alice', 'id': 101},
        'total': 250.5,
      };

      expect(evalText('Hello {{customer.name}}', ctx), equals('Hello Alice'));
      expect(evalText('ID: {{customer.id}}', ctx), equals('ID: 101'));
      expect(evalValue('{{total}}', ctx), equals(250.5));
    });

    test('Helper functions - formatCurrency, formatNumber, formatDate', () {
      final ctx = {
        'amount': 1234.56,
        'dateStr': '2026-05-12T10:30:00Z',
      };

      expect(evalText('{{formatCurrency amount "USD"}}', ctx),
          contains('1,234.56'));
      expect(evalText('{{formatNumber amount 1}}', ctx), equals('1,234.6'));
      expect(evalText('{{formatDate dateStr "dd/MM/yyyy"}}', ctx),
          equals('12/05/2026'));
    });

    test('Conditional logic helpers - eq, ne, gt, gte, iif', () {
      final ctx = {
        'qty': 15,
        'status': 'PAID',
      };

      expect(evalCondition('{{gt qty 10}}', ctx), isTrue);
      expect(evalCondition('{{lt qty 10}}', ctx), isFalse);
      expect(evalCondition('{{eq status "PAID"}}', ctx), isTrue);
      expect(evalCondition('{{ne status "PENDING"}}', ctx), isTrue);
      expect(
          evalText('{{iif (gt qty 10) "Bulk" "Single"}}', ctx), equals('Bulk'));
    });

    test('Math helpers - add, sub, mul, div, round', () {
      final ctx = {'a': 20, 'b': 5};

      expect(evalText('{{add a b}}', ctx), equals('25'));
      expect(evalText('{{sub a b}}', ctx), equals('15'));
      expect(evalText('{{mul a b}}', ctx), equals('100'));
      expect(evalText('{{div a b}}', ctx), equals('4'));
      expect(evalText('{{math a "+" b}}', ctx), equals('25'));
    });

    test(
        'String helpers - uppercase, lowercase, titlecase, left, right, numberToWords',
        () {
      final ctx = {'title': 'eazy report engine', 'amount': 1520};

      expect(
          evalText('{{uppercase title}}', ctx), equals('EAZY REPORT ENGINE'));
      expect(evalText('{{left title 4}}', ctx), equals('eazy'));
      expect(evalText('{{numberToWords amount}}', ctx),
          equals('One Thousand Five Hundred Twenty'));
    });

    test('Array helpers - sum, avg, count', () {
      final ctx = {
        'items': [
          {'price': 100},
          {'price': 200},
          {'price': 300},
        ]
      };

      expect(evalText('{{count items}}', ctx), equals('3'));
      expect(evalText('{{sum items "price"}}', ctx), equals('600'));
      expect(evalText('{{avg items "price"}}', ctx), equals('200'));
    });
  });
}
