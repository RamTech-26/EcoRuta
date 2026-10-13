import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Patrón Singleton para asegurar una única instancia en toda la app[cite: 8]
  static final DatabaseHelper _instancia = DatabaseHelper._interno();
  factory DatabaseHelper() => _instancia;
  DatabaseHelper._interno();

  static Database? _database;
  static const _nombreDB = 'ecoruta.db';
  static const _version = 5; // Incrementado para la migración de nuevas columnas[cite: 9]

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
        // USUARIOS
        await db.execute(
          'CREATE TABLE IF NOT EXISTS usuarios(id TEXT PRIMARY KEY, nombreApellido TEXT NOT NULL, usuario TEXT NOT NULL UNIQUE, dni TEXT NOT NULL, email TEXT NOT NULL, contrasena TEXT NOT NULL, pais TEXT NOT NULL, ciudad TEXT NOT NULL, departamento TEXT NOT NULL)',
        );
        // LUGARES FRECUENTES[cite: 8, 9]
        await db.execute(
          'CREATE TABLE IF NOT EXISTS lugares_frecuentes(id TEXT PRIMARY KEY, nombre TEXT NOT NULL, direccion TEXT NOT NULL, latitud REAL NOT NULL, longitud REAL NOT NULL, icono TEXT NOT NULL, orden INTEGER NOT NULL)',
        );
        // INCIDENTES[cite: 8, 9]
        await db.execute(
          'CREATE TABLE IF NOT EXISTS incidentes(id TEXT PRIMARY KEY, tipos TEXT NOT NULL, descripcion TEXT NOT NULL, calle TEXT NOT NULL, fecha TEXT NOT NULL, foto TEXT NOT NULL)',
        );
        // ALARMAS[cite: 8, 9]
        await db.execute(
          'CREATE TABLE IF NOT EXISTS alarmas(id TEXT PRIMARY KEY, lugarId TEXT NOT NULL, hora TEXT NOT NULL, dias TEXT NOT NULL DEFAULT "", activa INTEGER NOT NULL, orden INTEGER NOT NULL DEFAULT 0, loopAudio INTEGER NOT NULL DEFAULT 1, vibrar INTEGER NOT NULL DEFAULT 1, sonido TEXT NOT NULL DEFAULT "Marimba", volumenPersonalizado INTEGER NOT NULL DEFAULT 0, volumen REAL NOT NULL DEFAULT 0.8, FOREIGN KEY(lugarId) REFERENCES lugares_frecuentes(id) ON DELETE CASCADE)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          // Migración automática si la tabla ya existía[cite: 28]
          await db.execute('ALTER TABLE alarmas ADD COLUMN loopAudio INTEGER NOT NULL DEFAULT 1');
          await db.execute('ALTER TABLE alarmas ADD COLUMN vibrar INTEGER NOT NULL DEFAULT 1');
          await db.execute('ALTER TABLE alarmas ADD COLUMN sonido TEXT NOT NULL DEFAULT "Marimba"');
          await db.execute('ALTER TABLE alarmas ADD COLUMN volumenPersonalizado INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE alarmas ADD COLUMN volumen REAL NOT NULL DEFAULT 0.8');
        }
      },
    );
  }
}