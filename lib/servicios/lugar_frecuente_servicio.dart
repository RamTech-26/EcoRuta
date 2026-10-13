import 'package:ecoruta_2026/servicios/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../modelos/lugar_frecuente.dart';

class LugarFrecuenteServicio {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  

  Future<void> guardar(LugarFrecuente lugar) async {
    final db = await _dbHelper.database;
    await db.insert(
      'lugares_frecuentes',
      lugar.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LugarFrecuente>> obtenerTodos() async {
  final db = await _dbHelper.database;
  final res = await db.query('lugares_frecuentes', orderBy: 'orden ASC');
  return res.map((e) => LugarFrecuente.fromMap(e)).toList();
}

  Future<void> eliminar(String id) async {
    final db = await _dbHelper.database;
    await db.delete('lugares_frecuentes', where: 'id =?', whereArgs: [id]);
  }

  Future<void> actualizarOrden(List<LugarFrecuente> lugares) async {
    final db = await _dbHelper.database;
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
