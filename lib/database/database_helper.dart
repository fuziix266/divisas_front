import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tasa_cambio.dart';
import '../models/conversion_guardada.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'divisas.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasa_cambio (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        valor_sol REAL NOT NULL,
        fecha_registro TEXT NOT NULL,
        activa INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE conversiones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        monto_soles REAL NOT NULL,
        monto_pesos REAL NOT NULL,
        tasa_usada REAL NOT NULL,
        nota TEXT,
        fecha TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  // === TASA DE CAMBIO ===

  Future<int> insertTasa(TasaCambio tasa) async {
    final db = await database;
    // Desactivar todas las tasas anteriores
    await db.update('tasa_cambio', {'activa': 0});
    return await db.insert('tasa_cambio', tasa.toMap());
  }

  Future<TasaCambio?> getTasaActiva() async {
    final db = await database;
    final maps = await db.query(
      'tasa_cambio',
      where: 'activa = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TasaCambio.fromMap(maps.first);
  }

  // === CONVERSIONES ===

  Future<int> insertConversion(ConversionGuardada conversion) async {
    final db = await database;
    return await db.insert('conversiones', conversion.toMap());
  }

  Future<List<ConversionGuardada>> getConversiones({String? busqueda}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (busqueda != null && busqueda.isNotEmpty) {
      maps = await db.query(
        'conversiones',
        where: 'nota LIKE ?',
        whereArgs: ['%$busqueda%'],
        orderBy: 'fecha DESC',
      );
    } else {
      maps = await db.query('conversiones', orderBy: 'fecha DESC');
    }

    return maps.map((map) => ConversionGuardada.fromMap(map)).toList();
  }

  Future<List<ConversionGuardada>> getConversionesPendientes() async {
    final db = await database;
    final maps = await db.query(
      'conversiones',
      where: 'synced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => ConversionGuardada.fromMap(map)).toList();
  }

  Future<void> marcarSincronizado(int id) async {
    final db = await database;
    await db.update(
      'conversiones',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteConversion(int id) async {
    final db = await database;
    return await db.delete('conversiones', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllConversiones() async {
    final db = await database;
    return await db.delete('conversiones');
  }
}
