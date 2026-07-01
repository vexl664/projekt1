import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/place_note.dart';

class PlacesDatabase {
  PlacesDatabase._();

  static final PlacesDatabase instance = PlacesDatabase._();

  static const String _tableName = 'places';
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'moje_miejsca.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            image_path TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertPlace(PlaceNote place) async {
    final db = await database;
    return db.insert(_tableName, place.toMap());
  }

  Future<List<PlaceNote>> getPlaces() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'created_at DESC');

    return maps.map(PlaceNote.fromMap).toList();
  }

  Future<void> deletePlace(int id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
