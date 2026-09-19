import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../modelos/usuario.dart';

/// Servicio de persistencia de usuarios en SQLite.
/// Maneja el alta, la búsqueda y la actualización de usuarios registrados.
class UsuarioServicio {
  static const _nombreDB = 'ecoruta.db';
  static const _version = 1; // se reinicia la versión: DB nueva al reinstalar

  /// Abre (o crea) la base de datos con las tablas necesarias.
  Future<Database> _abrirDB() async {
    return openDatabase(
      join(await getDatabasesPath(), _nombreDB),
      version: _version,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE usuarios('
          'id TEXT PRIMARY KEY, '
          'nombreApellido TEXT NOT NULL, '
          'usuario TEXT NOT NULL UNIQUE, '
          'dni TEXT NOT NULL, '
          'email TEXT NOT NULL, '
          'contrasena TEXT NOT NULL, '
          'pais TEXT NOT NULL, '
          'ciudad TEXT NOT NULL, '
          'departamento TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE lugares_frecuentes('
          'id TEXT PRIMARY KEY, '
          'nombre TEXT NOT NULL, '
          'direccion TEXT NOT NULL, '
          'latitud REAL NOT NULL, '
          'longitud REAL NOT NULL, '
          'icono TEXT NOT NULL, '
          'orden INTEGER NOT NULL)',
        );
      },
    );
  }

  /// Guarda un usuario nuevo o actualiza uno existente.
  Future<void> guardar(Usuario usuario) async {
    final db = await _abrirDB();
    await db.insert(
      'usuarios',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Busca un usuario por nombre de usuario (para login).
  Future<Usuario?> obtenerPorUsuario(String usuario) async {
    final db = await _abrirDB();
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
    final db = await _abrirDB();
    final res = await db.query(
      'usuarios',
      where: 'usuario = ?',
      whereArgs: [usuario],
      limit: 1,
    );
    return res.isNotEmpty;
  }
}