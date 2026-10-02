import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import '../expressions/format.dart';
import '../model/base_templates.dart';
import '../model/document.dart';
import '../model/inheritance.dart';
import '../model/model_helpers.dart';
import '../renderers/pdf_renderer.dart';
import 'paginate.dart';

class PrintSpec {
  dynamic template;
  Map<String, dynamic>? data;
  Map<String, dynamic> sources;
  Map<String, dynamic> params;
  List<dynamic>? records;
  dynamic base;
  int copies;
  String? title;
  bool applyOffset;

  PrintSpec({
    required this.template,
    this.data,
    Map<String, dynamic>? sources,
    Map<String, dynamic>? params,
    this.records,
    this.base,
    this.copies = 1,
    this.title,
    this.applyOffset = true,
  })  : sources = sources ?? {},
        params = params ?? {};

  Map<String, dynamic> toJson() {
    return {
      'template': (template is LayoutDocument)
          ? (template as LayoutDocument).toJson()
          : template,
      if (data != null) 'data': data,
      'sources': sources,
      'params': params,
      if (records != null) 'records': records,
      if (base != null)
        'base':
            (base is LayoutDocument) ? (base as LayoutDocument).toJson() : base,
      'copies': copies,
      if (title != null) 'title': title,
      'applyOffset': applyOffset,
    };
  }
}

class ValidationIssue {
  final String level; // 'error' | 'warning'
  final String message;
  const ValidationIssue({required this.level, required this.message});

  @override
  String toString() => '[$level] $message';
}

LayoutDocument _parseTemplate(dynamic t) {
  if (t is LayoutDocument) return t;
  if (t is Map<String, dynamic>) return normalizeDocument(t);
  if (t is Map) return normalizeDocument(Map<String, dynamic>.from(t));
  if (t is String) {
    final parsed = jsonDecode(t);
    return normalizeDocument(parsed is Map<String, dynamic>
        ? parsed
        : Map<String, dynamic>.from(parsed as Map));
  }
  throw ArgumentError(
      'Template must be a LayoutDocument, Map, or JSON string.');
}

class ReportBuilder {
  final PrintSpec spec;
  LayoutDocument? _cachedDoc;

  ReportBuilder(dynamic template) : spec = PrintSpec(template: template);

  static ReportBuilder fromTemplate(dynamic template) =>
      ReportBuilder(template);

  static ReportBuilder fromSpec(PrintSpec spec) {
    final b = ReportBuilder(spec.template);
    b.spec.data = spec.data;
    b.spec.sources = Map<String, dynamic>.from(spec.sources);
    b.spec.params = Map<String, dynamic>.from(spec.params);
    b.spec.records = spec.records;
    b.spec.base = spec.base;
    b.spec.copies = spec.copies;
    b.spec.title = spec.title;
    b.spec.applyOffset = spec.applyOffset;
    return b;
  }

  /* ---------------- Configuration ---------------- */

  ReportBuilder data(Map<String, dynamic> data) {
    spec.data = data;
    return this;
  }

  ReportBuilder source(String alias, dynamic data) {
    spec.sources[alias] = data;
    return this;
  }

  ReportBuilder sources(Map<String, dynamic> map) {
    spec.sources.addAll(map);
    return this;
  }

  ReportBuilder params(Map<String, dynamic> values) {
    spec.params.addAll(values);
    return this;
  }

  ReportBuilder param(String name, dynamic value) {
    spec.params[name] = value;
    return this;
  }

  ReportBuilder records(List<dynamic> records) {
    spec.records = records;
    return this;
  }

  ReportBuilder base(dynamic base) {
    spec.base = base;
    _cachedDoc = null;
    return this;
  }

  ReportBuilder copies(int n) {
    spec.copies = n > 1 ? n : 1;
    return this;
  }

  ReportBuilder title(String title) {
    spec.title = title;
    _cachedDoc = null;
    return this;
  }

  ReportBuilder calibration(bool apply) {
    spec.applyOffset = apply;
    return this;
  }

  PrintSpec toSpec() => spec;

  /* ---------------- Building ---------------- */

  LayoutDocument document() {
    if (_cachedDoc != null) return _cachedDoc!;
    var doc = _parseTemplate(spec.template);
    final baseRef = spec.base;
    if (baseRef != null) {
      final builtIn = baseRef == 'portrait' || baseRef == 'landscape';
      final baseDoc = builtIn
          ? createDefaultBase(baseRef.toString())
          : _parseTemplate(baseRef);
      doc = attachBase(doc.copyWith(base: null), baseDoc,
          builtIn ? 'base-a4-$baseRef.rtpl' : 'base.rtpl');
    }
    if (spec.title != null && spec.title!.isNotEmpty) {
      doc = doc.copyWith(title: spec.title);
    }
    _cachedDoc = doc;
    return doc;
  }

  dynamic payload() {
    final sources = spec.sources;
    final params = spec.params;

    Map<String, dynamic> one(Map<String, dynamic>? primary) {
      final primaryParams = (primary != null && primary['params'] is Map)
          ? Map<String, dynamic>.from(primary['params'] as Map)
          : <String, dynamic>{};

      return {
        if (primary != null) ...primary,
        ...sources,
        'params': {...primaryParams, ...params},
      };
    }

    final copies = spec.copies;
    final list = (spec.records != null)
        ? spec.records!
            .map((r) => one(r is Map ? Map<String, dynamic>.from(r) : null))
            .toList()
        : [one(spec.data)];

    final all = <Map<String, dynamic>>[];
    for (int c = 0; c < copies; c++) {
      all.addAll(list);
    }
    return all.length == 1 ? all[0] : all;
  }

  List<ValidationIssue> validate() {
    final issues = <ValidationIssue>[];
    LayoutDocument resolved;
    try {
      resolved = resolveInheritance(document()).doc;
    } catch (e) {
      return [ValidationIssue(level: 'error', message: 'Invalid template: $e')];
    }

    final sources = spec.sources;
    for (final s in resolved.extraSources) {
      if (!sources.containsKey(s.alias)) {
        issues.add(ValidationIssue(
          level: 'warning',
          message:
              'Data source "${s.alias}" is used by the template but was not provided (.source("${s.alias}", data)).',
        ));
      }
    }

    final params = spec.params;
    for (final p in resolved.parameters) {
      if (p.required &&
          !params.containsKey(p.name) &&
          (p.defaultValue == null || p.defaultValue.toString().isEmpty)) {
        issues.add(ValidationIssue(
          level: 'error',
          message: 'Required parameter "${p.name}" has no value.',
        ));
      }
    }

    if (spec.data == null && spec.records == null) {
      issues.add(const ValidationIssue(
          level: 'warning',
          message: 'No data provided (.data(...) or .records([...])).'));
    }
    if (spec.records != null && spec.records!.isEmpty) {
      issues.add(const ValidationIssue(
          level: 'warning',
          message: 'records([]) is empty — nothing to print.'));
    }

    return issues;
  }

  ReportBuilder assertValid() {
    final errors = validate().where((i) => i.level == 'error').toList();
    if (errors.isNotEmpty) {
      throw StateError(errors.map((e) => e.message).join('\n'));
    }
    return this;
  }

  List<RenderedPage> pages() {
    return renderReport(
      document(),
      payload(),
      RenderOptions(applyOffset: spec.applyOffset),
    );
  }

  int pageCount() => pages().length;

  String toHtml() {
    final doc = document();
    final pgs = pages();
    return '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>${escapeHtml(doc.title)}</title>
<link rel="stylesheet" href="$fontLink">
<style>
${reportCss(doc)}
</style>
</head>
<body>
${pagesHtml(doc, pgs)}
</body>
</html>''';
  }

  pw.Document toPdfDocument(
      [PdfRenderOptions opts = const PdfRenderOptions()]) {
    return renderReportPdfDocument(
      document(),
      payload(),
      opts,
    );
  }

  Future<Uint8List> toPdf([PdfRenderOptions opts = const PdfRenderOptions()]) {
    return renderReportPdf(
      document(),
      payload(),
      opts,
    );
  }
}
