import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/conversion_guardada.dart';

class HistorialProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  List<ConversionGuardada> _conversiones = [];
  String _busqueda = '';
  bool _cargando = false;

  List<ConversionGuardada> get conversiones => _conversiones;
  String get busqueda => _busqueda;
  bool get cargando => _cargando;

  Future<void> cargarHistorial() async {
    _cargando = true;
    notifyListeners();

    _conversiones = await _db.getConversiones(busqueda: _busqueda);

    _cargando = false;
    notifyListeners();
  }

  void buscar(String query) {
    _busqueda = query;
    cargarHistorial();
  }

  Future<void> eliminar(int id) async {
    await _db.deleteConversion(id);
    await cargarHistorial();
  }

  Future<void> eliminarTodo() async {
    await _db.deleteAllConversiones();
    await cargarHistorial();
  }

  List<ConversionGuardada> filtrarHoy() {
    final hoy = DateTime.now();
    return _conversiones.where((c) {
      final fecha = DateTime.tryParse(c.fecha);
      if (fecha == null) return false;
      return fecha.year == hoy.year &&
          fecha.month == hoy.month &&
          fecha.day == hoy.day;
    }).toList();
  }

  List<ConversionGuardada> filtrarSemana() {
    final ahora = DateTime.now();
    final inicioSemana = ahora.subtract(Duration(days: 7));
    return _conversiones.where((c) {
      final fecha = DateTime.tryParse(c.fecha);
      if (fecha == null) return false;
      return fecha.isAfter(inicioSemana);
    }).toList();
  }
}
