import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:savedatabase/models/dog.dart';
import 'package:sqflite/sqflite.dart';

class DogProvider extends ChangeNotifier {
  late Database database;
  late Dog newDog = Dog(id: 0, name: '', age: 0);
  late List<Dog> dogs = [];

  String name = '';
  int age = 0;
  int id = 0;

  Future<void> initDatabase() async {
    openDatabase(
      join(await getDatabasesPath(), 'doggie_database.db'),
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE dogs(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER)",
        );
      },
      version: 1,
    );
  }

  // Getting a reference to the database
  Future<Database> getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'doggie_database.db'),
      version: 1,
    );
  }

  Future<void> saveDog(Dog dog) async {
    try {
      var db = await getDatabase();

      // validate if name is empty
      if (name.isEmpty) {
        throw Exception('Name is empty');
      }

      // validate if age is empty
      if (age == 0) {
        throw Exception('Age is empty');
      }

      // add name, age and id to newDog variable
      newDog = Dog(name: name, age: age);

      await db.insert(
        'dogs',
        newDog.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      resetValues();

      notifyListeners();
      getDogs();
    } catch (e) {
      print(e);
    }
  }

  // Reset all values
  Future<void> resetValues() async {
    name = '';
    age = 0;
    id = 0;
    notifyListeners();
  }

  // get all dogs
  Future<void> getDogs() async {
    final Database db = await getDatabase();

    // get all dogs from database
    final List<Map<String, dynamic>> maps = await db.query('dogs');

    dogs = List.generate(maps.length, (i) {
      return Dog(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });

    notifyListeners();
  }

  // Remove dog from database
  Future<void> removeDog(int id) async {
    try {
      final db = await getDatabase();

      await db.delete(
        'dogs',
        where: "id = ?",
        whereArgs: [id],
      );
    } catch (e) {
      print(e);
    }

    notifyListeners();
    getDogs();
  }

  // validate if exist table
  Future<bool> isTableExist(String tableName) async {
    var db = await getDatabase();
    var res = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");
    return res.isNotEmpty;
  }
}
