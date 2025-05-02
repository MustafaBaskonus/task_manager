import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/category.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    final path = join(await getDatabasesPath(), 'task_manager.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // Tabloların oluşturulması
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            icon TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            title TEXT,
            category_id INTEGER,
            FOREIGN KEY (category_id) REFERENCES categories(id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Eski tablonun silinmesi
          await db.execute('DROP TABLE IF EXISTS tasks');
          await db.execute('DROP TABLE IF EXISTS categories');

          // Yeni tablonun oluşturulması
          await db.execute('''
            CREATE TABLE categories(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              icon TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE tasks(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT,
              title TEXT,
              category_id INTEGER,
              FOREIGN KEY (category_id) REFERENCES categories(id)
            )
          ''');
        }
      },
    );
  }

  // Kategorileri çekme
  Future<List<Category>> fetchCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  // Görevleri veritabanından çekme
  Future<List<Task>> fetchTasks() async {
    final db = await database; // Veritabanına bağlanıyoruz
    final List<Map<String, dynamic>> maps =
        await db.query('tasks'); // 'tasks' tablosundaki tüm verileri alıyoruz

    // List.generate ile her bir map öğesini Task nesnesine dönüştürüp liste oluşturuyoruz
    return List.generate(maps.length, (i) {
      return Task.fromMap(
          maps[i]); // Her bir map öğesini Task nesnesine çeviriyoruz
    });
  }

  // Kategorilere ait görevleri çekme
  Future<List<Task>> fetchTasksByCategoryId(int categoryId) async {
    final db = await instance.database;
    var res = await db.query(
      'tasks',
      where: 'category_id = ?', // Kategori ID'sine göre filtreleme
      whereArgs: [categoryId],
    );
    List<Task> tasks =
        res.isNotEmpty ? res.map((task) => Task.fromMap(task)).toList() : [];
    return tasks;
  }

  // Kategori ekleme
  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Görev ekleme
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Görev silme
  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
