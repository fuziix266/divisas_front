import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'theme/app_theme.dart';
import 'providers/conversion_provider.dart';
import 'providers/historial_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/ingreso_sol_screen.dart';
import 'screens/conversor_screen.dart';

// Instancia global de Analytics
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const DivisasApp());
}

class DivisasApp extends StatelessWidget {
  const DivisasApp({super.key});

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
        navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
        routes: {
          '/': (context) => const SplashScreen(),
          '/ingreso': (context) => const IngresoSolScreen(),
          '/conversor': (context) => const ConversorScreen(),
        },
      ),
    );
  }
}
