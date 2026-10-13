import 'package:ecoruta_2026/servicios/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../modelos/incidente.dart';

/// Servicio de persistencia de incidentes reportados.
/// Guarda, lista y elimina incidentes en SQLite.
class IncidenteServicio {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  /// Guarda un incidente nuevo.
  Future<void> guardar(Incidente incidente) async {
    final db = await _dbHelper.database;
    await db.insert(
      'incidentes',
      incidente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Devuelve todos los incidentes, ordenados por fecha descendente (más nuevos primero).
  Future<List<Incidente>> obtenerTodos() async {
    final db = await _dbHelper.database;
    final res = await db.query('incidentes', orderBy: 'fecha DESC');
    return res.map((e) => Incidente.fromMap(e)).toList();
  }

  /// Elimina un incidente por su id.
  Future<void> eliminar(String id) async {
    final db = await _dbHelper.database;
    await db.delete('incidentes', where: 'id = ?', whereArgs: [id]);
  }
}