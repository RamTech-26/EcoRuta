import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Patrón Singleton para asegurar una única instancia en toda la app[cite: 8]
  static final DatabaseHelper _instancia = DatabaseHelper._interno();
  factory DatabaseHelper() => _instancia;
  DatabaseHelper._interno();

  static Database? _database;
  static const _nombreDB = 'ecoruta.db';
  static const _version = 7; // v7: usuarios sin contraseña

  /// Columnas de la tabla de usuarios. Se usan al crear la base y en la
  /// migración a v7, así las dos quedan siempre iguales.
  static const _columnasUsuarios =
      'id TEXT PRIMARY KEY, nombreApellido TEXT NOT NULL, '
      'usuario TEXT NOT NULL UNIQUE, dni TEXT NOT NULL, email TEXT NOT NULL, '
      'pais TEXT NOT NULL, ciudad TEXT NOT NULL, departamento TEXT NOT NULL';

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
      // Activa las claves foráneas en cada conexión (SQLite las trae apagadas).
      // Sin esto, el ON DELETE CASCADE de alarmas no hace nada.
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // USUARIOS
        await db.execute(
          'CREATE TABLE IF NOT EXISTS usuarios($_columnasUsuarios)',
        );
        // LUGARES FRECUENTES[cite: 8, 9]
        await db.execute(
          'CREATE TABLE IF NOT EXISTS lugares_frecuentes(id TEXT PRIMARY KEY, nombre TEXT NOT NULL, direccion TEXT NOT NULL, latitud REAL NOT NULL, longitud REAL NOT NULL, icono TEXT NOT NULL, orden INTEGER NOT NULL)',
        );
        // INCIDENTES[cite: 8, 9]
        await db.execute(
          'CREATE TABLE IF NOT EXISTS incidentes(id TEXT PRIMARY KEY, tipos TEXT NOT NULL, descripcion TEXT NOT NULL, calle TEXT NOT NULL, fecha TEXT NOT NULL, foto TEXT NOT NULL, latitud REAL, longitud REAL)',
        );
        // ALARMAS[cite: 8, 9]
        await db.execute(
          'CREATE TABLE IF NOT EXISTS alarmas(id TEXT PRIMARY KEY, lugarId TEXT NOT NULL, hora TEXT NOT NULL, dias TEXT NOT NULL DEFAULT "", activa INTEGER NOT NULL, orden INTEGER NOT NULL DEFAULT 0, loopAudio INTEGER NOT NULL DEFAULT 1, vibrar INTEGER NOT NULL DEFAULT 1, sonido TEXT NOT NULL DEFAULT "Marimba", volumenPersonalizado INTEGER NOT NULL DEFAULT 0, volumen REAL NOT NULL DEFAULT 0.8, FOREIGN KEY(lugarId) REFERENCES lugares_frecuentes(id) ON DELETE CASCADE)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          // Migración automática si la tabla ya existía[cite: 28]
          await db.execute(
            'ALTER TABLE alarmas ADD COLUMN loopAudio INTEGER NOT NULL DEFAULT 1',
          );
          await db.execute(
            'ALTER TABLE alarmas ADD COLUMN vibrar INTEGER NOT NULL DEFAULT 1',
          );
          await db.execute(
            'ALTER TABLE alarmas ADD COLUMN sonido TEXT NOT NULL DEFAULT "Marimba"',
          );
          await db.execute(
            'ALTER TABLE alarmas ADD COLUMN volumenPersonalizado INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE alarmas ADD COLUMN volumen REAL NOT NULL DEFAULT 0.8',
          );
        }
        if (oldVersion < 6) {
          // Ubicación GPS del incidente (puede quedar vacía)
          await db.execute('ALTER TABLE incidentes ADD COLUMN latitud REAL');
          await db.execute('ALTER TABLE incidentes ADD COLUMN longitud REAL');
        }
        if (oldVersion < 7) {
          // La contraseña la verifica Firebase: no tiene que quedar guardada
          // en el celular. SQLite en Android viejo no tiene DROP COLUMN, así
          // que se recrea la tabla sin esa columna y se copian los datos.
          await db.execute('CREATE TABLE usuarios_nueva($_columnasUsuarios)');
          await db.execute(
            'INSERT INTO usuarios_nueva '
            '(id, nombreApellido, usuario, dni, email, pais, ciudad, departamento) '
            'SELECT id, nombreApellido, usuario, dni, email, pais, ciudad, departamento '
            'FROM usuarios',
          );
          await db.execute('DROP TABLE usuarios');
          await db.execute('ALTER TABLE usuarios_nueva RENAME TO usuarios');
        }
      },
    );
  }
}
