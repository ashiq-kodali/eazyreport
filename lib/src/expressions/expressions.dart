import 'dart:math' as math;
import 'format.dart';
import 'number_to_words.dart';

dynamic getPath(dynamic obj, String path) {
  if (path.isEmpty || obj == null) return null;
  final parts = path.split('.');
  dynamic curr = obj;
  for (final part in parts) {
    if (curr == null) return null;
    if (curr is Map) {
      curr = curr[part];
    } else if (curr is List) {
      final idx = int.tryParse(part);
      if (idx != null && idx >= 0 && idx < curr.length) {
        curr = curr[idx];
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
  return curr;
}

num _num(dynamic v) {
  if (v == null || v == '') return 0;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? 0;
}

final Map<String, Function> expressionHelpers = {
  'formatCurrency': (dynamic v, [dynamic cur, dynamic dec]) => formatCurrency(
      v, cur is String ? cur : 'USD', dec is num ? dec.toInt() : 2),
  'formatNumber': (dynamic v, [dynamic dec, dynamic thousands]) => formatNumber(
      v, dec is num ? dec.toInt() : 2, thousands is bool ? thousands : true),
  'formatDate': (dynamic v, [dynamic pattern]) {
    final d = toDate(v);
    if (d == null) return v?.toString() ?? '';
    return formatDatePattern(
        d, pattern is String && pattern.isNotEmpty ? pattern : 'dd/MM/yyyy');
  },
  'formatPercent': (dynamic v, [dynamic dec]) =>
      '${formatNumber(_num(v) * 100, dec is num ? dec.toInt() : 0)}%',
  'eq': (dynamic a, dynamic b) {
    if (a is num && b is num) return a == b;
    final na = num.tryParse(a?.toString() ?? '');
    final nb = num.tryParse(b?.toString() ?? '');
    if (na != null && nb != null) return na == nb;
    return (a?.toString() ?? '') == (b?.toString() ?? '');
  },
  'ne': (dynamic a, dynamic b) => !expressionHelpers['eq']!(a, b),
  'gt': (dynamic a, dynamic b) => _num(a) > _num(b),
  'gte': (dynamic a, dynamic b) => _num(a) >= _num(b),
  'lt': (dynamic a, dynamic b) => _num(a) < _num(b),
  'lte': (dynamic a, dynamic b) => _num(a) <= _num(b),
  'and': (List<dynamic> args) => args.every(_isTruthy),
  'or': (List<dynamic> args) => args.any(_isTruthy),
  'not': (dynamic a) => !_isTruthy(a),
  'iif': (dynamic c, dynamic a, [dynamic b]) => _isTruthy(c) ? a : (b ?? ''),
  'isEmpty': (dynamic v) =>
      v == null ||
      v == '' ||
      (v is Iterable && v.isEmpty) ||
      (v is Map && v.isEmpty),
  'default': (dynamic v, dynamic d) =>
      (v == null || v == '' || (v is Iterable && v.isEmpty)) ? d : v,
  'math': (dynamic a, String op, dynamic b) {
    final l = _num(a);
    final r = _num(b);
    switch (op) {
      case '+':
        return l + r;
      case '-':
        return l - r;
      case '*':
        return l * r;
      case '/':
        return r != 0 ? l / r : 0;
      case '%':
        return r != 0 ? l % r : 0;
      default:
        return 0;
    }
  },
  'add': (dynamic a, dynamic b) => _num(a) + _num(b),
  'sub': (dynamic a, dynamic b) => _num(a) - _num(b),
  'mul': (dynamic a, dynamic b) => _num(a) * _num(b),
  'div': (dynamic a, dynamic b) {
    if (_num(b) == 0) return 0;
    final res = _num(a) / _num(b);
    return res % 1 == 0 ? res.toInt() : res;
  },
  'round': (dynamic a, [dynamic d]) {
    final places = d is num ? d.toInt() : 0;
    final p = math.pow(10, places);
    final res = (_num(a) * p).round() / p;
    return res % 1 == 0 ? res.toInt() : res;
  },
  'abs': (dynamic a) => _num(a).abs(),
  'sum': (dynamic arr, [dynamic field]) {
    if (arr is! Iterable) return 0;
    num total = 0;
    for (final it in arr) {
      if (field is String && field.isNotEmpty) {
        final cleanField =
            field.startsWith('item.') ? field.substring(5) : field;
        total += _num(getPath(it, cleanField));
      } else {
        total += _num(it);
      }
    }
    return total % 1 == 0 ? total.toInt() : total;
  },
  'count': (dynamic arr) => arr is Iterable ? arr.length : 0,
  'avg': (dynamic arr, [dynamic field]) {
    if (arr is! Iterable || arr.isEmpty) return 0;
    final sumVal = expressionHelpers['sum']!(arr, field) as num;
    final res = sumVal / arr.length;
    return res % 1 == 0 ? res.toInt() : res;
  },
  'join': (dynamic arr, [dynamic sep]) =>
      arr is Iterable ? arr.join(sep is String ? sep : ', ') : '',
  'uppercase': (dynamic s) => (s?.toString() ?? '').toUpperCase(),
  'lowercase': (dynamic s) => (s?.toString() ?? '').toLowerCase(),
  'titlecase': (dynamic s) {
    final str = s?.toString() ?? '';
    return str.split(RegExp(r'\s+')).map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() +
          (w.length > 1 ? w.substring(1).toLowerCase() : '');
    }).join(' ');
  },
  'trim': (dynamic s) => (s?.toString() ?? '').trim(),
  'substr': (dynamic s, dynamic start, [dynamic len]) {
    final str = s?.toString() ?? '';
    final st = _num(start).toInt().clamp(0, str.length);
    if (len is num) {
      final l = len.toInt().clamp(0, str.length - st);
      return str.substring(st, st + l);
    }
    return str.substring(st);
  },
  'left': (dynamic s, dynamic n) {
    final str = s?.toString() ?? '';
    final count = _num(n).toInt().clamp(0, str.length);
    return str.substring(0, count);
  },
  'right': (dynamic s, dynamic n) {
    final str = s?.toString() ?? '';
    final count = _num(n).toInt().clamp(0, str.length);
    return str.substring(str.length - count);
  },
  'padLeft': (dynamic s, dynamic n, [dynamic ch]) {
    final str = s?.toString() ?? '';
    return str.padLeft(
        _num(n).toInt(), ch is String && ch.isNotEmpty ? ch : '0');
  },
  'padRight': (dynamic s, dynamic n, [dynamic ch]) {
    final str = s?.toString() ?? '';
    return str.padRight(
        _num(n).toInt(), ch is String && ch.isNotEmpty ? ch : ' ');
  },
  'replace': (dynamic s, dynamic a, dynamic b) => (s?.toString() ?? '')
      .replaceAll(a?.toString() ?? '', b?.toString() ?? ''),
  'concat': (List<dynamic> args) => args.map((e) => e?.toString() ?? '').join(),
  'length': (dynamic v) {
    if (v is String) return v.length;
    if (v is Iterable) return v.length;
    if (v is Map) return v.length;
    return 0;
  },
  'numberToWords': (dynamic v) => numberToWords(_num(v)),
};

bool _isTruthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    return s.isNotEmpty &&
        s != 'false' &&
        s != '0' &&
        s != 'no' &&
        s != 'null' &&
        s != 'undefined';
  }
  if (v is Iterable) return v.isNotEmpty;
  if (v is Map) return v.isNotEmpty;
  return true;
}

class _Token {
  final String text;
  final bool isSubExpr;
  _Token(this.text, {this.isSubExpr = false});
}

List<_Token> _tokenize(String input) {
  final tokens = <_Token>[];
  var i = 0;
  final len = input.length;

  while (i < len) {
    while (i < len && input[i].trim().isEmpty) {
      i++;
    }
    if (i >= len) break;

    final ch = input[i];

    // String literal
    if (ch == '"' || ch == "'") {
      final quote = ch;
      i++;
      final sb = StringBuffer();
      while (i < len && input[i] != quote) {
        if (input[i] == '\\' && i + 1 < len) {
          i++;
          sb.write(input[i]);
        } else {
          sb.write(input[i]);
        }
        i++;
      }
      if (i < len) i++; // skip closing quote
      tokens.add(_Token('"$sb"'));
      continue;
    }

    // Sub-expression in parenthesis (e.g. `(gt item.qty 10)`)
    if (ch == '(') {
      i++;
      var depth = 1;
      final sb = StringBuffer();
      while (i < len && depth > 0) {
        if (input[i] == '(') depth++;
        if (input[i] == ')') depth--;
        if (depth > 0) sb.write(input[i]);
        i++;
      }
      tokens.add(_Token(sb.toString().trim(), isSubExpr: true));
      continue;
    }

    // Normal word/path/literal
    final sb = StringBuffer();
    while (i < len &&
        input[i].trim().isNotEmpty &&
        input[i] != ')' &&
        input[i] != '"' &&
        input[i] != "'") {
      sb.write(input[i]);
      i++;
    }
    tokens.add(_Token(sb.toString()));
  }

  return tokens;
}

dynamic _evalToken(_Token token, dynamic ctx) {
  if (token.isSubExpr) {
    return _evalExpressionString(token.text, ctx);
  }

  final raw = token.text;
  if ((raw.startsWith('"') && raw.endsWith('"')) ||
      (raw.startsWith("'") && raw.endsWith("'"))) {
    return raw.substring(1, raw.length - 1);
  }
  if (raw == 'true') return true;
  if (raw == 'false') return false;
  if (raw == 'null') return null;

  final n = num.tryParse(raw);
  if (n != null) return n;

  // Otherwise, it's a property path in the context
  return getPath(ctx, raw);
}

dynamic _evalExpressionString(String expr, dynamic ctx) {
  final tokens = _tokenize(expr.trim());
  if (tokens.isEmpty) return '';

  final firstToken = tokens[0];
  final helperName = firstToken.text;

  // Check if the first token is a helper function
  if (!firstToken.isSubExpr && expressionHelpers.containsKey(helperName)) {
    final helper = expressionHelpers[helperName]!;
    final argTokens = tokens.sublist(1);
    final evaluatedArgs = argTokens.map((t) => _evalToken(t, ctx)).toList();

    try {
      if (helperName == 'and' || helperName == 'or' || helperName == 'concat') {
        return Function.apply(helper, [evaluatedArgs]);
      }
      return Function.apply(helper, evaluatedArgs);
    } catch (_) {
      return '';
    }
  }

  // If only 1 token and not a helper, resolve it directly
  if (tokens.length == 1) {
    return _evalToken(firstToken, ctx);
  }

  // Fallback: join evaluated tokens
  return tokens.map((t) => _evalToken(t, ctx)?.toString() ?? '').join(' ');
}

String evalTemplate(String tpl, dynamic ctx) {
  if (!tpl.contains('{{')) return tpl;
  final regex = RegExp(r'\{\{([\s\S]*?)\}\}');
  return tpl.replaceAllMapped(regex, (m) {
    final expr = m.group(1)!.trim();
    final res = _evalExpressionString(expr, ctx);
    return res != null ? escapeHtml(res.toString()) : '';
  });
}

String evalText(String tpl, dynamic ctx) {
  final html = evalTemplate(tpl, ctx);
  return html
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#x27;', "'")
      .replaceAll('&#x3D;', '=')
      .replaceAll('&#x60;', '`')
      .replaceAll('&amp;', '&');
}

bool evalCondition(String expr, dynamic ctx) {
  final e = expr.trim();
  if (e.isEmpty) return true;
  dynamic out;
  if (e.contains('{{')) {
    out = evalText(e, ctx).trim();
  } else if (e == 'true') {
    return true;
  } else if (e == 'false') {
    return false;
  } else {
    out = getPath(ctx, e);
  }
  return _isTruthy(out);
}

dynamic evalValue(String expr, dynamic ctx) {
  final e = expr.trim();
  final singleMatch = RegExp(r'^\{\{\s*([\w.@$[\]]+)\s*\}\}$').firstMatch(e);
  if (singleMatch != null) {
    return getPath(ctx, singleMatch.group(1)!);
  }
  if (e.contains('{{')) {
    return evalText(e, ctx);
  }
  return getPath(ctx, e);
}
