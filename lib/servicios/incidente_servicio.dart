import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../modelos/incidente.dart';

/// Servicio de persistencia de incidentes reportados.
/// Guarda, lista y elimina incidentes en SQLite.
class IncidenteServicio {
  static const _nombreDB = 'ecoruta.db';
  static const _version = 1;

  /// Abre la base de datos y asegura que la tabla exista.
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
        await db.execute(
          'CREATE TABLE incidentes('
          'id TEXT PRIMARY KEY, '
          'tipos TEXT NOT NULL, '
          'descripcion TEXT NOT NULL, '
          'calle TEXT NOT NULL, '
          'fecha TEXT NOT NULL, '
          'foto TEXT NOT NULL)',
        );
      },
    );
  }

  /// Guarda un incidente nuevo.
  Future<void> guardar(Incidente incidente) async {
    final db = await _abrirDB();
    await db.insert(
      'incidentes',
      incidente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Devuelve todos los incidentes, ordenados por fecha descendente (más nuevos primero).
  Future<List<Incidente>> obtenerTodos() async {
    final db = await _abrirDB();
    final res = await db.query('incidentes', orderBy: 'fecha DESC');
    return res.map((e) => Incidente.fromMap(e)).toList();
  }

  /// Elimina un incidente por su id.
  Future<void> eliminar(String id) async {
    final db = await _abrirDB();
    await db.delete('incidentes', where: 'id = ?', whereArgs: [id]);
  }
}