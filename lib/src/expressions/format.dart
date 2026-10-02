import 'dart:convert';
import 'package:intl/intl.dart';
import '../model/types.dart';

const months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

const days = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday'
];

String formatDatePattern(DateTime d, String pattern) {
  String pad(int n) => n.toString().padLeft(2, '0');
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;

  final tokens = <String, String>{
    'yyyy': d.year.toString(),
    'yy': d.year.toString().substring(d.year.toString().length - 2),
    'MMMM': months[d.month - 1],
    'MMM': months[d.month - 1].substring(0, 3),
    'MM': pad(d.month),
    'M': d.month.toString(),
    'dddd': days[d.weekday - 1],
    'ddd': days[d.weekday - 1].substring(0, 3),
    'dd': pad(d.day),
    'd': d.day.toString(),
    'HH': pad(d.hour),
    'H': d.hour.toString(),
    'hh': pad(h12),
    'h': h12.toString(),
    'mm': pad(d.minute),
    'ss': pad(d.second),
    'tt': d.hour < 12 ? 'AM' : 'PM',
  };

  final regex =
      RegExp(r'yyyy|yy|MMMM|MMM|MM|M|dddd|ddd|dd|d|HH|H|hh|h|mm|ss|tt');
  return pattern.replaceAllMapped(
      regex, (m) => tokens[m.group(0)!] ?? m.group(0)!);
}

DateTime? toDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String) {
    if (value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }
  return null;
}

String formatNumber(dynamic value, [int decimals = 2, bool thousands = true]) {
  if (value == null || value == '') return '';
  final num? n = num.tryParse(value.toString());
  if (n == null) return '';

  final format = NumberFormat.currency(
    locale: 'en_US',
    symbol: '',
    decimalDigits: decimals,
  );
  if (!thousands) {
    format.turnOffGrouping();
  }
  return format.format(n).trim();
}

String formatCurrency(dynamic value,
    [String currency = 'USD', int decimals = 2]) {
  if (value == null || value == '') return '';
  final num? n = num.tryParse(value.toString());
  if (n == null) return '';

  try {
    final cur = RegExp(r'^[A-Za-z]{3}$').hasMatch(currency)
        ? currency.toUpperCase()
        : 'USD';
    final format =
        NumberFormat.simpleCurrency(name: cur, decimalDigits: decimals);
    return format.format(n);
  } catch (_) {
    return n.toStringAsFixed(decimals);
  }
}

String resolveFormatKind(ValueFormat f, String dataType) {
  if (f.format != 'auto') return f.format;
  if (dataType == 'currency') return 'currency';
  if (dataType == 'date') return 'date';
  if (dataType == 'boolean') return 'boolean';
  return 'text';
}

String formatValue(dynamic value, ValueFormat f, String dataType) {
  if (value == null) return '';
  switch (resolveFormatKind(f, dataType)) {
    case 'number':
      return formatNumber(value, f.decimals, f.thousands);
    case 'currency':
      return formatCurrency(value, f.currency, f.decimals);
    case 'percent':
      final num? n = num.tryParse(value.toString());
      if (n == null) return value.toString();
      return '${formatNumber(n * 100, f.decimals, f.thousands)}%';
    case 'date':
      final d = toDate(value);
      return d != null
          ? formatDatePattern(
              d, f.datePattern.isNotEmpty ? f.datePattern : 'dd/MM/yyyy')
          : value.toString();
    case 'boolean':
      final parts = f.booleanText.split('|');
      final yes = parts.isNotEmpty ? parts[0] : 'Yes';
      final no = parts.length > 1 ? parts[1] : 'No';
      final truthy =
          value == true || value == 'true' || value == 1 || value == '1';
      return truthy ? yes : no;
    default:
      return value is Map || value is List
          ? jsonEncode(value)
          : value.toString();
  }
}

String escapeHtml(String s) {
  return s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
