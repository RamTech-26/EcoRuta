import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Patrón Singleton para asegurar una única instancia en toda la app
  static final DatabaseHelper _instancia = DatabaseHelper._interno();
  factory DatabaseHelper() => _instancia;
  DatabaseHelper._interno();

  static Database? _database;
  static const _nombreDB = 'ecoruta.db';
  static const _version = 4;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _inicializarDB();
    return _database!;
  }

  Future<Database> _inicializarDB() async {
    final path = join(await getDatabasesPath(), _nombreDB);
    return openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        // AQUÍ SE CREAN TODAS LAS TABLAS DE LA APP DE UNA SOLA VEZ
        await db.execute(
          'CREATE TABLE IF NOT EXISTS usuarios(id TEXT PRIMARY KEY, nombreApellido TEXT NOT NULL, usuario TEXT NOT NULL UNIQUE, dni TEXT NOT NULL, email TEXT NOT NULL, contrasena TEXT NOT NULL, pais TEXT NOT NULL, ciudad TEXT NOT NULL, departamento TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS lugares_frecuentes(id TEXT PRIMARY KEY, nombre TEXT NOT NULL, direccion TEXT NOT NULL, latitud REAL NOT NULL, longitud REAL NOT NULL, icono TEXT NOT NULL, orden INTEGER NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS incidentes(id TEXT PRIMARY KEY, tipos TEXT NOT NULL, descripcion TEXT NOT NULL, calle TEXT NOT NULL, fecha TEXT NOT NULL, foto TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS alarmas(id TEXT PRIMARY KEY, lugarId TEXT NOT NULL, hora TEXT NOT NULL, activa INTEGER NOT NULL, FOREIGN KEY(lugarId) REFERENCES lugares_frecuentes(id) ON DELETE CASCADE)',
        );
      },
    );
  }
}