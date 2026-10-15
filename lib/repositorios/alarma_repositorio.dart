import 'package:sqflite/sqflite.dart';

import '../modelos/alarma.dart';
import '../servicios/database_helper.dart';

abstract class AlarmaRepositorio {
  Future<List<Alarma>> obtenerTodas();
  Future<List<Alarma>> obtenerPorLugar(String lugarId);
  Future<void> guardar(Alarma alarma);
  Future<void> eliminar(String id);
  Future<void> actualizarOrden(List<Alarma> alarmas);
}

class AlarmaRepositorioImpl implements AlarmaRepositorio {
  final DatabaseHelper _dbHelper;

  AlarmaRepositorioImpl(this._dbHelper);

  @override
  Future<List<Alarma>> obtenerTodas() async {
    final db = await _dbHelper.database;
    final res = await db.query('alarmas', orderBy: 'orden ASC');
    return res.map((e) => Alarma.fromMap(e)).toList();
  }

  @override
  Future<List<Alarma>> obtenerPorLugar(String lugarId) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'alarmas',
      where: 'lugarId =?',
      whereArgs: [lugarId],
    );
    return res.map((e) => Alarma.fromMap(e)).toList();
  }

  @override
  Future<void> guardar(Alarma alarma) async {
    final db = await _dbHelper.database;
    await db.insert(
      'alarmas',
      alarma.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> eliminar(String id) async {
    final db = await _dbHelper.database;
    await db.delete('alarmas', where: 'id =?', whereArgs: [id]);
  }

  @override
  Future<void> actualizarOrden(List<Alarma> alarmas) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (var i = 0; i < alarmas.length; i++) {
      batch.update(
        'alarmas',
        {'orden': i},
        where: 'id =?',
        whereArgs: [alarmas[i].id],
      );
    }
    await batch.commit();
  }
}
