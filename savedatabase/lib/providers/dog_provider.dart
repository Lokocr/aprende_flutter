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

  // Inicializamos la base de datos.
  Future<void> initDatabase() async {
    openDatabase(
      join(await getDatabasesPath(), 'doggie_database.db'),
      onCreate: (db, version) {
        // Cuando la base de datos es creada por primera vez, crea una tabla para almacenar dogs.
        db.execute(
          "CREATE TABLE dogs(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER)",
        );
      },
      version: 1,
    );
  }

  // Obtenemos la instancia de base de datos.
  Future<Database> getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'doggie_database.db'),
      version: 1,
    );
  }

  Future<void> saveDog(Dog dog) async {
    try {
      var db = await getDatabase();

      // Validamos si el valor en la variables name es vacio
      if (name.isEmpty) {
        throw Exception('Name is empty');
      }

      // Validamos si el valor en la variables age es 0
      if (age == 0) {
        throw Exception('Age is empty');
      }

      // Agregamos los valores a una nueva instancia del modelo Dog
      newDog = Dog(name: name, age: age);

      // Insertamos el nuevo modelo en la base de datos
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

  // Reseteamos los valores de las variables
  Future<void> resetValues() async {
    name = '';
    age = 0;
    id = 0;
    notifyListeners();
  }

  // Obtenemos todos los registros de la base de datos
  Future<void> getDogs() async {
    final Database db = await getDatabase();

    // Obtenemos una lista de Map<String, dynamic> de la base de datos de la tabla de dogs
    final List<Map<String, dynamic>> maps = await db.query('dogs');

    // Convertimos la List<Map<String, dynamic> en una List<Dog>.
    dogs = List.generate(maps.length, (i) {
      return Dog(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });

    notifyListeners();
  }

  // Eliminamos un registro de la base de datos
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

  // Validmaos si la tabla existe
  Future<bool> isTableExist(String tableName) async {
    var db = await getDatabase();
    var res = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");
    return res.isNotEmpty;
  }
}
