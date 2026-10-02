import 'document.dart';

/* ------------------------------------------------------------------ */
/* Styling                                                             */
/* ------------------------------------------------------------------ */

enum HAlign {
  left,
  center,
  right,
  justify;

  static HAlign fromString(String? val) {
    switch (val) {
      case 'center':
        return HAlign.center;
      case 'right':
        return HAlign.right;
      case 'justify':
        return HAlign.justify;
      case 'left':
      default:
        return HAlign.left;
    }
  }

  String toJson() => name;
}

enum VAlign {
  top,
  middle,
  bottom;

  static VAlign fromString(String? val) {
    switch (val) {
      case 'top':
        return VAlign.top;
      case 'bottom':
        return VAlign.bottom;
      case 'middle':
      default:
        return VAlign.middle;
    }
  }

  String toJson() => name;
}

enum StrokeStyle {
  solid,
  dashed,
  dotted,
  double;

  static StrokeStyle fromString(String? val) {
    switch (val) {
      case 'dashed':
        return StrokeStyle.dashed;
      case 'dotted':
        return StrokeStyle.dotted;
      case 'double':
        return StrokeStyle.double;
      case 'solid':
      default:
        return StrokeStyle.solid;
    }
  }

  String toJson() => name;
}

class TextStyle {
  final String fontFamily;
  final double fontSize; // pt
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strike;
  final String color;
  final HAlign align;
  final VAlign vAlign;
  final double lineHeight; // multiplier
  final double letterSpacing; // pt
  final bool wrap;

  const TextStyle({
    this.fontFamily = 'Inter',
    this.fontSize = 10.0,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strike = false,
    this.color = '#0f172a',
    this.align = HAlign.left,
    this.vAlign = VAlign.middle,
    this.lineHeight = 1.2,
    this.letterSpacing = 0.0,
    this.wrap = true,
  });

  TextStyle copyWith({
    String? fontFamily,
    double? fontSize,
    bool? bold,
    bool? italic,
    bool? underline,
    bool? strike,
    String? color,
    HAlign? align,
    VAlign? vAlign,
    double? lineHeight,
    double? letterSpacing,
    bool? wrap,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strike: strike ?? this.strike,
      color: color ?? this.color,
      align: align ?? this.align,
      vAlign: vAlign ?? this.vAlign,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wrap: wrap ?? this.wrap,
    );
  }

  factory TextStyle.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TextStyle();
    return TextStyle(
      fontFamily: json['fontFamily'] as String? ?? 'Inter',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 10.0,
      bold: json['bold'] as bool? ?? false,
      italic: json['italic'] as bool? ?? false,
      underline: json['underline'] as bool? ?? false,
      strike: json['strike'] as bool? ?? false,
      color: json['color'] as String? ?? '#0f172a',
      align: HAlign.fromString(json['align'] as String?),
      vAlign: VAlign.fromString(json['vAlign'] as String?),
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.2,
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 0.0,
      wrap: json['wrap'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'bold': bold,
      'italic': italic,
      'underline': underline,
      'strike': strike,
      'color': color,
      'align': align.toJson(),
      'vAlign': vAlign.toJson(),
      'lineHeight': lineHeight,
      'letterSpacing': letterSpacing,
      'wrap': wrap,
    };
  }
}

class BoxStyle {
  final String background; // '' = transparent
  final double borderWidth; // pt, 0 = none
  final String borderColor;
  final StrokeStyle borderStyle;
  final bool borderTop;
  final bool borderRight;
  final bool borderBottom;
  final bool borderLeft;
  final double borderRadius; // mm
  final double padding; // mm
  final bool shadow;

  const BoxStyle({
    this.background = '',
    this.borderWidth = 0.0,
    this.borderColor = '#0f172a',
    this.borderStyle = StrokeStyle.solid,
    this.borderTop = true,
    this.borderRight = true,
    this.borderBottom = true,
    this.borderLeft = true,
    this.borderRadius = 0.0,
    this.padding = 0.5,
    this.shadow = false,
  });

  BoxStyle copyWith({
    String? background,
    double? borderWidth,
    String? borderColor,
    StrokeStyle? borderStyle,
    bool? borderTop,
    bool? borderRight,
    bool? borderBottom,
    bool? borderLeft,
    double? borderRadius,
    double? padding,
    bool? shadow,
  }) {
    return BoxStyle(
      background: background ?? this.background,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      borderStyle: borderStyle ?? this.borderStyle,
      borderTop: borderTop ?? this.borderTop,
      borderRight: borderRight ?? this.borderRight,
      borderBottom: borderBottom ?? this.borderBottom,
      borderLeft: borderLeft ?? this.borderLeft,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      shadow: shadow ?? this.shadow,
    );
  }

  factory BoxStyle.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BoxStyle();
    return BoxStyle(
      background: json['background'] as String? ?? '',
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 0.0,
      borderColor: json['borderColor'] as String? ?? '#0f172a',
      borderStyle: StrokeStyle.fromString(json['borderStyle'] as String?),
      borderTop: json['borderTop'] as bool? ?? true,
      borderRight: json['borderRight'] as bool? ?? true,
      borderBottom: json['borderBottom'] as bool? ?? true,
      borderLeft: json['borderLeft'] as bool? ?? true,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 0.0,
      padding: (json['padding'] as num?)?.toDouble() ?? 0.5,
      shadow: json['shadow'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'background': background,
      'borderWidth': borderWidth,
      'borderColor': borderColor,
      'borderStyle': borderStyle.toJson(),
      'borderTop': borderTop,
      'borderRight': borderRight,
      'borderBottom': borderBottom,
      'borderLeft': borderLeft,
      'borderRadius': borderRadius,
      'padding': padding,
      'shadow': shadow,
    };
  }
}

class ValueFormat {
  final String
      format; // 'auto' | 'text' | 'number' | 'currency' | 'percent' | 'date' | 'boolean'
  final int decimals;
  final String currency;
  final String datePattern;
  final String booleanText; // "Yes|No"
  final bool thousands;

  const ValueFormat({
    this.format = 'auto',
    this.decimals = 2,
    this.currency = 'USD',
    this.datePattern = 'dd/MM/yyyy',
    this.booleanText = 'Yes|No',
    this.thousands = true,
  });

  ValueFormat copyWith({
    String? format,
    int? decimals,
    String? currency,
    String? datePattern,
    String? booleanText,
    bool? thousands,
  }) {
    return ValueFormat(
      format: format ?? this.format,
      decimals: decimals ?? this.decimals,
      currency: currency ?? this.currency,
      datePattern: datePattern ?? this.datePattern,
      booleanText: booleanText ?? this.booleanText,
      thousands: thousands ?? this.thousands,
    );
  }

  factory ValueFormat.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ValueFormat();
    return ValueFormat(
      format: json['format'] as String? ?? 'auto',
      decimals: (json['decimals'] as num?)?.toInt() ?? 2,
      currency: json['currency'] as String? ?? 'USD',
      datePattern: json['datePattern'] as String? ?? 'dd/MM/yyyy',
      booleanText: json['booleanText'] as String? ?? 'Yes|No',
      thousands: json['thousands'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'decimals': decimals,
      'currency': currency,
      'datePattern': datePattern,
      'booleanText': booleanText,
      'thousands': thousands,
    };
  }
}

class Highlight {
  final String id;
  final String condition;
  final String color;
  final String background;
  final bool bold;
  final bool italic;
  final bool hide;

  const Highlight({
    required this.id,
    required this.condition,
    this.color = '',
    this.background = '',
    this.bold = false,
    this.italic = false,
    this.hide = false,
  });

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['id'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      color: json['color'] as String? ?? '',
      background: json['background'] as String? ?? '',
      bold: json['bold'] as bool? ?? false,
      italic: json['italic'] as bool? ?? false,
      hide: json['hide'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'condition': condition,
      'color': color,
      'background': background,
      'bold': bold,
      'italic': italic,
      'hide': hide,
    };
  }
}

class LogicRule {
  final String id;
  final String? name;
  final bool enabled;
  final String property;
  final String
      operator; // 'empty' | 'not_empty' | 'equals' | 'not_equals' | 'gt' | 'gte' | 'lt' | 'lte' | 'contains' | 'starts_with'
  final String? value;
  final String? targetId;
  final String
      action; // 'hide' | 'show' | 'skip' | 'text_color' | 'background' | 'set_text'
  final String? actionValue;

  const LogicRule({
    required this.id,
    this.name,
    this.enabled = true,
    required this.property,
    required this.operator,
    this.value,
    this.targetId,
    required this.action,
    this.actionValue,
  });

  factory LogicRule.fromJson(Map<String, dynamic> json) {
    return LogicRule(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      property: json['property'] as String? ?? '',
      operator: json['operator'] as String? ?? 'equals',
      value: json['value']?.toString(),
      targetId: json['targetId'] as String?,
      action: json['action'] as String? ?? 'hide',
      actionValue: json['actionValue']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (name != null) 'name': name,
      'enabled': enabled,
      'property': property,
      'operator': operator,
      if (value != null) 'value': value,
      if (targetId != null) 'targetId': targetId,
      'action': action,
      if (actionValue != null) 'actionValue': actionValue,
    };
  }
}

class BandScript {
  final String? onBeforePrint;
  final String? onAfterPrint;
  final String? onBeforeData;
  final String? onAfterData;

  const BandScript({
    this.onBeforePrint,
    this.onAfterPrint,
    this.onBeforeData,
    this.onAfterData,
  });

  factory BandScript.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BandScript();
    return BandScript(
      onBeforePrint: json['onBeforePrint'] as String?,
      onAfterPrint: json['onAfterPrint'] as String?,
      onBeforeData: json['onBeforeData'] as String?,
      onAfterData: json['onAfterData'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (onBeforePrint != null) 'onBeforePrint': onBeforePrint,
      if (onAfterPrint != null) 'onAfterPrint': onAfterPrint,
      if (onBeforeData != null) 'onBeforeData': onBeforeData,
      if (onAfterData != null) 'onAfterData': onAfterData,
    };
  }
}

class ElementScript {
  final String? onBeforePrint;
  final String? onAfterPrint;

  const ElementScript({
    this.onBeforePrint,
    this.onAfterPrint,
  });

  factory ElementScript.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ElementScript();
    return ElementScript(
      onBeforePrint: json['onBeforePrint'] as String?,
      onAfterPrint: json['onAfterPrint'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (onBeforePrint != null) 'onBeforePrint': onBeforePrint,
      if (onAfterPrint != null) 'onAfterPrint': onAfterPrint,
    };
  }
}

/* ------------------------------------------------------------------ */
/* Layout Elements                                                     */
/* ------------------------------------------------------------------ */

abstract class LayoutElement {
  final String id;
  final String type;
  final String name;
  final double x;
  final double y;
  final double w;
  final double h;
  final bool locked;
  final TextStyle style;
  final BoxStyle box;
  final double rotation;
  final bool printable;
  final String visibleExpr;
  final String hyperlink;
  final bool growToBottom;
  final List<Highlight> highlights;
  final ElementScript? script;
  final List<LogicRule>? rules;
  final List<String>?
      printOn; // 'FirstPage' | 'LastPage' | 'OddPages' | 'EvenPages' | 'RepeatedBand'

  const LayoutElement({
    required this.id,
    required this.type,
    required this.name,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.locked = false,
    this.style = const TextStyle(),
    this.box = const BoxStyle(),
    this.rotation = 0.0,
    this.printable = true,
    this.visibleExpr = '',
    this.hyperlink = '',
    this.growToBottom = false,
    this.highlights = const [],
    this.script,
    this.rules,
    this.printOn,
  });

  LayoutElement copyWith({
    String? id,
    String? type,
    String? name,
    double? x,
    double? y,
    double? w,
    double? h,
    bool? locked,
    TextStyle? style,
    BoxStyle? box,
    double? rotation,
    bool? printable,
    String? visibleExpr,
    String? hyperlink,
    bool? growToBottom,
    List<Highlight>? highlights,
    ElementScript? script,
    List<LogicRule>? rules,
    List<String>? printOn,
  });

  factory LayoutElement.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'text';
    switch (type) {
      case 'text':
        return TextElement.fromJson(json);
      case 'field':
        return FieldElement.fromJson(json);
      case 'image':
        return ImageElement.fromJson(json);
      case 'line':
        return LineElement.fromJson(json);
      case 'shape':
        return ShapeElement.fromJson(json);
      case 'table':
        return TableElement.fromJson(json);
      case 'barcode':
        return BarcodeElement.fromJson(json);
      case 'checkbox':
        return CheckboxElement.fromJson(json);
      case 'chart':
        return ChartElement.fromJson(json);
      case 'subreport':
        return SubReportElement.fromJson(json);
      default:
        return TextElement.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

class TextElement extends LayoutElement {
  final String text;
  final bool canGrow;
  final bool canShrink;
  final bool autoShrink;
  final bool allowHtml;
  final bool hideDuplicates;

  const TextElement({
    required super.id,
    super.type = 'text',
    required super.name,
    required super.x,
    required super.y,
    required super.w,
    required super.h,
    super.locked,
    super.style,
    super.box,
    super.rotation,
    super.printable,
    super.visibleExpr,
    super.hyperlink,
    super.growToBottom,
    super.highlights,
    super.script,
    super.rules,
    super.printOn,
    this.text = '',
    this.canGrow = false,
    this.canShrink = false,
    this.autoShrink = false,
    this.allowHtml = false,
    this.hideDuplicates = false,
  });

  @override
  TextElement copyWith({
    String? id,
    String? type,
    String? name,
    double? x,
    double? y,
    double? w,
    double? h,
    bool? locked,
    TextStyle? style,
    BoxStyle? box,
    double? rotation,
    bool? printable,
    String? visibleExpr,
    String? hyperlink,
    bool? growToBottom,
    List<Highlight>? highlights,
    ElementScript? script,
    List<LogicRule>? rules,
    List<String>? printOn,
    String? text,
    bool? canGrow,
    bool? canShrink,
    bool? autoShrink,
    bool? allowHtml,
    bool? hideDuplicates,
  }) {
    return TextElement(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      locked: locked ?? this.locked,
      style: style ?? this.style,
      box: box ?? this.box,
      rotation: rotation ?? this.rotation,
      printable: printable ?? this.printable,
      visibleExpr: visibleExpr ?? this.visibleExpr,
      hyperlink: hyperlink ?? this.hyperlink,
      growToBottom: growToBottom ?? this.growToBottom,
      highlights: highlights ?? this.highlights,
      script: script ?? this.script,
      rules: rules ?? this.rules,
      printOn: printOn ?? this.printOn,
      text: text ?? this.text,
      canGrow: canGrow ?? this.canGrow,
      canShrink: canShrink ?? this.canShrink,
      autoShrink: autoShrink ?? this.autoShrink,
      allowHtml: allowHtml ?? this.allowHtml,
      hideDuplicates: hideDuplicates ?? this.hideDuplicates,
    );
  }

  factory TextElement.fromJson(Map<String, dynamic> json) {
    return TextElement(
      id: json['id'] as String? ?? '',
      type: 'text',
      name: json['name'] as String? ?? 'Text',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      w: (json['w'] as num?)?.toDouble() ?? 50.0,
      h: (json['h'] as num?)?.toDouble() ?? 6.0,
      locked: json['locked'] as bool? ?? false,
      style: TextStyle.fromJson(json['style'] as Map<String, dynamic>?),
      box: BoxStyle.fromJson(json['box'] as Map<String, dynamic>?),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      printable: json['printable'] as bool? ?? true,
      visibleExpr: json['visibleExpr'] as String? ?? '',
      hyperlink: json['hyperlink'] as String? ?? '',
      growToBottom: json['growToBottom'] as bool? ?? false,
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((h) => Highlight.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      script: json['script'] != null
          ? ElementScript.fromJson(json['script'] as Map<String, dynamic>)
          : null,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((r) => LogicRule.fromJson(r as Map<String, dynamic>))
          .toList(),
      printOn: (json['printOn'] as List<dynamic>?)
          ?.map((p) => p.toString())
          .toList(),
      text: json['text'] as String? ?? '',
      canGrow: json['canGrow'] as bool? ?? false,
      canShrink: json['canShrink'] as bool? ?? false,
      autoShrink: json['autoShrink'] as bool? ?? false,
      allowHtml: json['allowHtml'] as bool? ?? false,
      hideDuplicates: json['hideDuplicates'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'x': x,
      'y': y,
      'w': w,
      'h': h,
      'locked': locked,
      'style': style.toJson(),
      'box': box.toJson(),
      'rotation': rotation,
      'printable': printable,
      'visibleExpr': visibleExpr,
      'hyperlink': hyperlink,
      'growToBottom': growToBottom,
      'highlights': highlights.map((h) => h.toJson()).toList(),
      if (script != null) 'script': script!.toJson(),
      if (rules != null) 'rules': rules!.map((r) => r.toJson()).toList(),
      if (printOn != null) 'printOn': printOn,
      'text': text,
      'canGrow': canGrow,
      'canShrink': canShrink,
      'autoShrink': autoShrink,
      'allowHtml': allowHtml,
      'hideDuplicates': hideDuplicates,
    };
  }
}

class FieldElement extends LayoutElement {
  final String path;
  final String label;
  final String dataType;
  final String prefix;
  final String suffix;
  final String nullText;
  final bool hideZeros;
  final bool hideDuplicates;
  final bool canGrow;
  final bool canShrink;
  final bool autoShrink;
  final String aggregate; // 'none' | 'sum' | 'avg' | 'min' | 'max' | 'count'
  final ValueFormat format;

  const FieldElement({
    required super.id,
    super.type = 'field',
    required super.name,
    required super.x,
    required super.y,
    required super.w,
    required super.h,
    super.locked,
    super.style,
    super.box,
    super.rotation,
    super.printable,
    super.visibleExpr,
    super.hyperlink,
    super.growToBottom,
    super.highlights,
    super.script,
    super.rules,
    super.printOn,
    this.path = '',
    this.label = '',
    this.dataType = 'string',
    this.prefix = '',
    this.suffix = '',
    this.nullText = '',
    this.hideZeros = false,
    this.hideDuplicates = false,
    this.canGrow = false,
    this.canShrink = false,
    this.autoShrink = false,
    this.aggregate = 'none',
    this.format = const ValueFormat(),
  });

  @override
  FieldElement copyWith({
    String? id,
    String? type,
    String? name,
    double? x,
    double? y,
    double? w,
    double? h,
    bool? locked,
    TextStyle? style,
    BoxStyle? box,
    double? rotation,
    bool? printable,
    String? visibleExpr,
    String? hyperlink,
    bool? growToBottom,
    List<Highlight>? highlights,
    ElementScript? script,
    List<LogicRule>? rules,
    List<String>? printOn,
    String? path,
    String? label,
    String? dataType,
    String? prefix,
    String? suffix,
    String? nullText,
    bool? hideZeros,
    bool? hideDuplicates,
    bool? canGrow,
    bool? canShrink,
    bool? autoShrink,
    String? aggregate,
    ValueFormat? format,
  }) {
    return FieldElement(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      locked: locked ?? this.locked,
      style: style ?? this.style,
      box: box ?? this.box,
      rotation: rotation ?? this.rotation,
      printable: printable ?? this.printable,
      visibleExpr: visibleExpr ?? this.visibleExpr,
      hyperlink: hyperlink ?? this.hyperlink,
      growToBottom: growToBottom ?? this.growToBottom,
      highlights: highlights ?? this.highlights,
      script: script ?? this.script,
      rules: rules ?? this.rules,
      printOn: printOn ?? this.printOn,
      path: path ?? this.path,
      label: label ?? this.label,
      dataType: dataType ?? this.dataType,
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
      nullText: nullText ?? this.nullText,
      hideZeros: hideZeros ?? this.hideZeros,
      hideDuplicates: hideDuplicates ?? this.hideDuplicates,
      canGrow: canGrow ?? this.canGrow,
      canShrink: canShrink ?? this.canShrink,
      autoShrink: autoShrink ?? this.autoShrink,
      aggregate: aggregate ?? this.aggregate,
      format: format ?? this.format,
    );
  }

  factory FieldElement.fromJson(Map<String, dynamic> json) {
    return FieldElement(
      id: json['id'] as String? ?? '',
      type: 'field',
      name: json['name'] as String? ?? 'Field',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      w: (json['w'] as num?)?.toDouble() ?? 45.0,
      h: (json['h'] as num?)?.toDouble() ?? 6.0,
      locked: json['locked'] as bool? ?? false,
      style: TextStyle.fromJson(json['style'] as Map<String, dynamic>?),
      box: BoxStyle.fromJson(json['box'] as Map<String, dynamic>?),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      printable: json['printable'] as bool? ?? true,
      visibleExpr: json['visibleExpr'] as String? ?? '',
      hyperlink: json['hyperlink'] as String? ?? '',
      growToBottom: json['growToBottom'] as bool? ?? false,
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((h) => Highlight.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      script: json['script'] != null
          ? ElementScript.fromJson(json['script'] as Map<String, dynamic>)
          : null,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((r) => LogicRule.fromJson(r as Map<String, dynamic>))
          .toList(),
      printOn: (json['printOn'] as List<dynamic>?)
          ?.map((p) => p.toString())
          .toList(),
      path: json['path'] as String? ?? '',
      label: json['label'] as String? ?? '',
      dataType: json['dataType'] as String? ?? 'string',
      prefix: json['prefix'] as String? ?? '',
      suffix: json['suffix'] as String? ?? '',
      nullText: json['nullText'] as String? ?? '',
      hideZeros: json['hideZeros'] as bool? ?? false,
      hideDuplicates: json['hideDuplicates'] as bool? ?? false,
      canGrow: json['canGrow'] as bool? ?? false,
      canShrink: json['canShrink'] as bool? ?? false,
      autoShrink: json['autoShrink'] as bool? ?? false,
      aggregate: json['aggregate'] as String? ?? 'none',
      format: ValueFormat.fromJson(json),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'type': type,
      'name': name,
      'x': x,
      'y': y,
      'w': w,
      'h': h,
      'locked': locked,
      'style': style.toJson(),
      'box': box.toJson(),
      'rotation': rotation,
      'printable': printable,
      'visibleExpr': visibleExpr,
      'hyperlink': hyperlink,
      'growToBottom': growToBottom,
      'highlights': highlights.map((h) => h.toJson()).toList(),
      if (script != null) 'script': script!.toJson(),
      if (rules != null) 'rules': rules!.map((r) => r.toJson()).toList(),
      if (printOn != null) 'printOn': printOn,
      'path': path,
      'label': label,
      'dataType': dataType,
      'prefix': prefix,
      'suffix': suffix,
      'nullText': nullText,
      'hideZeros': hideZeros,
      'hideDuplicates': hideDuplicates,
      'canGrow': canGrow,
      'canShrink': canShrink,
      'autoShrink': autoShrink,
      'aggregate': aggregate,
    };
    map.addAll(format.toJson());
    return map;
  }
}

class ImageElement extends LayoutElement {
  final String src;
  final String path;
  final String fit; // 'contain' | 'cover' | 'fill' | 'none'
  final String hAlignImage; // 'left' | 'center' | 'right'
  final String vAlignImage; // 'top' | 'middle' | 'bottom'
  final bool grayscale;
  final double opacity; // 0..1

  const ImageElement({
    required super.id,
    super.type = 'image',
    required super.name,
    required super.x,
    required super.y,
    required super.w,
    required super.h,
    super.locked,
    super.style,
    super.box,
    super.rotation,
    super.printable,
    super.visibleExpr,
    super.hyperlink,
    super.growToBottom,
    super.highlights,
    super.script,
    super.rules,
    super.printOn,
    this.src = '',
    this.path = '',
    this.fit = 'contain',
    this.hAlignImage = 'center',
    this.vAlignImage = 'middle',
    this.grayscale = false,
    this.opacity = 1.0,
  });

  @override
  ImageElement copyWith({
    String? id,
    String? type,
    String? name,
    double? x,
    double? y,
    double? w,
    double? h,
    bool? locked,
    TextStyle? style,
    BoxStyle? box,
    double? rotation,
    bool? printable,
    String? visibleExpr,
    String? hyperlink,
    bool? growToBottom,
    List<Highlight>? highlights,
    ElementScript? script,
    List<LogicRule>? rules,
    List<String>? printOn,
    String? src,
    String? path,
    String? fit,
    String? hAlignImage,
    String? vAlignImage,
    bool? grayscale,
    double? opacity,
  }) {
    return ImageElement(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      locked: locked ?? this.locked,
      style: style ?? this.style,
      box: box ?? this.box,
      rotation: rotation ?? this.rotation,
      printable: printable ?? this.printable,
      visibleExpr: visibleExpr ?? this.visibleExpr,
      hyperlink: hyperlink ?? this.hyperlink,
      growToBottom: growToBottom ?? this.growToBottom,
      highlights: highlights ?? this.highlights,
      script: script ?? this.script,
      rules: rules ?? this.rules,
      printOn: printOn ?? this.printOn,
      src: src ?? this.src,
      path: path ?? this.path,
      fit: fit ?? this.fit,
      hAlignImage: hAlignImage ?? this.hAlignImage,
      vAlignImage: vAlignImage ?? this.vAlignImage,
      grayscale: grayscale ?? this.grayscale,
      opacity: opacity ?? this.opacity,
    );
  }

  factory ImageElement.fromJson(Map<String, dynamic> json) {
    return ImageElement(
      id: json['id'] as String? ?? '',
      type: 'image',
      name: json['name'] as String? ?? 'Picture',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      w: (json['w'] as num?)?.toDouble() ?? 35.0,
      h: (json['h'] as num?)?.toDouble() ?? 25.0,
      locked: json['locked'] as bool? ?? false,
      style: TextStyle.fromJson(json['style'] as Map<String, dynamic>?),
      box: BoxStyle.fromJson(json['box'] as Map<String, dynamic>?),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      printable: json['printable'] as bool? ?? true,
      visibleExpr: json['visibleExpr'] as String? ?? '',
      hyperlink: json['hyperlink'] as String? ?? '',
      growToBottom: json['growToBottom'] as bool? ?? false,
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((h) => Highlight.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      script: json['script'] != null
          ? ElementScript.fromJson(json['script'] as Map<String, dynamic>)
          : null,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((r) => LogicRule.fromJson(r as Map<String, dynamic>))
          .toList(),
      printOn: (json['printOn'] as List<dynamic>?)
          ?.map((p) => p.toString())
          .toList(),
      src: json['src'] as String? ?? '',
      path: json['path'] as String? ?? '',
      fit: json['fit'] as String? ?? 'contain',
      hAlignImage: json['hAlignImage'] as String? ?? 'center',
      vAlignImage: json['vAlignImage'] as String? ?? 'middle',
      grayscale: json['grayscale'] as bool? ?? false,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'x': x,
      'y': y,
      'w': w,
      'h': h,
      'locked': locked,
      'style': style.toJson(),
      'box': box.toJson(),
      'rotation': rotation,
      'printable': printable,
      'visibleExpr': visibleExpr,
      'hyperlink': hyperlink,
      'growToBottom': growToBottom,
      'highlights': highlights.map((h) => h.toJson()).toList(),
      if (script != null) 'script': script!.toJson(),
      if (rules != null) 'rules': rules!.map((r) => r.toJson()).toList(),
      if (printOn != null) 'printOn': printOn,
      'src': src,
      'path': path,
      'fit': fit,
      'hAlignImage': hAlignImage,
      'vAlignImage': vAlignImage,
      'grayscale': grayscale,
      'opacity': opacity,
    };
  }
}

class LineElement extends LayoutElement {
  final String
      direction; // 'horizontal' | 'vertical' | 'diagonal-down' | 'diagonal-up'
  final double thickness; // pt
  final String color;
  final StrokeStyle lineStyle;
  final bool arrowStart;
  final bool arrowEnd;

  const LineElement({
    required super.id,
    super.type = 'line',
    required super.name,
    required super.x,
    required super.y,
    required super.w,
    required super.h,
    super.locked,
    super.style,
    super.box,
    super.rotation,
    super.printable,
    super.visibleExpr,
    super.hyperlink,
    super.growToBottom,
    super.highlights,
    super.script,
    super.rules,
    super.printOn,
    this.direction = 'horizontal',
    this.thickness = 0.75,
    this.color = '#0f172a',
    this.lineStyle = StrokeStyle.solid,
    this.arrowStart = false,
    this.arrowEnd = false,
  });

  @override
  LineElement copyWith({
    String? id,
    String? type,
    String? name,
    double? x,
    double? y,
    double? w,
    double? h,
    bool? locked,
    TextStyle? style,
    BoxStyle? box,
    double? rotation,
    bool? printable,
    String? visibleExpr,
    String? hyperlink,
    bool? growToBottom,
    List<Highlight>? highlights,
    ElementScript? script,
    List<LogicRule>? rules,
    List<String>? printOn,
    String? direction,
    double? thickness,
    String? color,
    StrokeStyle? lineStyle,
    bool? arrowStart,
    bool? arrowEnd,
  }) {
    return LineElement(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      locked: locked ?? this.locked,
      style: style ?? this.style,
      box: box ?? this.box,
      rotation: rotation ?? this.rotation,
      printable: printable ?? this.printable,
      visibleExpr: visibleExpr ?? this.visibleExpr,
      hyperlink: hyperlink ?? this.hyperlink,
      growToBottom: growToBottom ?? this.growToBottom,
      highlights: highlights ?? this.highlights,
      script: script ?? this.script,
      rules: rules ?? this.rules,
      printOn: printOn ?? this.printOn,
      direction: direction ?? this.direction,
      thickness: thickness ?? this.thickness,
      color: color ?? this.color,
      lineStyle: lineStyle ?? this.lineStyle,
      arrowStart: arrowStart ?? this.arrowStart,
      arrowEnd: arrowEnd ?? this.arrowEnd,
    );
  }

  factory LineElement.fromJson(Map<String, dynamic> json) {
    return LineElement(
      id: json['id'] as String? ?? '',
      type: 'line',
      name: json['name'] as String? ?? 'Line',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      w: (json['w'] as num?)?.toDouble() ?? 60.0,
      h: (json['h'] as num?)?.toDouble() ?? 2.0,
      locked: json['locked'] as bool? ?? false,
      style: TextStyle.fromJson(json['style'] as Map<String, dynamic>?),
      box: BoxStyle.fromJson(json['box'] as Map<String, dynamic>?),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      printable: json['printable'] as bool? ?? true,
      visibleExpr: json['visibleExpr'] as String? ?? '',
      hyperlink: json['hyperlink'] as String? ?? '',
      growToBottom: json['growToBottom'] as bool? ?? false,
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((h) => Highlight.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      script: json['script'] != null
          ? ElementScript.fromJson(json['script'] as Map<String, dynamic>)
          : null,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((r) => LogicRule.fromJson(r as Map<String, dynamic>))
          .toList(),
      printOn: (json['printOn'] as List<dynamic>?)
          ?.map((p) => p.toString())
          .toList(),
      direction: json['direction'] as String? ?? 'horizontal',
      thickness: (json['thickness'] as num?)?.toDouble() ?? 0.75,
      color: json['color'] as String? ?? '#0f172a',
      lineStyle: StrokeStyle.fromString(json['lineStyle'] as String?),
      arrowStart: json['arrowStart'] as bool? ?? false,
      arrowEnd: json['arrowEnd'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'x': x,
      'y': y,
      'w': w,
      'h': h,
      'locked': locked,
      'style': style.toJson(),
      'box': box.toJson(),
      'rotation': rotation,
      'printable': printable,
      'visibleExpr': visibleExpr,
      'hyperlink': hyperlink,
      'growToBottom': growToBottom,
      'highlights': highlights.map((h) => h.toJson()).toList(),
      if (script != null) 'script': script!.toJson(),
      if (rules != null) 'rules': rules!.map((r) => r.toJson()).toList(),
      if (printOn != null) 'printOn': printOn,
      'direction': direction,
      'thickness': thickness,
      'color': color,
      'lineStyle': lineStyle.toJson(),
      'arrowStart': arrowStart,
      'arrowEnd': arrowEnd,
    };
  }
}

class ShapeElement extends LayoutElement {
  final String
      shape; // 'rect' | 'roundrect' | 'ellipse' | 'triangle' | 'diamond'

  const ShapeElement({
    required super.id,
    super.type = 'shape',
    required super.name,
    required super.x,
    required super.y,
    required super.w,
    required super.h,
    super.locked,
    super.style,
    super.box,
    super.rotation,
    super.printable,
    super.visibleExpr,
    super.hyperlink,
    super.growToBottom,
    super.highlights,
    super.script,
    super.rules,
    super.printOn,
    this.shape = 'rect',
  });

  @override
  ShapeElement copyWith({
    String? id,
    String? type,
    String? name,
    double? x,
    double? y,
    double? w,
    double? h,
    bool? locked,
    TextStyle? style,
    BoxStyle? box,
    double? rotation,
    bool? printable,
    String? visibleExpr,
    String? hyperlink,
    bool? growToBottom,
    List<Highlight>? highlights,
    ElementScript? script,
    List<LogicRule>? rules,
    List<String>? printOn,
    String? shape,
  }) {
    return ShapeElement(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      locked: locked ?? this.locked,
      style: style ?? this.style,
      box: box ?? this.box,
      rotation: rotation ?? this.rotation,
      printable: printable ?? this.printable,
      visibleExpr: visibleExpr ?? this.visibleExpr,
      hyperlink: hyperlink ?? this.hyperlink,
      growToBottom: growToBottom ?? this.growToBottom,
      highlights: highlights ?? this.highlights,
      script: script ?? this.script,
      rules: rules ?? this.rules,
      printOn: printOn ?? this.printOn,
      shape: shape ?? this.shape,
    );
  }

  factory ShapeElement.fromJson(Map<String, dynamic> json) {
    return ShapeElement(
      id: json['id'] as String? ?? '',
      type: 'shape',
      name: json['name'] as String? ?? 'Shape',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      w: (json['w'] as num?)?.toDouble() ?? 40.0,
      h: (json['h'] as num?)?.toDouble() ?? 20.0,
      locked: json['locked'] as bool? ?? false,
      style: TextStyle.fromJson(json['style'] as Map<String, dynamic>?),
      box: BoxStyle.fromJson(json['box'] as Map<String, dynamic>?),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      printable: json['printable'] as bool? ?? true,
      visibleExpr: json['visibleExpr'] as String? ?? '',
      hyperlink: json['hyperlink'] as String? ?? '',
      growToBottom: json['growToBottom'] as bool? ?? false,
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((h) => Highlight.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      script: json['script'] != null
          ? ElementScript.fromJson(json['script'] as Map<String, dynamic>)
          : null,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((r) => LogicRule.fromJson(r as Map<String, dynamic>))
          .toList(),
      printOn: (json['printOn'] as List<dynamic>?)
          ?.map((p) => p.toString())
          .toList(),
      shape: json['shape'] as String? ?? 'rect',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'x': x,
      'y': y,
      'w': w,
      'h': h,
      'locked': locked,
      'style': style.toJson(),
      'box': box.toJson(),
      'rotation': rotation,
      'printable': printable,
      'visibleExpr': visibleExpr,
      'hyperlink': hyperlink,
      'growToBottom': growToBottom,
      'highlights': highlights.map((h) => h.toJson()).toList(),
      if (script != null) 'script': script!.toJson(),
      if (rules != null) 'rules': rules!.map((r) => r.toJson()).toList(),
      if (printOn != null) 'printOn': printOn,
      'shape': shape,
    };
  }
}

class TableColumn {
  final String id;
  final String header;
  final String field;
  final String dataType;
  final double width; // mm
  final HAlign align;
  final String aggregate; // 'none' | 'sum' | 'count' | 'avg' | 'min' | 'max'
  final ValueFormat format;

  const TableColumn({
    required this.id,
    required this.header,
    required this.field,
    this.dataType = 'string',
    this.width = 20.0,
    this.align = HAlign.left,
    this.aggregate = 'none',
    this.format = const ValueFormat(),
  });

  factory TableColumn.fromJson(Map<String, dynamic> json) {
    return TableColumn(
      id: json['id'] as String? ?? '',
      header: json['header'] as String? ?? '',
      field: json['field'] as String? ?? '',
      dataType: json['dataType'] as String? ?? 'string',
      width: (json['width'] as num?)?.toDouble() ?? 20.0,
      align: HAlign.fromString(json['align'] as String?),
      aggregate: json['aggregate'] as String? ?? 'none',
      format: ValueFormat.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'header': header,
      'field': field,
      'dataType': dataType,
      'width': width,
      'align': align.toJson(),
      'aggregate': aggregate,
    };
    map.addAll(format.toJson());
    return map;
  }
}

class TableElement extends LayoutElement {
  final String arrayPath;
  final List<TableColumn> columns;
  final bool showHeader;
  final bool showFooter;
  final String footerLabel;
  final double headerHeight;
  final double rowHeight;
  final String headerBackground;
  final String headerColor;
  final bool headerBold;
  final String gridLines; // 'none' | 'horizontal' | 'all'
  final String lineColor;
  final double lineWidth;
  final String stripeColor;
  final double cellPadding;

  const TableElement({
    required super.id,
    super.type = 'table',
    required super.name,
    required super.x,
    required super.y,
    required super.w,
    required super.h,
    super.locked,
    super.style,
    super.box,
    super.rotation,
    super.printable,
    super.visibleExpr,
    super.hyperlink,
    super.growToBottom,
    super.highlights,
    super.script,
    super.rules,
    super.printOn,
    this.arrayPath = '',
    this.columns = const [],
    this.showHeader = true,
    this.showFooter = false,
    this.footerLabel = 'Total',
    this.headerHeight = 7.0,
    this.rowHeight = 6.0,
    this.headerBackground = '#e2e8f0',
    this.headerColor = '#0f172a',
    this.headerBold = true,
    this.gridLines = 'horizontal',
    this.lineColor = '#cbd5e1',
    this.lineWidth = 0.5,
    this.stripeColor = '',
    this.cellPadding = 1.0,
  });

  @override
  TableElement copyWith({
    String? id,
    String? type,
    String? name,
    double? x,
    double? y,
    double? w,
    double? h,
    bool? locked,
    TextStyle? style,
    BoxStyle? box,
    double? rotation,
    bool? printable,
    String? visibleExpr,
    String? hyperlink,
    bool? growToBottom,
    List<Highlight>? highlights,
    ElementScript? script,
    List<LogicRule>? rules,
    List<String>? printOn,
    String? arrayPath,
    List<TableColumn>? columns,
    bool? showHeader,
    bool? showFooter,
    String? footerLabel,
    double? headerHeight,
    double? rowHeight,
    String? headerBackground,
    String? headerColor,
    bool? headerBold,
    String? gridLines,
    String? lineColor,
    double? lineWidth,
    String? stripeColor,
    double? cellPadding,
  }) {
    return TableElement(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      locked: locked ?? this.locked,
      style: style ?? this.style,
      box: box ?? this.box,
      rotation: rotation ?? this.rotation,
      printable: printable ?? this.printable,
      visibleExpr: visibleExpr ?? this.visibleExpr,
      hyperlink: hyperlink ?? this.hyperlink,
      growToBottom: growToBottom ?? this.growToBottom,
      highlights: highlights ?? this.highlights,
      script: script ?? this.script,
      rules: rules ?? this.rules,
      printOn: printOn ?? this.printOn,
      arrayPath: arrayPath ?? this.arrayPath,
      columns: columns ?? this.columns,
      showHeader: showHeader ?? this.showHeader,
      showFooter: showFooter ?? this.showFooter,
      footerLabel: footerLabel ?? this.footerLabel,
      headerHeight: headerHeight ?? this.headerHeight,
      rowHeight: rowHeight ?? this.rowHeight,
      headerBackground: headerBackground ?? this.headerBackground,
      headerColor: headerColor ?? this.headerColor,
      headerBold: headerBold ?? this.headerBold,
      gridLines: gridLines ?? this.gridLines,
      lineColor: lineColor ?? this.lineColor,
      lineWidth: lineWidth ?? this.lineWidth,
      stripeColor: stripeColor ?? this.stripeColor,
      cellPadding: cellPadding ?? this.cellPadding,
    );
  }

  factory TableElement.fromJson(Map<String, dynamic> json) {
    return TableElement(
      id: json['id'] as String? ?? '',
      type: 'table',
      name: json['name'] as String? ?? 'Table',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      w: (json['w'] as num?)?.toDouble() ?? 120.0,
      h: (json['h'] as num?)?.toDouble() ?? 50.0,
      locked: json['locked'] as bool? ?? false,
      style: TextStyle.fromJson(json['style'] as Map<String, dynamic>?),
      box: BoxStyle.fromJson(json['box'] as Map<String, dynamic>?),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      printable: json['printable'] as bool? ?? true,
      visibleExpr: json['visibleExpr'] as String? ?? '',
      hyperlink: json['hyperlink'] as String? ?? '',
      growToBottom: json['growToBottom'] as bool? ?? false,
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((h) => Highlight.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      script: json['script'] != null
          ? ElementScript.fromJson(json['script'] as Map<String, dynamic>)
          : null,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((r) => LogicRule.fromJson(r as Map<String, dynamic>))
          .toList(),
      printOn: (json['printOn'] as List<dynamic>?)
          ?.map((p) => p.toString())
          .toList(),
      arrayPath: json['arrayPath'] as String? ?? '',
      columns: (json['columns'] as List<dynamic>?)
              ?.map((c) => TableColumn.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      showHeader: json['showHeader'] as bool? ?? true,
      showFooter: json['showFooter'] as bool? ?? false,
      footerLabel: json['footerLabel'] as String? ?? 'Total',
      headerHeight: (json['headerHeight'] as num?)?.toDouble() ?? 7.0,
      rowHeight: (json['rowHeight'] as num?)?.toDouble() ?? 6.0,
      headerBackground: json['headerBackground'] as String? ?? '#e2e8f0',
      headerColor: json['headerColor'] as String? ?? '#0f172a',
      headerBold: json['headerBold'] as bool? ?? true,
      gridLines: json['gridLines'] as String? ?? 'horizontal',
      lineColor: json['lineColor'] as String? ?? '#cbd5e1',
      lineWidth: (json['lineWidth'] as num?)?.toDouble() ?? 0.5,
      stripeColor: json['stripeColor'] as String? ?? '',
      cellPadding: (json['cellPadding'] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'x': x,
      'y': y,
      'w': w,
      'h': h,
      'locked': locked,
      'style': style.toJson(),
      'box': box.toJson(),
      'rotation': rotation,
      'printable': printable,
      'visibleExpr': visibleExpr,
      'hyperlink': hyperlink,
      'growToBottom': growToBottom,
      'highlights': highlights.map((h) => h.toJson()).toList(),
      if (script != null) 'script': script!.toJson(),
      if (rules != null) 'rules': rules!.map((r) => r.toJson()).toList(),
      if (printOn != null) 'printOn': printOn,
      'arrayPath': arrayPath,
      'columns': columns.map((c) => c.toJson()).toList(),
      'showHeader': showHeader,
      'showFooter': showFooter,
      'footerLabel': footerLabel,
      'headerHeight': headerHeight,
      'rowHeight': rowHeight,
      'headerBackground': headerBackground,
      'headerColor': headerColor,
      'headerBold': headerBold,
      'gridLines': gridLines,
      'lineColor': lineColor,
      'lineWidth': lineWidth,
      'stripeColor': stripeColor,
      'cellPadding': cellPadding,
    };
  }
}

class BarcodeElement extends LayoutElement {
  final String
      symbology; // 'code128', 'ean13', 'qrcode', 'datamatrix', 'pdf417'...
  final String value;
  final bool showText;
  final String barColor;
  final String background;
  final double quietZone; // mm
  final String eccLevel; // 'L' | 'M' | 'Q' | 'H'
  final bool includeCheck;
  final bool stretch;

  const BarcodeElement({
    required super.id,
    super.type = 'barcode',
    required super.name,
    required super.x,
    required super.y,
    required super.w,
    required super.h,
    super.locked,
    super.style,
    super.box,
    super.rotation,
    super.printable,
    super.visibleExpr,
    super.hyperlink,
    super.growToBottom,
    super.highlights,
    super.script,
    super.rules,
    super.printOn,
    this.symbology = 'code128',
    this.value = '123456789012',
    this.showText = true,
    this.barColor = '#000000',
    this.background = '',
    this.quietZone = 0.0,
    this.eccLevel = 'M',
    this.includeCheck = false,
    this.stretch = true,
  });

  @override
  BarcodeElement copyWith({
    String? id,
    String? type,
    String? name,
    double? x,
    double? y,
    double? w,
    double? h,
    bool? locked,
    TextStyle? style,
    BoxStyle? box,
    double? rotation,
    bool? printable,
    String? visibleExpr,
    String? hyperlink,
    bool? growToBottom,
    List<Highlight>? highlights,
    ElementScript? script,
    List<LogicRule>? rules,
    List<String>? printOn,
    String? symbology,
    String? value,
    bool? showText,
    String? barColor,
    String? background,
    double? quietZone,
    String? eccLevel,
    bool? includeCheck,
    bool? stretch,
  }) {
    return BarcodeElement(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      locked: locked ?? this.locked,
      style: style ?? this.style,
      box: box ?? this.box,
      rotation: rotation ?? this.rotation,
      printable: printable ?? this.printable,
      visibleExpr: visibleExpr ?? this.visibleExpr,
      hyperlink: hyperlink ?? this.hyperlink,
      growToBottom: growToBottom ?? this.growToBottom,
      highlights: highlights ?? this.highlights,
      script: script ?? this.script,
      rules: rules ?? this.rules,
      printOn: printOn ?? this.printOn,
      symbology: symbology ?? this.symbology,
      value: value ?? this.value,
      showText: showText ?? this.showText,
      barColor: barColor ?? this.barColor,
      background: background ?? this.background,
      quietZone: quietZone ?? this.quietZone,
      eccLevel: eccLevel ?? this.eccLevel,
      includeCheck: includeCheck ?? this.includeCheck,
      stretch: stretch ?? this.stretch,
    );
  }

  factory BarcodeElement.fromJson(Map<String, dynamic> json) {
    return BarcodeElement(
      id: json['id'] as String? ?? '',
      type: 'barcode',
      name: json['name'] as String? ?? 'Barcode',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      w: (json['w'] as num?)?.toDouble() ?? 50.0,
      h: (json['h'] as num?)?.toDouble() ?? 15.0,
      locked: json['locked'] as bool? ?? false,
      style: TextStyle.fromJson(json['style'] as Map<String, dynamic>?),
      box: BoxStyle.fromJson(json['box'] as Map<String, dynamic>?),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      printable: json['printable'] as bool? ?? true,
      visibleExpr: json['visibleExpr'] as String? ?? '',
      hyperlink: json['hyperlink'] as String? ?? '',
      growToBottom: json['growToBottom'] as bool? ?? false,
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((h) => Highlight.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      script: json['script'] != null
          ? ElementScript.fromJson(json['script'] as Map<String, dynamic>)
          : null,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((r) => LogicRule.fromJson(r as Map<String, dynamic>))
          .toList(),
      printOn: (json['printOn'] as List<dynamic>?)
          ?.map((p) => p.toString())
          .toList(),
      symbology: json['symbology'] as String? ?? 'code128',
      value: json['value'] as String? ?? '',
      showText: json['showText'] as bool? ?? false,
      barColor: json['barColor'] as String? ?? '#000000',
      background: json['background'] as String? ?? '',
      quietZone: (json['quietZone'] as num?)?.toDouble() ?? 0.0,
      eccLevel: json['eccLevel'] as String? ?? 'M',
      includeCheck: json['includeCheck'] as bool? ?? false,
      stretch: json['stretch'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'x': x,
      'y': y,
      'w': w,
      'h': h,
      'locked': locked,
      'style': style.toJson(),
      'box': box.toJson(),
      'rotation': rotation,
      'printable': printable,
      'visibleExpr': visibleExpr,
      'hyperlink': hyperlink,
      'growToBottom': growToBottom,
      'highlights': highlights.map((h) => h.toJson()).toList(),
      if (script != null) 'script': script!.toJson(),
      if (rules != null) 'rules': rules!.map((r) => r.toJson()).toList(),
      if (printOn != null) 'printOn': printOn,
      'symbology': symbology,
      'value': value,
      'showText': showText,
      'barColor': barColor,
      'background': background,
      'quietZone': quietZone,
      'eccLevel': eccLevel,
      'includeCheck': includeCheck,
      'stretch': stretch,
    };
  }
}

class CheckboxElement extends LayoutElement {
  final String expr;
  final String mark; // 'check' | 'cross' | 'fill'
  final String markColor;
  final bool uncheckedHidden;

  const CheckboxElement({
    required super.id,
    super.type = 'checkbox',
    required super.name,
    required super.x,
    required super.y,
    required super.w,
    required super.h,
    super.locked,
    super.style,
    super.box,
    super.rotation,
    super.printable,
    super.visibleExpr,
    super.hyperlink,
    super.growToBottom,
    super.highlights,
    super.script,
    super.rules,
    super.printOn,
    this.expr = 'true',
    this.mark = 'check',
    this.markColor = '#0f172a',
    this.uncheckedHidden = false,
  });

  @override
  CheckboxElement copyWith({
    String? id,
    String? type,
    String? name,
    double? x,
    double? y,
    double? w,
    double? h,
    bool? locked,
    TextStyle? style,
    BoxStyle? box,
    double? rotation,
    bool? printable,
    String? visibleExpr,
    String? hyperlink,
    bool? growToBottom,
    List<Highlight>? highlights,
    ElementScript? script,
    List<LogicRule>? rules,
    List<String>? printOn,
    String? expr,
    String? mark,
    String? markColor,
    bool? uncheckedHidden,
  }) {
    return CheckboxElement(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      locked: locked ?? this.locked,
      style: style ?? this.style,
      box: box ?? this.box,
      rotation: rotation ?? this.rotation,
      printable: printable ?? this.printable,
      visibleExpr: visibleExpr ?? this.visibleExpr,
      hyperlink: hyperlink ?? this.hyperlink,
      growToBottom: growToBottom ?? this.growToBottom,
      highlights: highlights ?? this.highlights,
      script: script ?? this.script,
      rules: rules ?? this.rules,
      printOn: printOn ?? this.printOn,
      expr: expr ?? this.expr,
      mark: mark ?? this.mark,
      markColor: markColor ?? this.markColor,
      uncheckedHidden: uncheckedHidden ?? this.uncheckedHidden,
    );
  }

  factory CheckboxElement.fromJson(Map<String, dynamic> json) {
    return CheckboxElement(
      id: json['id'] as String? ?? '',
      type: 'checkbox',
      name: json['name'] as String? ?? 'CheckBox',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      w: (json['w'] as num?)?.toDouble() ?? 4.0,
      h: (json['h'] as num?)?.toDouble() ?? 4.0,
      locked: json['locked'] as bool? ?? false,
      style: TextStyle.fromJson(json['style'] as Map<String, dynamic>?),
      box: BoxStyle.fromJson(json['box'] as Map<String, dynamic>?),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      printable: json['printable'] as bool? ?? true,
      visibleExpr: json['visibleExpr'] as String? ?? '',
      hyperlink: json['hyperlink'] as String? ?? '',
      growToBottom: json['growToBottom'] as bool? ?? false,
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((h) => Highlight.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      script: json['script'] != null
          ? ElementScript.fromJson(json['script'] as Map<String, dynamic>)
          : null,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((r) => LogicRule.fromJson(r as Map<String, dynamic>))
          .toList(),
      printOn: (json['printOn'] as List<dynamic>?)
          ?.map((p) => p.toString())
          .toList(),
      expr: json['expr'] as String? ?? 'true',
      mark: json['mark'] as String? ?? 'check',
      markColor: json['markColor'] as String? ?? '#0f172a',
      uncheckedHidden: json['uncheckedHidden'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'x': x,
      'y': y,
      'w': w,
      'h': h,
      'locked': locked,
      'style': style.toJson(),
      'box': box.toJson(),
      'rotation': rotation,
      'printable': printable,
      'visibleExpr': visibleExpr,
      'hyperlink': hyperlink,
      'growToBottom': growToBottom,
      'highlights': highlights.map((h) => h.toJson()).toList(),
      if (script != null) 'script': script!.toJson(),
      if (rules != null) 'rules': rules!.map((r) => r.toJson()).toList(),
      if (printOn != null) 'printOn': printOn,
      'expr': expr,
      'mark': mark,
      'markColor': markColor,
      'uncheckedHidden': uncheckedHidden,
    };
  }
}

class ChartElement extends LayoutElement {
  final String
      chartType; // 'column' | 'bar' | 'line' | 'area' | 'pie' | 'doughnut'
  final String dataPath;
  final String labelField;
  final String valueField;
  final String title;
  final List<String> colors;
  final bool showLegend;
  final bool showValues;
  final bool showGrid;

  const ChartElement({
    required super.id,
    super.type = 'chart',
    required super.name,
    required super.x,
    required super.y,
    required super.w,
    required super.h,
    super.locked,
    super.style,
    super.box,
    super.rotation,
    super.printable,
    super.visibleExpr,
    super.hyperlink,
    super.growToBottom,
    super.highlights,
    super.script,
    super.rules,
    super.printOn,
    this.chartType = 'column',
    this.dataPath = '',
    this.labelField = '',
    this.valueField = '',
    this.title = '',
    this.colors = const [
      '#4f46e5',
      '#0891b2',
      '#059669',
      '#d97706',
      '#dc2626',
      '#7c3aed',
      '#db2777',
      '#65a30d'
    ],
    this.showLegend = true,
    this.showValues = true,
    this.showGrid = true,
  });

  @override
  ChartElement copyWith({
    String? id,
    String? type,
    String? name,
    double? x,
    double? y,
    double? w,
    double? h,
    bool? locked,
    TextStyle? style,
    BoxStyle? box,
    double? rotation,
    bool? printable,
    String? visibleExpr,
    String? hyperlink,
    bool? growToBottom,
    List<Highlight>? highlights,
    ElementScript? script,
    List<LogicRule>? rules,
    List<String>? printOn,
    String? chartType,
    String? dataPath,
    String? labelField,
    String? valueField,
    String? title,
    List<String>? colors,
    bool? showLegend,
    bool? showValues,
    bool? showGrid,
  }) {
    return ChartElement(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      locked: locked ?? this.locked,
      style: style ?? this.style,
      box: box ?? this.box,
      rotation: rotation ?? this.rotation,
      printable: printable ?? this.printable,
      visibleExpr: visibleExpr ?? this.visibleExpr,
      hyperlink: hyperlink ?? this.hyperlink,
      growToBottom: growToBottom ?? this.growToBottom,
      highlights: highlights ?? this.highlights,
      script: script ?? this.script,
      rules: rules ?? this.rules,
      printOn: printOn ?? this.printOn,
      chartType: chartType ?? this.chartType,
      dataPath: dataPath ?? this.dataPath,
      labelField: labelField ?? this.labelField,
      valueField: valueField ?? this.valueField,
      title: title ?? this.title,
      colors: colors ?? this.colors,
      showLegend: showLegend ?? this.showLegend,
      showValues: showValues ?? this.showValues,
      showGrid: showGrid ?? this.showGrid,
    );
  }

  factory ChartElement.fromJson(Map<String, dynamic> json) {
    return ChartElement(
      id: json['id'] as String? ?? '',
      type: 'chart',
      name: json['name'] as String? ?? 'Chart',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      w: (json['w'] as num?)?.toDouble() ?? 90.0,
      h: (json['h'] as num?)?.toDouble() ?? 55.0,
      locked: json['locked'] as bool? ?? false,
      style: TextStyle.fromJson(json['style'] as Map<String, dynamic>?),
      box: BoxStyle.fromJson(json['box'] as Map<String, dynamic>?),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      printable: json['printable'] as bool? ?? true,
      visibleExpr: json['visibleExpr'] as String? ?? '',
      hyperlink: json['hyperlink'] as String? ?? '',
      growToBottom: json['growToBottom'] as bool? ?? false,
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((h) => Highlight.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      script: json['script'] != null
          ? ElementScript.fromJson(json['script'] as Map<String, dynamic>)
          : null,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((r) => LogicRule.fromJson(r as Map<String, dynamic>))
          .toList(),
      printOn: (json['printOn'] as List<dynamic>?)
          ?.map((p) => p.toString())
          .toList(),
      chartType: json['chartType'] as String? ?? 'column',
      dataPath: json['dataPath'] as String? ?? '',
      labelField: json['labelField'] as String? ?? '',
      valueField: json['valueField'] as String? ?? '',
      title: json['title'] as String? ?? '',
      colors: (json['colors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [
            '#4f46e5',
            '#0891b2',
            '#059669',
            '#d97706',
            '#dc2626',
            '#7c3aed',
            '#db2777',
            '#65a30d'
          ],
      showLegend: json['showLegend'] as bool? ?? true,
      showValues: json['showValues'] as bool? ?? true,
      showGrid: json['showGrid'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'x': x,
      'y': y,
      'w': w,
      'h': h,
      'locked': locked,
      'style': style.toJson(),
      'box': box.toJson(),
      'rotation': rotation,
      'printable': printable,
      'visibleExpr': visibleExpr,
      'hyperlink': hyperlink,
      'growToBottom': growToBottom,
      'highlights': highlights.map((h) => h.toJson()).toList(),
      if (script != null) 'script': script!.toJson(),
      if (rules != null) 'rules': rules!.map((r) => r.toJson()).toList(),
      if (printOn != null) 'printOn': printOn,
      'chartType': chartType,
      'dataPath': dataPath,
      'labelField': labelField,
      'valueField': valueField,
      'title': title,
      'colors': colors,
      'showLegend': showLegend,
      'showValues': showValues,
      'showGrid': showGrid,
    };
  }
}

class SubReportElement extends LayoutElement {
  final LayoutDocument? reportDoc;
  final String reportFileName;
  final String dataPath;
  final bool passParams;

  const SubReportElement({
    required super.id,
    super.type = 'subreport',
    required super.name,
    required super.x,
    required super.y,
    required super.w,
    required super.h,
    super.locked,
    super.style,
    super.box,
    super.rotation,
    super.printable,
    super.visibleExpr,
    super.hyperlink,
    super.growToBottom,
    super.highlights,
    super.script,
    super.rules,
    super.printOn,
    this.reportDoc,
    this.reportFileName = '',
    this.dataPath = '',
    this.passParams = true,
  });

  @override
  SubReportElement copyWith({
    String? id,
    String? type,
    String? name,
    double? x,
    double? y,
    double? w,
    double? h,
    bool? locked,
    TextStyle? style,
    BoxStyle? box,
    double? rotation,
    bool? printable,
    String? visibleExpr,
    String? hyperlink,
    bool? growToBottom,
    List<Highlight>? highlights,
    ElementScript? script,
    List<LogicRule>? rules,
    List<String>? printOn,
    LayoutDocument? reportDoc,
    String? reportFileName,
    String? dataPath,
    bool? passParams,
  }) {
    return SubReportElement(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
      locked: locked ?? this.locked,
      style: style ?? this.style,
      box: box ?? this.box,
      rotation: rotation ?? this.rotation,
      printable: printable ?? this.printable,
      visibleExpr: visibleExpr ?? this.visibleExpr,
      hyperlink: hyperlink ?? this.hyperlink,
      growToBottom: growToBottom ?? this.growToBottom,
      highlights: highlights ?? this.highlights,
      script: script ?? this.script,
      rules: rules ?? this.rules,
      printOn: printOn ?? this.printOn,
      reportDoc: reportDoc ?? this.reportDoc,
      reportFileName: reportFileName ?? this.reportFileName,
      dataPath: dataPath ?? this.dataPath,
      passParams: passParams ?? this.passParams,
    );
  }

  factory SubReportElement.fromJson(Map<String, dynamic> json) {
    return SubReportElement(
      id: json['id'] as String? ?? '',
      type: 'subreport',
      name: json['name'] as String? ?? 'SubReport',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      w: (json['w'] as num?)?.toDouble() ?? 80.0,
      h: (json['h'] as num?)?.toDouble() ?? 40.0,
      locked: json['locked'] as bool? ?? false,
      style: TextStyle.fromJson(json['style'] as Map<String, dynamic>?),
      box: BoxStyle.fromJson(json['box'] as Map<String, dynamic>?),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      printable: json['printable'] as bool? ?? true,
      visibleExpr: json['visibleExpr'] as String? ?? '',
      hyperlink: json['hyperlink'] as String? ?? '',
      growToBottom: json['growToBottom'] as bool? ?? false,
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((h) => Highlight.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      script: json['script'] != null
          ? ElementScript.fromJson(json['script'] as Map<String, dynamic>)
          : null,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((r) => LogicRule.fromJson(r as Map<String, dynamic>))
          .toList(),
      printOn: (json['printOn'] as List<dynamic>?)
          ?.map((p) => p.toString())
          .toList(),
      reportDoc: json['reportDoc'] != null
          ? LayoutDocument.fromJson(json['reportDoc'] as Map<String, dynamic>)
          : null,
      reportFileName: json['reportFileName'] as String? ?? '',
      dataPath: json['dataPath'] as String? ?? '',
      passParams: json['passParams'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'x': x,
      'y': y,
      'w': w,
      'h': h,
      'locked': locked,
      'style': style.toJson(),
      'box': box.toJson(),
      'rotation': rotation,
      'printable': printable,
      'visibleExpr': visibleExpr,
      'hyperlink': hyperlink,
      'growToBottom': growToBottom,
      'highlights': highlights.map((h) => h.toJson()).toList(),
      if (script != null) 'script': script!.toJson(),
      if (rules != null) 'rules': rules!.map((r) => r.toJson()).toList(),
      if (printOn != null) 'printOn': printOn,
      if (reportDoc != null) 'reportDoc': reportDoc!.toJson(),
      'reportFileName': reportFileName,
      'dataPath': dataPath,
      'passParams': passParams,
    };
  }
}

/* ------------------------------------------------------------------ */
/* Bands                                                               */
/* ------------------------------------------------------------------ */

class Band {
  final String id;
  final String
      type; // 'reportTitle' | 'pageHeader' | 'dataHeader' | 'groupHeader' | 'data' | 'groupFooter' | 'dataFooter' | 'reportSummary' | 'pageFooter' | 'overlay' | 'child'
  final String name;
  final double height; // mm
  final bool canGrow;
  final bool canShrink;
  final String visibleExpr;
  final String fill;
  final bool startNewPage;
  final bool printOnFirstPage;
  final bool printOnLastPage;
  final bool repeatOnEveryPage;
  final List<LayoutElement> elements;
  final BandScript? script;
  final Band? child;
  final bool fillUnusedSpace;
  final bool keepWithParent;
  final bool printIfDatabandEmpty;
  final List<LogicRule>? rules;
  final List<String>? printOn;

  const Band({
    required this.id,
    required this.type,
    required this.name,
    this.height = 10.0,
    this.canGrow = false,
    this.canShrink = false,
    this.visibleExpr = '',
    this.fill = '',
    this.startNewPage = false,
    this.printOnFirstPage = true,
    this.printOnLastPage = true,
    this.repeatOnEveryPage = false,
    this.elements = const [],
    this.script,
    this.child,
    this.fillUnusedSpace = false,
    this.keepWithParent = false,
    this.printIfDatabandEmpty = false,
    this.rules,
    this.printOn,
  });

  Band copyWith({
    String? id,
    String? type,
    String? name,
    double? height,
    bool? canGrow,
    bool? canShrink,
    String? visibleExpr,
    String? fill,
    bool? startNewPage,
    bool? printOnFirstPage,
    bool? printOnLastPage,
    bool? repeatOnEveryPage,
    List<LayoutElement>? elements,
    BandScript? script,
    Band? child,
    bool? fillUnusedSpace,
    bool? keepWithParent,
    bool? printIfDatabandEmpty,
    List<LogicRule>? rules,
    List<String>? printOn,
  }) {
    return Band(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      height: height ?? this.height,
      canGrow: canGrow ?? this.canGrow,
      canShrink: canShrink ?? this.canShrink,
      visibleExpr: visibleExpr ?? this.visibleExpr,
      fill: fill ?? this.fill,
      startNewPage: startNewPage ?? this.startNewPage,
      printOnFirstPage: printOnFirstPage ?? this.printOnFirstPage,
      printOnLastPage: printOnLastPage ?? this.printOnLastPage,
      repeatOnEveryPage: repeatOnEveryPage ?? this.repeatOnEveryPage,
      elements: elements ?? this.elements,
      script: script ?? this.script,
      child: child ?? this.child,
      fillUnusedSpace: fillUnusedSpace ?? this.fillUnusedSpace,
      keepWithParent: keepWithParent ?? this.keepWithParent,
      printIfDatabandEmpty: printIfDatabandEmpty ?? this.printIfDatabandEmpty,
      rules: rules ?? this.rules,
      printOn: printOn ?? this.printOn,
    );
  }

  factory Band.fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'data') {
      return DataBand.fromJson(json);
    }
    return Band(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'reportTitle',
      name: json['name'] as String? ?? '',
      height: (json['height'] as num?)?.toDouble() ?? 10.0,
      canGrow: json['canGrow'] as bool? ?? false,
      canShrink: json['canShrink'] as bool? ?? false,
      visibleExpr: json['visibleExpr'] as String? ?? '',
      fill: json['fill'] as String? ?? '',
      startNewPage: json['startNewPage'] as bool? ?? false,
      printOnFirstPage: json['printOnFirstPage'] as bool? ?? true,
      printOnLastPage: json['printOnLastPage'] as bool? ?? true,
      repeatOnEveryPage: json['repeatOnEveryPage'] as bool? ?? false,
      elements: (json['elements'] as List<dynamic>?)
              ?.map((e) => LayoutElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      script: json['script'] != null
          ? BandScript.fromJson(json['script'] as Map<String, dynamic>)
          : null,
      child: json['child'] != null
          ? Band.fromJson(json['child'] as Map<String, dynamic>)
          : null,
      fillUnusedSpace: json['fillUnusedSpace'] as bool? ?? false,
      keepWithParent: json['keepWithParent'] as bool? ?? false,
      printIfDatabandEmpty: json['printIfDatabandEmpty'] as bool? ?? false,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((r) => LogicRule.fromJson(r as Map<String, dynamic>))
          .toList(),
      printOn: (json['printOn'] as List<dynamic>?)
          ?.map((p) => p.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'height': height,
      'canGrow': canGrow,
      'canShrink': canShrink,
      'visibleExpr': visibleExpr,
      'fill': fill,
      'startNewPage': startNewPage,
      'printOnFirstPage': printOnFirstPage,
      'printOnLastPage': printOnLastPage,
      'repeatOnEveryPage': repeatOnEveryPage,
      'elements': elements.map((e) => e.toJson()).toList(),
      if (script != null) 'script': script!.toJson(),
      if (child != null) 'child': child!.toJson(),
      'fillUnusedSpace': fillUnusedSpace,
      'keepWithParent': keepWithParent,
      'printIfDatabandEmpty': printIfDatabandEmpty,
      if (rules != null) 'rules': rules!.map((r) => r.toJson()).toList(),
      if (printOn != null) 'printOn': printOn,
    };
  }
}

class GroupLevel {
  final String id;
  final String condition;
  final Band header;
  final Band? footer;

  const GroupLevel({
    required this.id,
    required this.condition,
    required this.header,
    this.footer,
  });

  GroupLevel copyWith({
    String? id,
    String? condition,
    Band? header,
    Band? footer,
  }) {
    return GroupLevel(
      id: id ?? this.id,
      condition: condition ?? this.condition,
      header: header ?? this.header,
      footer: footer ?? this.footer,
    );
  }

  factory GroupLevel.fromJson(Map<String, dynamic> json) {
    return GroupLevel(
      id: json['id'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      header: Band.fromJson(json['header'] as Map<String, dynamic>),
      footer: json['footer'] != null
          ? Band.fromJson(json['footer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'condition': condition,
      'header': header.toJson(),
      if (footer != null) 'footer': footer!.toJson(),
    };
  }
}

class DataBand extends Band {
  final String dataPath;
  final String alias;
  final String sortBy;
  final bool sortDesc;
  final String filterExpr;
  final int maxRows;
  final bool printIfEmpty;
  final String evenFill;
  final int columns;
  final double columnGap; // mm
  final Band? header;
  final Band? footer;
  final List<GroupLevel> groups;
  final DataBand? detail;

  const DataBand({
    required super.id,
    super.type = 'data',
    required super.name,
    super.height = 7.0,
    super.canGrow,
    super.canShrink,
    super.visibleExpr,
    super.fill,
    super.startNewPage,
    super.printOnFirstPage,
    super.printOnLastPage,
    super.repeatOnEveryPage,
    super.elements,
    super.script,
    super.child,
    super.fillUnusedSpace,
    super.keepWithParent,
    super.printIfDatabandEmpty,
    super.rules,
    super.printOn,
    this.dataPath = '',
    this.alias = 'item',
    this.sortBy = '',
    this.sortDesc = false,
    this.filterExpr = '',
    this.maxRows = 0,
    this.printIfEmpty = false,
    this.evenFill = '',
    this.columns = 1,
    this.columnGap = 0.0,
    this.header,
    this.footer,
    this.groups = const [],
    this.detail,
  });

  @override
  DataBand copyWith({
    String? id,
    String? type,
    String? name,
    double? height,
    bool? canGrow,
    bool? canShrink,
    String? visibleExpr,
    String? fill,
    bool? startNewPage,
    bool? printOnFirstPage,
    bool? printOnLastPage,
    bool? repeatOnEveryPage,
    List<LayoutElement>? elements,
    BandScript? script,
    Band? child,
    bool? fillUnusedSpace,
    bool? keepWithParent,
    bool? printIfDatabandEmpty,
    List<LogicRule>? rules,
    List<String>? printOn,
    String? dataPath,
    String? alias,
    String? sortBy,
    bool? sortDesc,
    String? filterExpr,
    int? maxRows,
    bool? printIfEmpty,
    String? evenFill,
    int? columns,
    double? columnGap,
    Band? header,
    Band? footer,
    List<GroupLevel>? groups,
    DataBand? detail,
  }) {
    return DataBand(
      id: id ?? this.id,
      name: name ?? this.name,
      height: height ?? this.height,
      canGrow: canGrow ?? this.canGrow,
      canShrink: canShrink ?? this.canShrink,
      visibleExpr: visibleExpr ?? this.visibleExpr,
      fill: fill ?? this.fill,
      startNewPage: startNewPage ?? this.startNewPage,
      printOnFirstPage: printOnFirstPage ?? this.printOnFirstPage,
      printOnLastPage: printOnLastPage ?? this.printOnLastPage,
      repeatOnEveryPage: repeatOnEveryPage ?? this.repeatOnEveryPage,
      elements: elements ?? this.elements,
      script: script ?? this.script,
      child: child ?? this.child,
      fillUnusedSpace: fillUnusedSpace ?? this.fillUnusedSpace,
      keepWithParent: keepWithParent ?? this.keepWithParent,
      printIfDatabandEmpty: printIfDatabandEmpty ?? this.printIfDatabandEmpty,
      rules: rules ?? this.rules,
      printOn: printOn ?? this.printOn,
      dataPath: dataPath ?? this.dataPath,
      alias: alias ?? this.alias,
      sortBy: sortBy ?? this.sortBy,
      sortDesc: sortDesc ?? this.sortDesc,
      filterExpr: filterExpr ?? this.filterExpr,
      maxRows: maxRows ?? this.maxRows,
      printIfEmpty: printIfEmpty ?? this.printIfEmpty,
      evenFill: evenFill ?? this.evenFill,
      columns: columns ?? this.columns,
      columnGap: columnGap ?? this.columnGap,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      groups: groups ?? this.groups,
      detail: detail ?? this.detail,
    );
  }

  factory DataBand.fromJson(Map<String, dynamic> json) {
    return DataBand(
      id: json['id'] as String? ?? '',
      type: 'data',
      name: json['name'] as String? ?? 'Data',
      height: (json['height'] as num?)?.toDouble() ?? 7.0,
      canGrow: json['canGrow'] as bool? ?? false,
      canShrink: json['canShrink'] as bool? ?? false,
      visibleExpr: json['visibleExpr'] as String? ?? '',
      fill: json['fill'] as String? ?? '',
      startNewPage: json['startNewPage'] as bool? ?? false,
      printOnFirstPage: json['printOnFirstPage'] as bool? ?? true,
      printOnLastPage: json['printOnLastPage'] as bool? ?? true,
      repeatOnEveryPage: json['repeatOnEveryPage'] as bool? ?? false,
      elements: (json['elements'] as List<dynamic>?)
              ?.map((e) => LayoutElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      script: json['script'] != null
          ? BandScript.fromJson(json['script'] as Map<String, dynamic>)
          : null,
      child: json['child'] != null
          ? Band.fromJson(json['child'] as Map<String, dynamic>)
          : null,
      fillUnusedSpace: json['fillUnusedSpace'] as bool? ?? false,
      keepWithParent: json['keepWithParent'] as bool? ?? false,
      printIfDatabandEmpty: json['printIfDatabandEmpty'] as bool? ?? false,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((r) => LogicRule.fromJson(r as Map<String, dynamic>))
          .toList(),
      printOn: (json['printOn'] as List<dynamic>?)
          ?.map((p) => p.toString())
          .toList(),
      dataPath: json['dataPath'] as String? ?? '',
      alias: json['alias'] as String? ?? 'item',
      sortBy: json['sortBy'] as String? ?? '',
      sortDesc: json['sortDesc'] as bool? ?? false,
      filterExpr: json['filterExpr'] as String? ?? '',
      maxRows: (json['maxRows'] as num?)?.toInt() ?? 0,
      printIfEmpty: json['printIfEmpty'] as bool? ?? false,
      evenFill: json['evenFill'] as String? ?? '',
      columns: (json['columns'] as num?)?.toInt() ?? 1,
      columnGap: (json['columnGap'] as num?)?.toDouble() ?? 0.0,
      header: json['header'] != null
          ? Band.fromJson(json['header'] as Map<String, dynamic>)
          : null,
      footer: json['footer'] != null
          ? Band.fromJson(json['footer'] as Map<String, dynamic>)
          : null,
      groups: (json['groups'] as List<dynamic>?)
              ?.map((g) => GroupLevel.fromJson(g as Map<String, dynamic>))
              .toList() ??
          [],
      detail: json['detail'] != null
          ? DataBand.fromJson(json['detail'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'dataPath': dataPath,
      'alias': alias,
      'sortBy': sortBy,
      'sortDesc': sortDesc,
      'filterExpr': filterExpr,
      'maxRows': maxRows,
      'printIfEmpty': printIfEmpty,
      'evenFill': evenFill,
      'columns': columns,
      'columnGap': columnGap,
      if (header != null) 'header': header!.toJson(),
      if (footer != null) 'footer': footer!.toJson(),
      'groups': groups.map((g) => g.toJson()).toList(),
      if (detail != null) 'detail': detail!.toJson(),
    });
    return map;
  }
}
