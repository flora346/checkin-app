import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';
import '../models/check_record.dart';

class DbService {
  static final DbService instance = DbService._internal();
  DbService._internal();
  Database? _db;

  Future<void> initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, "checkdb.db");
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''CREATE TABLE tasks(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          enableRemind INTEGER,
          remindTime TEXT
        )''');
        await db.execute('''CREATE TABLE records(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          taskId INTEGER,
          date TEXT,
          status TEXT,
          note TEXT
        )''');
        // 初始化默认任务
        await db.insert("tasks", Task(name: "画画").toMap());
        await db.insert("tasks", Task(name: "运动").toMap());
        await db.insert("tasks", Task(name: "吉他").toMap());
      },
    );
  }

  Future<List<Task>> getTaskList() async {
    final res = await _db!.query("tasks");
    return res.map((e) => Task.fromMap(e)).toList();
  }

  Future addTask(Task t) => _db!.insert("tasks", t.toMap());
  Future deleteTask(int id) => _db!.delete("tasks", where: "id=?", whereArgs: [id]);
  Future updateTask(Task t) => _db!.update("tasks", t.toMap(), where: "id=?", whereArgs: [t.id]);

  Future addRecord(CheckRecord r) => _db!.insert("records", r.toMap());
  Future updateRecord(CheckRecord r) => _db!.update("records", r.toMap(), where: "id=?", whereArgs: [r.id]);
  Future<List<CheckRecord>> getRecordByDate(String date) async {
    final res = await _db!.query("records", where: "date=?", whereArgs: [date]);
    return res.map((e) => CheckRecord.fromMap(e)).toList();
  }

  Future<List<CheckRecord>> getAllRecords() async {
    final res = await _db!.query("records");
    return res.map((e) => CheckRecord.fromMap(e)).toList();
  }
}
