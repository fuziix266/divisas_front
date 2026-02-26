import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/conversion_provider.dart';
import 'providers/historial_provider.dart';
import 'screens/ingreso_sol_screen.dart';
import 'screens/conversor_screen.dart';
import 'services/sync_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DivisasApp());
}

class DivisasApp extends StatefulWidget {
  const DivisasApp({super.key});

  @override
  State<DivisasApp> createState() => _DivisasAppState();
}

class _DivisasAppState extends State<DivisasApp> {
  final SyncService _syncService = SyncService();

  @override
  void initState() {
    super.initState();
    _syncService.iniciarMonitoreo();
  }

  @override
  void dispose() {
    _syncService.detenerMonitoreo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ConversionProvider()..cargarTasaActiva(),
        ),
        ChangeNotifierProvider(create: (_) => HistorialProvider()),
      ],
      child: MaterialApp(
        title: 'Divisas - Sol a Peso',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const _InitialRoute(),
          '/ingreso': (context) => const IngresoSolScreen(),
          '/conversor': (context) => const ConversorScreen(),
        },
      ),
    );
  }
}

/// Ruta inicial que decide si ir al ingreso de tasa o directo al conversor
class _InitialRoute extends StatelessWidget {
  const _InitialRoute();

  @override
  Widget build(BuildContext context) {
    return Consumer<ConversionProvider>(
      builder: (context, provider, child) {
        // Si ya tiene tasa, ir al conversor directamente
        if (provider.tieneTasa) {
          return const ConversorScreen();
        }
        // Si no, ir al ingreso del valor del sol
        return const IngresoSolScreen();
      },
    );
  }
}
