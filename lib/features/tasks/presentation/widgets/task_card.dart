import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final ValueChanged<String> onStatusChange;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onStatusChange,
    required this.onDelete,
  });

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return AppColors.priorityUrgent;
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      default:
        return AppColors.priorityLow;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'done':
        return 'Completed';
      default:
        return 'To Do';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'in_progress':
        return AppColors.statusInProgress;
      case 'done':
        return AppColors.statusDone;
      default:
        return AppColors.statusTodo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);
    final statusColor = _getStatusColor(task.status);
    final isDone = task.status == 'done';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Priority Badge, Tag Pill & Quick Status Menu
              Row(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      task.priority.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: priorityColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${task.tag}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Quick Status Dropdown
                  PopupMenuButton<String>(
                    onSelected: onStatusChange,
                    tooltip: 'Change Status',
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'todo', child: Text('Move to To Do')),
                      PopupMenuItem(
                          value: 'in_progress',
                          child: Text('Move to In Progress')),
                      PopupMenuItem(
                          value: 'done', child: Text('Mark as Completed')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusLabel(task.status),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Task Title
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? secondaryColor : null,
                ),
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryColor,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Footer Row: Due Date, Subtasks Counter, Delete Icon
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 13,
                    color: task.isOverdue
                        ? AppColors.priorityUrgent
                        : secondaryColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat('MMM d, yyyy').format(task.dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                      task.isOverdue ? FontWeight.w700 : FontWeight.w500,
                      color: task.isOverdue
                          ? AppColors.priorityUrgent
                          : secondaryColor,
                    ),
                  ),
                  if (task.isOverdue) ...[
                    const SizedBox(width: 6),
                    const Text(
                      '(Overdue)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.priorityUrgent,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (task.totalSubtasks > 0) ...[
                    Icon(
                      Icons.check_box_outlined,
                      size: 15,
                      color: secondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.completedSubtasks}/${task.totalSubtasks}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}