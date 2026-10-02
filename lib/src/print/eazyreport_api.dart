import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import '../engine/builder.dart';
import '../model/document.dart';
import '../model/model_helpers.dart';
import '../renderers/pdf_renderer.dart';

class PrintOptions {
  final Map<String, dynamic>? sources;
  final dynamic
      base; // 'portrait' | 'landscape' | LayoutDocument | Map | String
  final int copies;
  final String? title;
  final bool calibration;

  const PrintOptions({
    this.sources,
    this.base,
    this.copies = 1,
    this.title,
    this.calibration = true,
  });
}

LayoutDocument loadTemplate(dynamic template) {
  if (template is LayoutDocument) return template;
  if (template is Map<String, dynamic>) return normalizeDocument(template);
  if (template is Map)
    return normalizeDocument(Map<String, dynamic>.from(template));
  if (template is String) {
    final s = template.trim();
    if (s.startsWith('{')) {
      final parsed = jsonDecode(s);
      return normalizeDocument(parsed is Map<String, dynamic>
          ? parsed
          : Map<String, dynamic>.from(parsed as Map));
    }
  }
  throw ArgumentError(
      'Template must be a LayoutDocument, Map, or JSON string.');
}

ReportBuilder builderFor(
  dynamic template, [
  dynamic data,
  Map<String, dynamic>? params,
  PrintOptions options = const PrintOptions(),
]) {
  final b = ReportBuilder(loadTemplate(template));
  if (data is List) {
    b.records(data);
  } else if (data is Map<String, dynamic>) {
    b.data(data);
  } else if (data is Map) {
    b.data(Map<String, dynamic>.from(data));
  } else {
    b.data({});
  }

  if (params != null) b.params(params);
  if (options.sources != null) b.sources(options.sources!);
  if (options.base != null) b.base(options.base);
  if (options.copies > 1) b.copies(options.copies);
  if (options.title != null) b.title(options.title!);
  if (!options.calibration) b.calibration(false);

  b.assertValid();
  return b;
}

/// Returns the complete, filled printable HTML document (all pages) ready for printing or viewing.
String getReportHtml(
  dynamic template, [
  dynamic data,
  Map<String, dynamic>? params,
  PrintOptions options = const PrintOptions(),
]) {
  return builderFor(template, data, params, options).toHtml();
}

/// Calculates and returns the exact number of pages the report will generate.
int countReportPages(
  dynamic template, [
  dynamic data,
  Map<String, dynamic>? params,
  PrintOptions options = const PrintOptions(),
]) {
  return builderFor(template, data, params, options).pageCount();
}

/// Generates raw binary PDF bytes (Uint8List) directly for the report.
Future<Uint8List> getReportPdf(
  dynamic template, [
  dynamic data,
  Map<String, dynamic>? params,
  PrintOptions options = const PrintOptions(),
  PdfRenderOptions pdfOptions = const PdfRenderOptions(),
]) {
  return builderFor(template, data, params, options).toPdf(pdfOptions);
}

/// Generates a pw.Document (pdf package) directly for the report.
pw.Document getReportPdfDocument(
  dynamic template, [
  dynamic data,
  Map<String, dynamic>? params,
  PrintOptions options = const PrintOptions(),
  PdfRenderOptions pdfOptions = const PdfRenderOptions(),
]) {
  return builderFor(template, data, params, options).toPdfDocument(pdfOptions);
}
