import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../boards/data/board_model.dart';
import '../controllers/task_controller.dart';
import '../widgets/create_task_sheet.dart';
import '../widgets/task_card.dart';
import '../widgets/task_detail_sheet.dart';

class BoardDetailScreen extends StatefulWidget {
  final BoardModel board;

  const BoardDetailScreen({super.key, required this.board});

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  late final TaskController _taskController;

  @override
  void initState() {
    super.initState();
    _taskController = Get.find<TaskController>();
    _taskController.initializeBoard(widget.board.id);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(widget.board.colorHex);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.board.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: accentColor),
        ),
      ),
      body: Column(
        children: [
          // 1. Search Bar (Debounced by 250ms in TaskController)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              onChanged: _taskController.updateSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search tasks by title, description, or #tag...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),

          // 2. Kanban Status Filter Tabs
          Obx(
                () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatusTab(
                    label: 'All (${_taskController.allTasks.length})',
                    value: 'all',
                  ),
                  const SizedBox(width: 8),
                  _buildStatusTab(
                    label: 'To Do (${_taskController.todoCount})',
                    value: 'todo',
                  ),
                  const SizedBox(width: 8),
                  _buildStatusTab(
                    label: 'In Progress (${_taskController.inProgressCount})',
                    value: 'in_progress',
                  ),
                  const SizedBox(width: 8),
                  _buildStatusTab(
                    label: 'Done (${_taskController.doneCount})',
                    value: 'done',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 3. Priority Filter Pills
          Obx(
                () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Priority:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  for (final p in ['all', 'urgent', 'high', 'medium', 'low'])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        visualDensity: VisualDensity.compact,
                        label: Text(
                          p.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                        selected: _taskController.selectedPriority.value == p,
                        onSelected: (_) => _taskController.setPriorityFilter(p),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 4. Filtered Tasks List
          Expanded(
            child: Obx(() {
              if (_taskController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = _taskController.filteredTasks;
              if (tasks.isEmpty) {
                return const Center(
                  child: Text(
                    'No matching tasks found.',
                    style: TextStyle(color: AppColors.darkTextSecondary),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskCard(
                    task: task,
                    onTap: () {
                      Get.bottomSheet(
                        TaskDetailSheet(task: task),
                        isScrollControlled: true,
                      );
                    },
                    onStatusChange: (newStatus) =>
                        _taskController.updateTaskStatus(task.id, newStatus),
                    onDelete: () => _taskController.deleteTask(task.id),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor,
        onPressed: () {
          Get.bottomSheet(
            const CreateTaskSheet(),
            isScrollControlled: true,
          );
        },
        icon: const Icon(Icons.add_task_rounded),
        label: const Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildStatusTab({required String label, required String value}) {
    final isSelected = _taskController.selectedStatus.value == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : null,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      onSelected: (_) => _taskController.setStatusFilter(value),
    );
  }
}