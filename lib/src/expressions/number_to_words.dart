const ones = [
  '',
  'One',
  'Two',
  'Three',
  'Four',
  'Five',
  'Six',
  'Seven',
  'Eight',
  'Nine',
  'Ten',
  'Eleven',
  'Twelve',
  'Thirteen',
  'Fourteen',
  'Fifteen',
  'Sixteen',
  'Seventeen',
  'Eighteen',
  'Nineteen'
];

const tens = [
  '',
  '',
  'Twenty',
  'Thirty',
  'Forty',
  'Fifty',
  'Sixty',
  'Seventy',
  'Eighty',
  'Ninety'
];

const scales = ['', 'Thousand', 'Million', 'Billion', 'Trillion'];

String numberToWords(num n) {
  if (n.isNaN || n.isInfinite) return '';
  final whole = n.abs().floor();
  final cents = ((n.abs() - whole) * 100).round();

  String chunk(int x) {
    final parts = <String>[];
    if (x >= 100) {
      parts.add('${ones[x ~/ 100]} Hundred');
      x %= 100;
    }
    if (x >= 20) {
      final t = tens[x ~/ 10];
      final o = x % 10 != 0 ? '-${ones[x % 10]}' : '';
      parts.add('$t$o');
    } else if (x > 0) {
      parts.add(ones[x]);
    }
    return parts.join(' ');
  }

  var rest = whole;
  var i = 0;
  final words = <String>[];
  if (rest == 0) {
    words.add('Zero');
  }
  while (rest > 0) {
    final c = rest % 1000;
    if (c != 0) {
      final s = scales[i].isNotEmpty ? ' ${scales[i]}' : '';
      words.insert(0, '${chunk(c)}$s');
    }
    rest ~/= 1000;
    i++;
  }

  final prefix = n < 0 ? 'Minus ' : '';
  final centsText =
      cents > 0 ? ' and ${cents.toString().padLeft(2, '0')}/100' : '';
  return '$prefix${words.join(' ')}$centsText';
}
