import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../boards/presentation/controllers/board_controller.dart';
import '../../data/subtask_model.dart';
import '../../data/task_model.dart';
import '../../data/task_repository.dart';

class TaskController extends GetxController {
  final TaskRepository _repository = TaskRepository();
  final Uuid _uuid = const Uuid();

  // Current active board ID
  late String currentBoardId;

  // Master list of all tasks for this board & filtered list bound to the UI
  final RxList<TaskModel> allTasks = <TaskModel>[].obs;
  final RxList<TaskModel> filteredTasks = <TaskModel>[].obs;

  // Subtasks for the currently opened Task Detail bottom sheet
  final RxList<SubtaskModel> activeSubtasks = <SubtaskModel>[].obs;

  // Reactive Filter States
  final RxString selectedStatus = 'all'.obs;   // 'all', 'todo', 'in_progress', 'done'
  final RxString selectedPriority = 'all'.obs; // 'all', 'low', 'medium', 'high', 'urgent'
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Debounce search input by 250ms for smooth 60fps UI performance
    debounce(
      searchQuery,
          (_) => _applyFilters(),
      time: const Duration(milliseconds: 250),
    );
  }

  /// Initializes the controller when entering a specific Board screen
  Future<void> initializeBoard(String boardId) async {
    currentBoardId = boardId;
    selectedStatus.value = 'all';
    selectedPriority.value = 'all';
    searchQuery.value = '';
    await loadTasks();
  }

  /// Fetches tasks from SQLite and applies active UI filters
  Future<void> loadTasks() async {
    try {
      isLoading.value = true;
      final result = await _repository.getTasksByBoard(currentBoardId);
      allTasks.assignAll(result);
      _applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  /// Applies Status, Priority, and Search Query filters simultaneously
  void _applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();

    final result = allTasks.where((task) {
      final matchesStatus = selectedStatus.value == 'all' ||
          task.status == selectedStatus.value;

      final matchesPriority = selectedPriority.value == 'all' ||
          task.priority == selectedPriority.value;

      final matchesSearch = query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          task.tag.toLowerCase().contains(query);

      return matchesStatus && matchesPriority && matchesSearch;
    }).toList();

    filteredTasks.assignAll(result);
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void setPriorityFilter(String priority) {
    selectedPriority.value = priority;
    _applyFilters();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // ================= TASK CRUD OPERATIONS =================

  Future<void> createTask({
    required String title,
    required String description,
    required String priority,
    required DateTime dueDate,
    required String tag,
  }) async {
    final newTask = TaskModel(
      id: _uuid.v4(),
      boardId: currentBoardId,
      title: title.trim(),
      description: description.trim(),
      priority: priority,
      status: 'todo',
      dueDate: dueDate,
      tag: tag.trim().isEmpty ? 'General' : tag.trim(),
      createdAt: DateTime.now(),
    );

    await _repository.createTask(newTask);
    await loadTasks();
    _syncBoardCounts();
  }

  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    await _repository.updateTaskStatus(taskId, newStatus);
    await loadTasks();
    _syncBoardCounts();
  }

  Future<void> deleteTask(String taskId) async {
    await _repository.deleteTask(taskId);
    await loadTasks();
    _syncBoardCounts();
  }

  // ================= SUBTASK CHECKLIST OPERATIONS =================

  Future<void> loadSubtasks(String taskId) async {
    final result = await _repository.getSubtasksByTask(taskId);
    activeSubtasks.assignAll(result);
  }

  Future<void> addSubtask(String taskId, String title) async {
    if (title.trim().isEmpty) return;
    final subtask = SubtaskModel(
      id: _uuid.v4(),
      taskId: taskId,
      title: title.trim(),
    );
    await _repository.createSubtask(subtask);
    await loadSubtasks(taskId);
    await loadTasks(); // Updates the ☑️ X/Y badge on the parent task card
  }

  Future<void> toggleSubtask(SubtaskModel subtask) async {
    await _repository.toggleSubtask(subtask.id, !subtask.isCompleted);
    await loadSubtasks(subtask.taskId);
    await loadTasks();
  }

  Future<void> deleteSubtask(SubtaskModel subtask) async {
    await _repository.deleteSubtask(subtask.id);
    await loadSubtasks(subtask.taskId);
    await loadTasks();
  }

  // ================= COUNTERS FOR KANBAN TABS =================

  int get todoCount => allTasks.where((t) => t.status == 'todo').length;
  int get inProgressCount => allTasks.where((t) => t.status == 'in_progress').length;
  int get doneCount => allTasks.where((t) => t.status == 'done').length;

  /// Keeps the parent BoardController dashboard progress bars in sync
  void _syncBoardCounts() {
    if (Get.isRegistered<BoardController>()) {
      Get.find<BoardController>().loadBoards();
    }
  }
}