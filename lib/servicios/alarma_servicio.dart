import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modelos/alarma.dart';

class AlarmaServicio {
  static const _nombreDB = 'ecoruta.db';
  static const _version = 4; // Subimos versión por la nueva tabla

  Future<Database> _abrirDB() async {
    return openDatabase(
      join(await getDatabasesPath(), _nombreDB),
      version: _version,
      onCreate: (db, version) async {
        await _crearTablas(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _crearTablas(db);
      },
    );
  }

  Future<void> _crearTablas(Database db) async {
    // Aseguramos que la tabla de lugares exista también
    await db.execute(
      'CREATE TABLE IF NOT EXISTS lugares_frecuentes(id TEXT PRIMARY KEY, nombre TEXT NOT NULL, direccion TEXT NOT NULL, latitud REAL NOT NULL, longitud REAL NOT NULL, icono TEXT NOT NULL, orden INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS alarmas(id TEXT PRIMARY KEY, lugarId TEXT NOT NULL, hora TEXT NOT NULL, activa INTEGER NOT NULL, FOREIGN KEY(lugarId) REFERENCES lugares_frecuentes(id) ON DELETE CASCADE)',
    );
  }

  Future<List<Alarma>> obtenerTodas() async {
    final db = await _abrirDB();
    final res = await db.query('alarmas');
    return res.map((e) => Alarma.fromMap(e)).toList();
  }

  Future<void> guardar(Alarma alarma) async {
    final db = await _abrirDB();
    await db.insert('alarmas', alarma.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> eliminar(String id) async {
    final db = await _abrirDB();
    await db.delete('alarmas', where: 'id = ?', whereArgs: [id]);
  }
}