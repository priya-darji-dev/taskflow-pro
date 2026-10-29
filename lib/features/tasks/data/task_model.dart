class TaskModel {
  final String id;
  final String boardId;
  final String title;
  final String description;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final String status;   // 'todo', 'in_progress', 'done'
  final DateTime dueDate;
  final String tag;
  final DateTime createdAt;
  final int totalSubtasks;
  final int completedSubtasks;

  const TaskModel({
    required this.id,
    required this.boardId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.tag,
    required this.createdAt,
    this.totalSubtasks = 0,
    this.completedSubtasks = 0,
  });

  /// Checks if the task is past its due date and not yet completed
  bool get isOverdue {
    if (status == 'done') return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueDay.isBefore(today);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'board_id': boardId,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'due_date': dueDate.toIso8601String(),
      'tag': tag,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      boardId: map['board_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      priority: map['priority'] as String,
      status: map['status'] as String,
      dueDate: DateTime.parse(map['due_date'] as String),
      tag: map['tag'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      totalSubtasks: (map['total_subtasks'] as num?)?.toInt() ?? 0,
      completedSubtasks: (map['completed_subtasks'] as num?)?.toInt() ?? 0,
    );
  }

  TaskModel copyWith({
    String? id,
    String? boardId,
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? dueDate,
    String? tag,
    DateTime? createdAt,
    int? totalSubtasks,
    int? completedSubtasks,
  }) {
    return TaskModel(
      id: id ?? this.id,
      boardId: boardId ?? this.boardId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
      totalSubtasks: totalSubtasks ?? this.totalSubtasks,
      completedSubtasks: completedSubtasks ?? this.completedSubtasks,
    );
  }
}