import 'database_helper.dart';
import '../modelos/alarma.dart';
import 'package:sqflite/sqflite.dart';

class AlarmaServicio {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Alarma>> obtenerTodas() async {
    final db = await _dbHelper.database;
    // Mantiene el orden estricto guardado en BD
    final res = await db.query('alarmas', orderBy: 'orden ASC'); 
    return res.map((e) => Alarma.fromMap(e)).toList();
  }

  Future<void> guardar(Alarma alarma) async {
    final db = await _dbHelper.database;
    await db.insert('alarmas', alarma.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> eliminar(String id) async {
    final db = await _dbHelper.database;
    await db.delete('alarmas', where: 'id = ?', whereArgs: [id]);
  }

  // Persiste la nueva posición tras mantener presionado y arrastrar
  Future<void> actualizarOrden(List<Alarma> alarmas) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (var i = 0; i < alarmas.length; i++) {
      batch.update(
        'alarmas',
        {'orden': i},
        where: 'id = ?',
        whereArgs: [alarmas[i].id],
      );
    }
    await batch.commit();
  }
}