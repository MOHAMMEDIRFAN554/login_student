import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'student.dart';

class DatabaseHelper {
  Database? _db;

  Future<Database?> get db async {
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE students(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
        );
        await db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, email TEXT, password TEXT)',
        );
      },
    );
  }

  Future<void> insertUser(String email, String password) async {
    final dbClient = await db;
    await dbClient!.insert('users', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final dbClient = await db;
    final result = await dbClient!.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<void> insertStudent(Student student) async {
    final dbClient = await db;
    await dbClient!.insert('students', student.toMap());
  }

  Future<void> deleteStudent(int id) async {
    final dbClient = await db;
    await dbClient!.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateStudent(Student student) async {
    final dbClient = await db;
    await dbClient!.update('students', student.toMap(),
        where: 'id = ?', whereArgs: [student.id]);
  }

  Future<List<Student>> getStudents() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient!.query('students');

    return List.generate(maps.length, (i) {
      return Student(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });
  }
}
