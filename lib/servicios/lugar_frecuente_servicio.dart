import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modelos/lugar_frecuente.dart';

class LugarFrecuenteServicio {
  static Database? _db;

  Future<Database> get database async {
    if (_db!= null) return _db!;
    final path = join(await getDatabasesPath(), 'ecoruta.db');
    _db = await openDatabase(
      path,
      version: 3, // IMPORTANTE: 3 para que haga la migración
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS lugares_frecuentes(
            id TEXT PRIMARY KEY,
            nombre TEXT,
            direccion TEXT,
            latitud REAL,
            longitud REAL,
            icono TEXT,
            orden INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS usuarios(
            id TEXT PRIMARY KEY,
            nombre TEXT,
            contrasena TEXT,
            orden INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Si venís de la versión 1 (solo lugares), crea usuarios
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS usuarios(
              id TEXT PRIMARY KEY,
              nombre TEXT,
              contrasena TEXT,
              orden INTEGER
            )
          ''');
        }
        // Si venís de la versión 2, agrega la columna orden
        if (oldVersion < 3) {
          try {
            await db.execute('ALTER TABLE lugares_frecuentes ADD COLUMN orden INTEGER DEFAULT 0');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE usuarios ADD COLUMN orden INTEGER DEFAULT 0');
          } catch (_) {}
        }
      },
    );
    return _db!;
  }

  Future<List<LugarFrecuente>> obtenerTodos() async {
    final db = await database;
    final maps = await db.query('lugares_frecuentes', orderBy: 'orden ASC');
    return maps.map((m) => LugarFrecuente.fromMap(m)).toList();
  }

  Future<void> guardar(LugarFrecuente lugar) async {
    final db = await database;
    final result = await db.rawQuery('SELECT MAX(orden) as m FROM lugares_frecuentes');
    final maxOrden = (result.first['m'] as int?)?? -1;
    final nuevo = lugar.copyWith(orden: maxOrden + 1);
    await db.insert(
      'lugares_frecuentes',
      nuevo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> eliminar(String id) async {
    final db = await database;
    await db.delete('lugares_frecuentes', where: 'id =?', whereArgs: [id]);
  }

  Future<void> actualizarOrden(String id, int orden) async {
    final db = await database;
    await db.update(
      'lugares_frecuentes',
      {'orden': orden},
      where: 'id =?',
      whereArgs: [id],
    );
  }

  Future<void> actualizarOrdenBatch(List<LugarFrecuente> lugares) async {
    final db = await database;
    final batch = db.batch();
    for (int i = 0; i < lugares.length; i++) {
      batch.update(
        'lugares_frecuentes',
        {'orden': i},
        where: 'id =?',
        whereArgs: [lugares[i].id],
      );
    }
    await batch.commit(noResult: true);
  }
}