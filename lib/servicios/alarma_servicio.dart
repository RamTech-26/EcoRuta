import 'package:sqflite/sqflite.dart';
import '../modelos/alarma.dart';
import '../servicios/database_helper.dart';

class AlarmaServicio {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  

  Future<List<Alarma>> obtenerTodas() async {
    final db = await _dbHelper.database;
    final res = await db.query('alarmas');
    return res.map((e) => Alarma.fromMap(e)).toList();
  }

  Future<void> guardar(Alarma alarma) async {
    final db = await _dbHelper.database;
    await db.insert(
      'alarmas',
      alarma.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> eliminar(String id) async {
    final db = await _dbHelper.database;
    await db.delete('alarmas', where: 'id = ?', whereArgs: [id]);
  }
}
