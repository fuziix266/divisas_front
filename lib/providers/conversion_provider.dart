import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/tasa_cambio.dart';
import '../models/conversion_guardada.dart';
import '../main.dart';

class ConversionProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  TasaCambio? _tasaActual;
  double _montoSoles = 0.0;
  double _montoPesos = 0.0;
  String _inputDisplay = '';
  bool _solAPeso = true; // true = SOL→CLP, false = CLP→SOL

  TasaCambio? get tasaActual => _tasaActual;
  double get montoSoles => _montoSoles;
  double get montoPesos => _montoPesos;
  String get inputDisplay => _inputDisplay;
  bool get tieneTasa => _tasaActual != null;
  bool get solAPeso => _solAPeso;

  /// Verifica si hay tasa activa Y es del mismo día
  bool get tieneTasaVigente {
    if (_tasaActual == null) return false;
    final fechaTasa = DateTime.tryParse(_tasaActual!.fechaRegistro);
    if (fechaTasa == null) return false;
    final hoy = DateTime.now();
    return fechaTasa.year == hoy.year &&
        fechaTasa.month == hoy.month &&
        fechaTasa.day == hoy.day;
  }

  Future<void> cargarTasaActiva() async {
    _tasaActual = await _db.getTasaActiva();
    notifyListeners();
  }

  Future<void> guardarTasa(double valorSol) async {
    final tasa = TasaCambio(
      valorSol: valorSol,
      fechaRegistro: DateTime.now().toIso8601String(),
      activa: true,
    );
    await _db.insertTasa(tasa);
    _tasaActual = tasa;
    notifyListeners();

    // Analytics: tipo de cambio actualizado
    analytics.logEvent(
      name: 'tipo_cambio_actualizado',
      parameters: {'valor_sol': valorSol},
    );
  }

  void toggleDireccion() {
    _solAPeso = !_solAPeso;
    // Limpiar input al cambiar dirección
    _inputDisplay = '';
    _montoSoles = 0.0;
    _montoPesos = 0.0;
    notifyListeners();
  }

  void actualizarMonto(String input) {
    _inputDisplay = input;
    if (input.isEmpty || input == '.') {
      _montoSoles = 0.0;
      _montoPesos = 0.0;
    } else {
      final valor = double.tryParse(input) ?? 0.0;
      if (_tasaActual != null) {
        if (_solAPeso) {
          // SOL → CLP: usuario ingresa soles
          _montoSoles = valor;
          _montoPesos = valor * _tasaActual!.valorSol;
        } else {
          // CLP → SOL: usuario ingresa pesos
          _montoPesos = valor;
          _montoSoles = valor / _tasaActual!.valorSol;
        }
      }
    }
    notifyListeners();
  }

  void limpiarInput() {
    _inputDisplay = '';
    _montoSoles = 0.0;
    _montoPesos = 0.0;
    notifyListeners();
  }

  void limpiar() {
    _inputDisplay = '';
    _montoSoles = 0.0;
    _montoPesos = 0.0;
    _solAPeso = true;
    notifyListeners();
  }

  Future<ConversionGuardada> guardarConversion(String? nota) async {
    final conversion = ConversionGuardada(
      montoSoles: _montoSoles,
      montoPesos: _montoPesos,
      tasaUsada: _tasaActual?.valorSol ?? 0.0,
      nota: nota,
      fecha: DateTime.now().toIso8601String(),
    );
    await _db.insertConversion(conversion);

    // Analytics: valor guardado
    analytics.logEvent(
      name: 'valor_guardado',
      parameters: {
        'valor_soles': _montoSoles,
        'valor_pesos': _montoPesos,
        'tipo': _solAPeso ? 'sol_a_peso' : 'peso_a_sol',
      },
    );

    return conversion;
  }
}
