import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/conversion_provider.dart';
import '../services/image_sync_service.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  File? _fondoLocal;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    // 1. Cargar imagen local existente (si hay) para mostrar inmediatamente
    final imagenLocal = await ImageSyncService.obtenerImagenAleatoria();
    if (mounted && imagenLocal != null) {
      setState(() => _fondoLocal = imagenLocal);
    }

    // 2. Sincronizar imágenes con el servidor (en segundo plano, silencioso)
    ImageSyncService.sincronizar();

    // 3. Esperar a que el provider cargue la tasa Y mínimo 2.5 segundos
    final provider = context.read<ConversionProvider>();
    await Future.wait([
      provider.cargarTasaActiva(),
      Future.delayed(const Duration(milliseconds: 2000)),
    ]);
    if (!mounted) return;

    // 4. Decidir ruta: si no hay tasa vigente (no existe o expiró), ir a ingreso
    final ruta = provider.tieneTasaVigente ? '/conversor' : '/ingreso';
    Navigator.pushReplacementNamed(context, ruta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo desde archivo local
          if (_fondoLocal != null)
            Image.file(
              _fondoLocal!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),

          // Loader superpuesto abajo
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cargando...',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
