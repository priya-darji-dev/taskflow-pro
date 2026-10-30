import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:taskflow_pro/features/boards/data/board_model.dart';
import 'package:taskflow_pro/features/tasks/data/subtask_model.dart';
import 'package:taskflow_pro/features/tasks/data/task_model.dart';

void main() {
  setUpAll(() {
    // Initialize FFI for headless in-memory SQLite testing in CI/CD
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('BoardModel & TaskModel Unit Tests', () {
    test('BoardModel computes completion progress accurately', () {
      final board = BoardModel(
        id: 'b-1',
        title: 'Sprint 15',
        description: 'Core architecture',
        colorHex: 0xFF6366F1,
        createdAt: DateTime(2026, 10, 1),
        totalTasks: 4,
        completedTasks: 3,
      );

      expect(board.progress, 0.75);
    });

    test('BoardModel returns 0.0 progress when totalTasks is zero', () {
      final emptyBoard = BoardModel(
        id: 'b-2',
        title: 'Backlog',
        description: 'Empty board',
        colorHex: 0xFF10B981,
        createdAt: DateTime(2026, 10, 1),
        totalTasks: 0,
        completedTasks: 0,
      );

      expect(emptyBoard.progress, 0.0);
    });

    test('TaskModel accurately flags overdue incomplete tasks', () {
      final overdueTask = TaskModel(
        id: 't-1',
        boardId: 'b-1',
        title: 'Fix SQLite migration',
        description: 'Urgent patch',
        status: 'in_progress',
        priority: 'urgent',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        tag: 'Bug',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      );

      final completedPastTask = overdueTask.copyWith(status: 'done');

      expect(overdueTask.isOverdue, isTrue);
      expect(completedPastTask.isOverdue, isFalse);
    });

    test('SubtaskModel serializes and deserializes SQLite integer booleans', () {
      final subtask = SubtaskModel(
        id: 's-1',
        taskId: 't-1',
        title: 'Write unit tests',
        isCompleted: true,
      );

      final map = subtask.toMap();
      expect(map['is_completed'], 1);

      final restored = SubtaskModel.fromMap(map);
      expect(restored.isCompleted, isTrue);
      expect(restored.title, 'Write unit tests');
    });
  });

  group('Relational SQLite Engine (In-Memory FFI)', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE boards (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                description TEXT NOT NULL,
                color_hex INTEGER NOT NULL,
                created_at TEXT NOT NULL
              )
            ''');
            await db.execute('''
              CREATE TABLE tasks (
                id TEXT PRIMARY KEY,
                board_id TEXT NOT NULL,
                title TEXT NOT NULL,
                description TEXT NOT NULL,
                status TEXT NOT NULL,
                priority TEXT NOT NULL,
                due_date TEXT NOT NULL,
                tag TEXT NOT NULL,
                created_at TEXT NOT NULL,
                FOREIGN KEY (board_id) REFERENCES boards (id) ON DELETE CASCADE
              )
            ''');
          },
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('Cascade delete removes associated tasks when parent board is deleted', () async {
      await db.insert('boards', {
        'id': 'board-100',
        'title': 'Architecture',
        'description': 'Clean Architecture',
        'color_hex': 0xFF6366F1,
        'created_at': DateTime.now().toIso8601String(),
      });

      await db.insert('tasks', {
        'id': 'task-200',
        'board_id': 'board-100',
        'title': 'Setup CI/CD',
        'description': 'GitHub Actions',
        'status': 'todo',
        'priority': 'high',
        'due_date': DateTime.now().toIso8601String(),
        'tag': 'DevOps',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Verify task exists
      var tasks = await db.query('tasks');
      expect(tasks.length, 1);

      // Delete parent board
      await db.delete('boards', where: 'id = ?', whereArgs: ['board-100']);

      // Verify foreign key cascade deleted the child task automatically
      tasks = await db.query('tasks');
      expect(tasks.isEmpty, isTrue);
    });
  });
}