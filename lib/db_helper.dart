import 'package:mafraq_cpf_project_v1/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  late Database _database;

  Future<void> openDataBaseFile() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');

    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE User (
            id INTEGER PRIMARY KEY, 
            name TEXT,
            email TEXT,
            password TEXT,
            steps INTEGER DEFAULT 0
          )
          ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE User ADD COLUMN steps INTEGER DEFAULT 0',
          );
        }
      },
    );
  }

  Future<User> login({required String email, required String password}) async {
    await openDataBaseFile();
    List<Map> users = await _database.rawQuery(
      "SELECT * FROM User WHERE email = ? AND password = ?",
      [email, password],
    );
    await _database.close();

    if (users.isNotEmpty) {
      final u = users[0];
      return User(
        id: u['id'],
        name: u['name'],
        email: u['email'],
        password: u['password'],
        steps: u['steps'],
      );
    } else {
      throw Exception('User not found');
    }
  }

  Future<int> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    await openDataBaseFile();
    int id = await _database.rawInsert(
      "INSERT INTO User (name, email, password, steps) VALUES (?, ?, ?, 0)",
      [name, email, password],
    );
    await _database.close();
    return id;
  }

  Future<void> updateSteps(int userId, int steps) async {
    await openDataBaseFile();
    await _database.update(
      'User',
      {'steps': steps},
      where: 'id = ?',
      whereArgs: [userId],
    );
    await _database.close();
  }

  Future<int> getSteps(int userId) async {
    await openDataBaseFile();
    List<Map> result = await _database.query(
      'User',
      columns: ['steps'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    await _database.close();
    return result.isNotEmpty ? result[0]['steps'] : 0;
  }
}
