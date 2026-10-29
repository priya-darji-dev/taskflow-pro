import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/task_model.dart';
import '../controllers/task_controller.dart';

class TaskDetailSheet extends StatefulWidget {
  final TaskModel task;

  const TaskDetailSheet({super.key, required this.task});

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  final _subtaskController = TextEditingController();
  late final TaskController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<TaskController>();
    _controller.loadSubtasks(widget.task.id);
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    if (_subtaskController.text.trim().isNotEmpty) {
      _controller.addSubtask(widget.task.id, _subtaskController.text);
      _subtaskController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.task.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          if (widget.task.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.task.description,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            'Subtasks & Action Checklist',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          // Add Subtask Input Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtaskController,
                  onSubmitted: (_) => _addSubtask(),
                  decoration: const InputDecoration(
                    hintText: 'Add a checklist item...',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _addSubtask,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Subtasks Reactive List
          Flexible(
            child: Obx(() {
              final subtasks = _controller.activeSubtasks;
              if (subtasks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No subtasks yet. Break this task into smaller steps above!',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                itemCount: subtasks.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = subtasks[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Checkbox(
                      value: item.isCompleted,
                      activeColor: AppColors.primary,
                      onChanged: (_) => _controller.toggleSubtask(item),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => _controller.deleteSubtask(item),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}