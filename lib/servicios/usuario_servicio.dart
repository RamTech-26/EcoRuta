import 'package:ecoruta_2026/servicios/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../modelos/usuario.dart';

/// Servicio de persistencia de usuarios en SQLite.
/// Maneja el alta, la búsqueda y la actualización de usuarios registrados.
class UsuarioServicio {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  /// Guarda un usuario nuevo o actualiza uno existente.
  Future<void> guardar(Usuario usuario) async {
    final db = await _dbHelper.database;
    await db.insert(
      'usuarios',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Busca un usuario por nombre de usuario (para login).
  Future<Usuario?> obtenerPorUsuario(String usuario) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'usuarios',
      where: 'usuario = ?',
      whereArgs: [usuario],
    );
    if (res.isEmpty) return null;
    return Usuario.fromMap(res.first);
  }

  /// Verifica si ya existe un usuario con ese nombre.
  Future<bool> existeUsuario(String usuario) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'usuarios',
      where: 'usuario = ?',
      whereArgs: [usuario],
      limit: 1,
    );
    return res.isNotEmpty;
  }
}
