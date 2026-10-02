/// Schema models for report parameters and data sources.
class SchemaField {
  final String key;
  final String label;
  final String type;
  final String path;
  final String? format;
  final String? description;
  final List<SchemaField>? children;

  const SchemaField({
    required this.key,
    required this.label,
    required this.type,
    required this.path,
    this.format,
    this.description,
    this.children,
  });

  factory SchemaField.fromJson(Map<String, dynamic> json) {
    return SchemaField(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      type: json['type'] as String? ?? 'string',
      path: json['path'] as String? ?? '',
      format: json['format'] as String?,
      description: json['description'] as String?,
      children: (json['children'] as List<dynamic>?)
          ?.map((c) => SchemaField.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'type': type,
      'path': path,
      if (format != null) 'format': format,
      if (description != null) 'description': description,
      if (children != null)
        'children': children!.map((c) => c.toJson()).toList(),
    };
  }
}

class SchemaGroup {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final List<SchemaField> fields;

  const SchemaGroup({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.fields = const [],
  });

  factory SchemaGroup.fromJson(Map<String, dynamic> json) {
    return SchemaGroup(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      fields: (json['fields'] as List<dynamic>?)
              ?.map((f) => SchemaField.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      'fields': fields.map((f) => f.toJson()).toList(),
    };
  }
}

class ReportParameter {
  final String id;
  final String name;
  final String label;
  final String type; // 'string' | 'number' | 'date' | 'boolean' | 'select'
  final dynamic defaultValue;
  final List<String>? options;
  final bool required;
  final String? description;

  const ReportParameter({
    required this.id,
    required this.name,
    required this.label,
    this.type = 'string',
    this.defaultValue,
    this.options,
    this.required = false,
    this.description,
  });

  factory ReportParameter.fromJson(Map<String, dynamic> json) {
    return ReportParameter(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      label: json['label'] as String? ?? '',
      type: json['type'] as String? ?? 'string',
      defaultValue: json['defaultValue'],
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      required: json['required'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'label': label,
      'type': type,
      if (defaultValue != null) 'defaultValue': defaultValue,
      if (options != null) 'options': options,
      'required': required,
      if (description != null) 'description': description,
    };
  }
}
