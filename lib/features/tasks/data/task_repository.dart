import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import 'subtask_model.dart';
import 'task_model.dart';

class TaskRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Fetches all tasks for a specific board, including subtask counts and priority sorting
  Future<List<TaskModel>> getTasksByBoard(String boardId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        t.*,
        COUNT(s.id) AS total_subtasks,
        SUM(CASE WHEN s.is_completed = 1 THEN 1 ELSE 0 END) AS completed_subtasks
      FROM ${DatabaseHelper.tableTasks} t
      LEFT JOIN ${DatabaseHelper.tableSubtasks} s ON t.id = s.task_id
      WHERE t.board_id = ?
      GROUP BY t.id
      ORDER BY 
        CASE t.priority
          WHEN 'urgent' THEN 1
          WHEN 'high' THEN 2
          WHEN 'medium' THEN 3
          WHEN 'low' THEN 4
          ELSE 5
        END ASC,
        t.due_date ASC
    ''', [boardId]);

    return result.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<void> createTask(TaskModel task) async {
    final db = await _dbHelper.database;
    await db.insert(
      DatabaseHelper.tableTasks,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.tableTasks,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.tableTasks,
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> deleteTask(String taskId) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableTasks,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // ================= SUBTASKS CRUD =================

  Future<List<SubtaskModel>> getSubtasksByTask(String taskId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DatabaseHelper.tableSubtasks,
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
    return result.map((map) => SubtaskModel.fromMap(map)).toList();
  }

  Future<void> createSubtask(SubtaskModel subtask) async {
    final db = await _dbHelper.database;
    await db.insert(
      DatabaseHelper.tableSubtasks,
      subtask.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> toggleSubtask(String subtaskId, bool isCompleted) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.tableSubtasks,
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [subtaskId],
    );
  }

  Future<void> deleteSubtask(String subtaskId) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableSubtasks,
      where: 'id = ?',
      whereArgs: [subtaskId],
    );
  }
}