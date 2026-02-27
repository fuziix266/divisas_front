import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tasa_cambio.dart';
import '../models/conversion_guardada.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Almacenamiento en memoria para web
  static TasaCambio? _webTasaActiva;
  static final List<ConversionGuardada> _webConversiones = [];
  static int _webConversionId = 1;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('No usar database en web, usar métodos directos');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'divisas.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
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
        fecha TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migración v1 → v2: la columna synced ya no se usa pero no causa problemas
    // SQLite ignora columnas extra al leer, así que no necesitamos eliminarla
  }

  // === TASA DE CAMBIO ===

  Future<int> insertTasa(TasaCambio tasa) async {
    if (kIsWeb) {
      _webTasaActiva = tasa;
      return 1;
    }
    final db = await database;
    await db.update('tasa_cambio', {'activa': 0});
    return await db.insert('tasa_cambio', tasa.toMap());
  }

  Future<TasaCambio?> getTasaActiva() async {
    if (kIsWeb) {
      return _webTasaActiva;
    }
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
    if (kIsWeb) {
      final id = _webConversionId++;
      _webConversiones.insert(
        0,
        ConversionGuardada(
          id: id,
          montoSoles: conversion.montoSoles,
          montoPesos: conversion.montoPesos,
          tasaUsada: conversion.tasaUsada,
          nota: conversion.nota,
          fecha: conversion.fecha,
        ),
      );
      return id;
    }
    final db = await database;
    return await db.insert('conversiones', conversion.toMap());
  }

  Future<List<ConversionGuardada>> getConversiones({String? busqueda}) async {
    if (kIsWeb) {
      if (busqueda != null && busqueda.isNotEmpty) {
        return _webConversiones
            .where(
              (c) =>
                  c.nota?.toLowerCase().contains(busqueda.toLowerCase()) ??
                  false,
            )
            .toList();
      }
      return List.from(_webConversiones);
    }
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

  Future<int> deleteConversion(int id) async {
    if (kIsWeb) {
      _webConversiones.removeWhere((c) => c.id == id);
      return 1;
    }
    final db = await database;
    return await db.delete('conversiones', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllConversiones() async {
    if (kIsWeb) {
      final count = _webConversiones.length;
      _webConversiones.clear();
      return count;
    }
    final db = await database;
    return await db.delete('conversiones');
  }
}
