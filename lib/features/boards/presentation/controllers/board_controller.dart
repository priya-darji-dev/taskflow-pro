import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../data/board_model.dart';
import '../../data/board_repository.dart';

class BoardController extends GetxController {
  final BoardRepository _repository = BoardRepository();
  final Uuid _uuid = const Uuid();

  // Reactive state variables
  final RxList<BoardModel> boards = <BoardModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBoards();
  }

  /// Fetches all boards with their SQL-calculated task counts
  Future<void> loadBoards() async {
    try {
      isLoading.value = true;
      final result = await _repository.getAllBoards();
      boards.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  /// Creates a new project board and refreshes the dashboard
  Future<void> createBoard({
    required String title,
    required String description,
    required int colorHex,
  }) async {
    final newBoard = BoardModel(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      colorHex: colorHex,
      createdAt: DateTime.now(),
    );

    await _repository.createBoard(newBoard);
    await loadBoards();
  }
  Future<void> updateBoard({
    required BoardModel board,
    required String title,
    required String description,
    required int colorHex,
  }) async {
    final updated = board.copyWith(
      title: title.trim(),
      description: description.trim().isEmpty
          ? 'No description provided'
          : description.trim(),
      colorHex: colorHex,
    );

    await _repository.updateBoard(updated);
    await loadBoards();
  }

  /// Deletes a board (SQLite automatically cascades & deletes child tasks/subtasks)
  Future<void> deleteBoard(String boardId) async {
    await _repository.deleteBoard(boardId);
    await loadBoards();
  }

  // ================= WORKSPACE ANALYTICS GETTERS =================

  /// Total tasks across all boards
  int get totalWorkspaceTasks =>
      boards.fold(0, (sum, board) => sum + board.totalTasks);

  /// Completed tasks across all boards
  int get completedWorkspaceTasks =>
      boards.fold(0, (sum, board) => sum + board.completedTasks);

  /// Overall completion ratio (0.0 to 1.0) for the circular analytics ring
  double get overallCompletionRate {
    final total = totalWorkspaceTasks;
    if (total == 0) return 0.0;
    return completedWorkspaceTasks / total;
  }
}