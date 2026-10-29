import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import 'board_model.dart';

class BoardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Fetches all boards along with total and completed task counts in a single SQL query
  Future<List<BoardModel>> getAllBoards() async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        b.*,
        COUNT(t.id) AS total_tasks,
        SUM(CASE WHEN t.status = 'done' THEN 1 ELSE 0 END) AS completed_tasks
      FROM ${DatabaseHelper.tableBoards} b
      LEFT JOIN ${DatabaseHelper.tableTasks} t ON b.id = t.board_id
      GROUP BY b.id
      ORDER BY b.created_at DESC
    ''');

    return result.map((map) => BoardModel.fromMap(map)).toList();
  }

  /// Inserts a new board (replaces on conflict)
  Future<void> createBoard(BoardModel board) async {
    final db = await _dbHelper.database;
    await db.insert(
      DatabaseHelper.tableBoards,
      board.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing board's details
  Future<void> updateBoard(BoardModel board) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.tableBoards,
      board.toMap(),
      where: 'id = ?',
      whereArgs: [board.id],
    );
  }

  /// Deletes a board. Foreign Key ON DELETE CASCADE automatically deletes its tasks & subtasks!
  Future<void> deleteBoard(String boardId) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableBoards,
      where: 'id = ?',
      whereArgs: [boardId],
    );
  }
}