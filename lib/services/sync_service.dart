import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../database/database_helper.dart';

class SyncService {
  static const String _baseUrl =
      'http://localhost:3000/api'; // Cambiar en producción
  final DatabaseHelper _db = DatabaseHelper();
  StreamSubscription? _connectivitySubscription;

  void iniciarMonitoreo() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      // Si hay alguna conexión disponible, sincronizar
      if (results.any((r) => r != ConnectivityResult.none)) {
        sincronizar();
      }
    });
  }

  void detenerMonitoreo() {
    _connectivitySubscription?.cancel();
  }

  Future<void> sincronizar() async {
    try {
      final pendientes = await _db.getConversionesPendientes();
      if (pendientes.isEmpty) return;

      final body = jsonEncode({
        'conversiones': pendientes.map((c) => c.toJson()).toList(),
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl/sync'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        for (final conversion in pendientes) {
          if (conversion.id != null) {
            await _db.marcarSincronizado(conversion.id!);
          }
        }
      }
    } catch (e) {
      // Sin conexión o error de red — no hacer nada, se reintentará
    }
  }
}
