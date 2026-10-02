import 'schema.dart';
import 'types.dart';

class PageMargins {
  final double top;
  final double right;
  final double bottom;
  final double left;

  const PageMargins({
    this.top = 10.0,
    this.right = 10.0,
    this.bottom = 10.0,
    this.left = 10.0,
  });

  factory PageMargins.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PageMargins();
    return PageMargins(
      top: (json['top'] as num?)?.toDouble() ?? 10.0,
      right: (json['right'] as num?)?.toDouble() ?? 10.0,
      bottom: (json['bottom'] as num?)?.toDouble() ?? 10.0,
      left: (json['left'] as num?)?.toDouble() ?? 10.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top': top,
      'right': right,
      'bottom': bottom,
      'left': left,
    };
  }
}

class Watermark {
  final bool enabled;
  final String text;
  final String color;
  final double fontSize; // pt
  final double angle;
  final double opacity;
  final String image;
  final bool onTop;

  const Watermark({
    this.enabled = false,
    this.text = 'DRAFT',
    this.color = '#94a3b8',
    this.fontSize = 90.0,
    this.angle = -45.0,
    this.opacity = 0.18,
    this.image = '',
    this.onTop = false,
  });

  Watermark copyWith({
    bool? enabled,
    String? text,
    String? color,
    double? fontSize,
    double? angle,
    double? opacity,
    String? image,
    bool? onTop,
  }) {
    return Watermark(
      enabled: enabled ?? this.enabled,
      text: text ?? this.text,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      angle: angle ?? this.angle,
      opacity: opacity ?? this.opacity,
      image: image ?? this.image,
      onTop: onTop ?? this.onTop,
    );
  }

  factory Watermark.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Watermark();
    return Watermark(
      enabled: json['enabled'] as bool? ?? false,
      text: json['text'] as String? ?? 'DRAFT',
      color: json['color'] as String? ?? '#94a3b8',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 90.0,
      angle: (json['angle'] as num?)?.toDouble() ?? -45.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 0.18,
      image: json['image'] as String? ?? '',
      onTop: json['onTop'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'text': text,
      'color': color,
      'fontSize': fontSize,
      'angle': angle,
      'opacity': opacity,
      'image': image,
      'onTop': onTop,
    };
  }
}

class LayoutPage {
  final String id;
  final String name;
  final bool inheritPage;
  final bool titleBeforeHeader;
  final String
      size; // 'A3' | 'A4' | 'A5' | 'A6' | 'B5' | 'LETTER' | 'LEGAL' | 'EXECUTIVE' | 'CUSTOM'
  final String orientation; // 'portrait' | 'landscape'
  final double width;
  final double height;
  final PageMargins margins;
  final double printOffsetX;
  final double printOffsetY;
  final String? designBackground;
  final double designBackgroundOpacity;
  final Watermark watermark;
  final Band? reportTitle;
  final Band? pageHeader;
  final List<DataBand> dataBands;
  final Band? reportSummary;
  final Band? pageFooter;
  final Band? overlay;

  const LayoutPage({
    required this.id,
    this.name = 'Page1',
    this.inheritPage = true,
    this.titleBeforeHeader = false,
    this.size = 'A4',
    this.orientation = 'portrait',
    this.width = 210.0,
    this.height = 297.0,
    this.margins = const PageMargins(),
    this.printOffsetX = 0.0,
    this.printOffsetY = 0.0,
    this.designBackground,
    this.designBackgroundOpacity = 0.4,
    this.watermark = const Watermark(),
    this.reportTitle,
    this.pageHeader,
    this.dataBands = const [],
    this.reportSummary,
    this.pageFooter,
    this.overlay,
  });

  LayoutPage copyWith({
    String? id,
    String? name,
    bool? inheritPage,
    bool? titleBeforeHeader,
    String? size,
    String? orientation,
    double? width,
    double? height,
    PageMargins? margins,
    double? printOffsetX,
    double? printOffsetY,
    String? designBackground,
    double? designBackgroundOpacity,
    Watermark? watermark,
    Band? reportTitle,
    Band? pageHeader,
    List<DataBand>? dataBands,
    Band? reportSummary,
    Band? pageFooter,
    Band? overlay,
  }) {
    return LayoutPage(
      id: id ?? this.id,
      name: name ?? this.name,
      inheritPage: inheritPage ?? this.inheritPage,
      titleBeforeHeader: titleBeforeHeader ?? this.titleBeforeHeader,
      size: size ?? this.size,
      orientation: orientation ?? this.orientation,
      width: width ?? this.width,
      height: height ?? this.height,
      margins: margins ?? this.margins,
      printOffsetX: printOffsetX ?? this.printOffsetX,
      printOffsetY: printOffsetY ?? this.printOffsetY,
      designBackground: designBackground ?? this.designBackground,
      designBackgroundOpacity:
          designBackgroundOpacity ?? this.designBackgroundOpacity,
      watermark: watermark ?? this.watermark,
      reportTitle: reportTitle ?? this.reportTitle,
      pageHeader: pageHeader ?? this.pageHeader,
      dataBands: dataBands ?? this.dataBands,
      reportSummary: reportSummary ?? this.reportSummary,
      pageFooter: pageFooter ?? this.pageFooter,
      overlay: overlay ?? this.overlay,
    );
  }

  factory LayoutPage.fromJson(Map<String, dynamic> json) {
    return LayoutPage(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Page1',
      inheritPage: json['inheritPage'] as bool? ?? true,
      titleBeforeHeader: json['titleBeforeHeader'] as bool? ?? false,
      size: json['size'] as String? ?? 'A4',
      orientation: json['orientation'] as String? ?? 'portrait',
      width: (json['width'] as num?)?.toDouble() ?? 210.0,
      height: (json['height'] as num?)?.toDouble() ?? 297.0,
      margins: PageMargins.fromJson(json['margins'] as Map<String, dynamic>?),
      printOffsetX: (json['printOffsetX'] as num?)?.toDouble() ?? 0.0,
      printOffsetY: (json['printOffsetY'] as num?)?.toDouble() ?? 0.0,
      designBackground: json['designBackground'] as String?,
      designBackgroundOpacity:
          (json['designBackgroundOpacity'] as num?)?.toDouble() ?? 0.4,
      watermark: Watermark.fromJson(json['watermark'] as Map<String, dynamic>?),
      reportTitle: json['reportTitle'] != null
          ? Band.fromJson(json['reportTitle'] as Map<String, dynamic>)
          : null,
      pageHeader: json['pageHeader'] != null
          ? Band.fromJson(json['pageHeader'] as Map<String, dynamic>)
          : null,
      dataBands: (json['dataBands'] as List<dynamic>?)
              ?.map((d) => DataBand.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      reportSummary: json['reportSummary'] != null
          ? Band.fromJson(json['reportSummary'] as Map<String, dynamic>)
          : null,
      pageFooter: json['pageFooter'] != null
          ? Band.fromJson(json['pageFooter'] as Map<String, dynamic>)
          : null,
      overlay: json['overlay'] != null
          ? Band.fromJson(json['overlay'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'inheritPage': inheritPage,
      'titleBeforeHeader': titleBeforeHeader,
      'size': size,
      'orientation': orientation,
      'width': width,
      'height': height,
      'margins': margins.toJson(),
      'printOffsetX': printOffsetX,
      'printOffsetY': printOffsetY,
      if (designBackground != null) 'designBackground': designBackground,
      'designBackgroundOpacity': designBackgroundOpacity,
      'watermark': watermark.toJson(),
      if (reportTitle != null) 'reportTitle': reportTitle!.toJson(),
      if (pageHeader != null) 'pageHeader': pageHeader!.toJson(),
      'dataBands': dataBands.map((d) => d.toJson()).toList(),
      if (reportSummary != null) 'reportSummary': reportSummary!.toJson(),
      if (pageFooter != null) 'pageFooter': pageFooter!.toJson(),
      if (overlay != null) 'overlay': overlay!.toJson(),
    };
  }
}

class GridSettings {
  final double size;
  final bool show;
  final bool snapToGrid;
  final bool snapToElements;

  const GridSettings({
    this.size = 1.0,
    this.show = true,
    this.snapToGrid = true,
    this.snapToElements = true,
  });

  factory GridSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GridSettings();
    return GridSettings(
      size: (json['size'] as num?)?.toDouble() ?? 1.0,
      show: json['show'] as bool? ?? true,
      snapToGrid: json['snapToGrid'] as bool? ?? true,
      snapToElements: json['snapToElements'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'show': show,
      'snapToGrid': snapToGrid,
      'snapToElements': snapToElements,
    };
  }
}

class DataSourceRef {
  final String id;
  final String alias;

  const DataSourceRef({required this.id, required this.alias});

  factory DataSourceRef.fromJson(Map<String, dynamic> json) {
    return DataSourceRef(
      id: json['id'] as String? ?? '',
      alias: json['alias'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'alias': alias};
}

class BaseReportRef {
  final String fileName;
  final String importedAt;
  final LayoutDocument doc;

  const BaseReportRef({
    required this.fileName,
    required this.importedAt,
    required this.doc,
  });

  factory BaseReportRef.fromJson(Map<String, dynamic> json) {
    return BaseReportRef(
      fileName: json['fileName'] as String? ?? '',
      importedAt: json['importedAt'] as String? ?? '',
      doc: LayoutDocument.fromJson(json['doc'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'importedAt': importedAt,
      'doc': doc.toJson(),
    };
  }
}

class LayoutDocument {
  final String format;
  final int version;
  final String title;
  final String author;
  final String description;
  final List<LayoutPage> pages;
  final GridSettings grid;
  final List<ReportParameter> parameters;
  final String? dataSourceId;
  final List<DataSourceRef> extraSources;
  final BaseReportRef? base;
  final List<String> hiddenBaseIds;
  final String createdAt;
  final String updatedAt;
  final String? script;

  const LayoutDocument({
    this.format = 'report-designer-layout',
    this.version = 2,
    this.title = 'Untitled Report',
    this.author = '',
    this.description = '',
    this.pages = const [],
    this.grid = const GridSettings(),
    this.parameters = const [],
    this.dataSourceId,
    this.extraSources = const [],
    this.base,
    this.hiddenBaseIds = const [],
    this.createdAt = '',
    this.updatedAt = '',
    this.script,
  });

  LayoutDocument copyWith({
    String? format,
    int? version,
    String? title,
    String? author,
    String? description,
    List<LayoutPage>? pages,
    GridSettings? grid,
    List<ReportParameter>? parameters,
    String? dataSourceId,
    List<DataSourceRef>? extraSources,
    BaseReportRef? base,
    List<String>? hiddenBaseIds,
    String? createdAt,
    String? updatedAt,
    String? script,
  }) {
    return LayoutDocument(
      format: format ?? this.format,
      version: version ?? this.version,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      pages: pages ?? this.pages,
      grid: grid ?? this.grid,
      parameters: parameters ?? this.parameters,
      dataSourceId: dataSourceId ?? this.dataSourceId,
      extraSources: extraSources ?? this.extraSources,
      base: base ?? this.base,
      hiddenBaseIds: hiddenBaseIds ?? this.hiddenBaseIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      script: script ?? this.script,
    );
  }

  factory LayoutDocument.fromJson(Map<String, dynamic> json) {
    return LayoutDocument(
      format: json['format'] as String? ?? 'report-designer-layout',
      version: (json['version'] as num?)?.toInt() ?? 2,
      title: json['title'] as String? ?? 'Untitled Report',
      author: json['author'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pages: (json['pages'] as List<dynamic>?)
              ?.map((p) => LayoutPage.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      grid: GridSettings.fromJson(json['grid'] as Map<String, dynamic>?),
      parameters: (json['parameters'] as List<dynamic>?)
              ?.map((p) => ReportParameter.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      dataSourceId: json['dataSourceId'] as String?,
      extraSources: (json['extraSources'] as List<dynamic>?)
              ?.map((s) => DataSourceRef.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      base: json['base'] != null
          ? BaseReportRef.fromJson(json['base'] as Map<String, dynamic>)
          : null,
      hiddenBaseIds: (json['hiddenBaseIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      script: json['script'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'version': version,
      'title': title,
      'author': author,
      'description': description,
      'pages': pages.map((p) => p.toJson()).toList(),
      'grid': grid.toJson(),
      'parameters': parameters.map((p) => p.toJson()).toList(),
      if (dataSourceId != null) 'dataSourceId': dataSourceId,
      'extraSources': extraSources.map((s) => s.toJson()).toList(),
      if (base != null) 'base': base!.toJson(),
      'hiddenBaseIds': hiddenBaseIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (script != null) 'script': script,
    };
  }
}
