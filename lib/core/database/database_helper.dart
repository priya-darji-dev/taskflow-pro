import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Table Names
  static const String tableBoards = 'boards';
  static const String tableTasks = 'tasks';
  static const String tableSubtasks = 'subtasks';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('taskflow_pro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _createDB,
    );
  }

  // Crucial: Enable SQLite Foreign Key constraints for ON DELETE CASCADE
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Create Boards Table
    await db.execute('''
      CREATE TABLE $tableBoards (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        color_hex INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 2. Create Tasks Table (Foreign Key -> boards.id)
    await db.execute('''
      CREATE TABLE $tableTasks (
        id TEXT PRIMARY KEY,
        board_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        due_date TEXT NOT NULL,
        tag TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (board_id) REFERENCES $tableBoards (id) ON DELETE CASCADE
      )
    ''');

    // 3. Create Subtasks Table (Foreign Key -> tasks.id)
    await db.execute('''
      CREATE TABLE $tableSubtasks (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (task_id) REFERENCES $tableTasks (id) ON DELETE CASCADE
      )
    ''');

    // 4. Create Indexes for fast lookup performance
    await db.execute(
      'CREATE INDEX idx_tasks_board_id ON $tableTasks (board_id)',
    );
    await db.execute(
      'CREATE INDEX idx_subtasks_task_id ON $tableSubtasks (task_id)',
    );

    // 5. Seed initial demo data so the portfolio app looks rich on first launch
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1)).toIso8601String();
    final nextWeek = now.add(const Duration(days: 5)).toIso8601String();
    final yesterday = now.subtract(const Duration(days: 1)).toIso8601String();

    // Seed Boards
    await db.insert(tableBoards, {
      'id': 'board-1',
      'title': 'Mobile Architecture v2.0',
      'description': 'Clean Architecture refactoring, offline sync & performance tuning',
      'color_hex': 0xFF6366F1, // Indigo
      'created_at': now.toIso8601String(),
    });

    await db.insert(tableBoards, {
      'id': 'board-2',
      'title': 'Design System & UI Kit',
      'description': 'Component library, dark mode tokens, and micro-interactions',
      'color_hex': 0xFF10B981, // Emerald
      'created_at': now.toIso8601String(),
    });

    await db.insert(tableBoards, {
      'id': 'board-3',
      'title': 'Release & CI/CD Pipeline',
      'description': 'Automated testing, Play Store & App Store deployment checklists',
      'color_hex': 0xFFF59E0B, // Amber
      'created_at': now.toIso8601String(),
    });

    // Seed Tasks for Board 1
    await db.insert(tableTasks, {
      'id': 'task-101',
      'board_id': 'board-1',
      'title': 'Implement SQLite Relational Schema & Foreign Keys',
      'description': 'Configure PRAGMA foreign_keys = ON, create indexes, and write aggregate JOIN queries for boards and tasks.',
      'priority': 'urgent',
      'status': 'done',
      'due_date': yesterday,
      'tag': 'Database',
      'created_at': now.toIso8601String(),
    });

    await db.insert(tableTasks, {
      'id': 'task-102',
      'board_id': 'board-1',
      'title': 'Build Reactive GetX Controllers with Search Debouncing',
      'description': 'Implement real-time task filtering by status, priority, and search query without blocking UI frames.',
      'priority': 'high',
      'status': 'in_progress',
      'due_date': tomorrow,
      'tag': 'Architecture',
      'created_at': now.toIso8601String(),
    });

    await db.insert(tableTasks, {
      'id': 'task-103',
      'board_id': 'board-1',
      'title': 'Write Unit Tests for Offline Repository Layer',
      'description': 'Verify CRUD operations and cascade deletion behavior across boards and subtasks.',
      'priority': 'medium',
      'status': 'todo',
      'due_date': nextWeek,
      'tag': 'Testing',
      'created_at': now.toIso8601String(),
    });

    // Seed Tasks for Board 2
    await db.insert(tableTasks, {
      'id': 'task-201',
      'board_id': 'board-2',
      'title': 'Design Analytics Progress Header Card',
      'description': 'Create custom circular progress indicator displaying overall workspace completion rate.',
      'priority': 'high',
      'status': 'done',
      'due_date': tomorrow,
      'tag': 'UI/UX',
      'created_at': now.toIso8601String(),
    });

    // Seed Subtasks for Task 102
    await db.insert(tableSubtasks, {
      'id': 'sub-1',
      'task_id': 'task-102',
      'title': 'Create observable state variables (RxList)',
      'is_completed': 1,
    });
    await db.insert(tableSubtasks, {
      'id': 'sub-2',
      'task_id': 'task-102',
      'title': 'Add multi-criteria filter logic (Status + Priority + Query)',
      'is_completed': 1,
    });
    await db.insert(tableSubtasks, {
      'id': 'sub-3',
      'task_id': 'task-102',
      'title': 'Bind controller to Kanban board view',
      'is_completed': 0,
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}