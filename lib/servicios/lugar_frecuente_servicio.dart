import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../modelos/lugar_frecuente.dart';

class LugarFrecuenteServicio {
  static const _nombreDB = 'ecoruta.db';
  static const _version = 3;

  Future<Database> _abrirDB() async {
    return openDatabase(
      join(await getDatabasesPath(), _nombreDB),
      version: _version,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS lugares_frecuentes(id TEXT PRIMARY KEY, nombre TEXT NOT NULL, direccion TEXT NOT NULL, latitud REAL NOT NULL, longitud REAL NOT NULL, icono TEXT NOT NULL, orden INTEGER NOT NULL)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS lugares_frecuentes(id TEXT PRIMARY KEY, nombre TEXT NOT NULL, direccion TEXT NOT NULL, latitud REAL NOT NULL, longitud REAL NOT NULL, icono TEXT NOT NULL, orden INTEGER NOT NULL)',
        );
      },
    );
  }

  Future<List<LugarFrecuente>> obtenerTodos() async {
    final db = await _abrirDB();
    final res = await db.query('lugares_frecuentes', orderBy: 'orden ASC');
    return res.map((e) => LugarFrecuente.fromMap(e)).toList();
  }

  Future<void> guardar(LugarFrecuente lugar) async {
    final db = await _abrirDB();
    await db.insert(
      'lugares_frecuentes',
      lugar.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> eliminar(String id) async {
    final db = await _abrirDB();
    await db.delete('lugares_frecuentes', where: 'id =?', whereArgs: [id]);
  }

  Future<void> actualizarOrden(List<LugarFrecuente> lugares) async {
    final db = await _abrirDB();
    final batch = db.batch();
    for (var i = 0; i < lugares.length; i++) {
      batch.update(
        'lugares_frecuentes',
        {'orden': i},
        where: 'id =?',
        whereArgs: [lugares[i].id],
      );
    }
    await batch.commit();
  }
}
