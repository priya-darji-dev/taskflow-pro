class BoardModel {
  final String id;
  final String title;
  final String description;
  final int colorHex;
  final DateTime createdAt;
  final int totalTasks;
  final int completedTasks;

  const BoardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.colorHex,
    required this.createdAt,
    this.totalTasks = 0,
    this.completedTasks = 0,
  });

  /// Calculates completion ratio between 0.0 and 1.0 for Linear/Circular progress bars
  double get progress => totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

  /// Converts model to SQLite table map (excludes computed aggregate fields)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'color_hex': colorHex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Parses SQLite row including aggregate JOIN counts
  factory BoardModel.fromMap(Map<String, dynamic> map) {
    return BoardModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      colorHex: map['color_hex'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      totalTasks: (map['total_tasks'] as num?)?.toInt() ?? 0,
      completedTasks: (map['completed_tasks'] as num?)?.toInt() ?? 0,
    );
  }

  BoardModel copyWith({
    String? id,
    String? title,
    String? description,
    int? colorHex,
    DateTime? createdAt,
    int? totalTasks,
    int? completedTasks,
  }) {
    return BoardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
    );
  }
}