import '../expressions/expressions.dart';
import '../model/types.dart';

dynamic resolvePropertyValue(String prop, dynamic ctx) {
  if (prop.isEmpty || ctx == null) return null;
  final p = prop.trim();

  if (p.startsWith('params.') && ctx is Map) {
    final key = p.substring(7);
    return ctx['params'] is Map ? ctx['params'][key] : null;
  }

  if (ctx is Map) {
    if (p == 'Row' || p == 'row') return ctx['Row'] ?? ctx['rowNumber'];
    if (p == 'Page' || p == 'page') return ctx['Page'] ?? 1;
    if (p == 'TotalPages') return ctx['TotalPages'] ?? 1;
    if (p == 'Now')
      return ctx['Now'] ?? DateTime.now().toUtc().toIso8601String();

    if (ctx['row'] is Map && (ctx['row'] as Map).containsKey(p)) {
      return ctx['row'][p];
    }
  }

  final val = getPath(ctx, p);
  if (val != null) return val;

  if (ctx is Map && ctx['data'] != null) {
    return getPath(ctx['data'], p);
  }

  return null;
}

bool checkCondition(dynamic val, String op, [String? cmpValue]) {
  switch (op) {
    case 'empty':
      return val == null ||
          (val is String && val.trim().isEmpty) ||
          (val is Iterable && val.isEmpty) ||
          (val is Map && val.isEmpty);

    case 'not_empty':
      return val != null &&
          !(val is String && val.trim().isEmpty) &&
          !(val is Iterable && val.isEmpty) &&
          !(val is Map && val.isEmpty);

    case 'equals':
      if (val == null) return cmpValue == null || cmpValue.isEmpty;
      final numVal = num.tryParse(val.toString());
      final numCmp = num.tryParse(cmpValue ?? '');
      if (numVal != null &&
          numCmp != null &&
          cmpValue != null &&
          cmpValue.isNotEmpty) {
        return numVal == numCmp;
      }
      return val.toString().trim().toLowerCase() ==
          (cmpValue ?? '').trim().toLowerCase();

    case 'not_equals':
      return !checkCondition(val, 'equals', cmpValue);

    case 'gt':
      final n1 = num.tryParse(val?.toString() ?? '');
      final n2 = num.tryParse(cmpValue ?? '');
      return n1 != null && n2 != null && n1 > n2;

    case 'gte':
      final n1 = num.tryParse(val?.toString() ?? '');
      final n2 = num.tryParse(cmpValue ?? '');
      return n1 != null && n2 != null && n1 >= n2;

    case 'lt':
      final n1 = num.tryParse(val?.toString() ?? '');
      final n2 = num.tryParse(cmpValue ?? '');
      return n1 != null && n2 != null && n1 < n2;

    case 'lte':
      final n1 = num.tryParse(val?.toString() ?? '');
      final n2 = num.tryParse(cmpValue ?? '');
      return n1 != null && n2 != null && n1 <= n2;

    case 'contains':
      if (val == null) return false;
      return val
          .toString()
          .toLowerCase()
          .contains((cmpValue ?? '').toLowerCase());

    case 'starts_with':
      if (val == null) return false;
      return val
          .toString()
          .toLowerCase()
          .startsWith((cmpValue ?? '').toLowerCase());

    default:
      return false;
  }
}

class RuleEvaluationResult {
  final bool triggered;
  final dynamic value;
  final String action;
  final String? actionValue;

  const RuleEvaluationResult({
    required this.triggered,
    this.value,
    required this.action,
    this.actionValue,
  });
}

RuleEvaluationResult evaluateRule(LogicRule rule, dynamic ctx) {
  if (!rule.enabled) {
    return RuleEvaluationResult(triggered: false, action: rule.action);
  }
  final val = resolvePropertyValue(rule.property, ctx);
  final triggered = checkCondition(val, rule.operator, rule.value);
  return RuleEvaluationResult(
    triggered: triggered,
    value: val,
    action: rule.action,
    actionValue: rule.actionValue,
  );
}
