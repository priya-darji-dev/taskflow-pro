class SubtaskModel {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;

  const SubtaskModel({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory SubtaskModel.fromMap(Map<String, dynamic> map) {
    return SubtaskModel(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      title: map['title'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }

  SubtaskModel copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}