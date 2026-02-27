import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/conversion_provider.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navegarDespuesDeSplash();
  }

  Future<void> _navegarDespuesDeSplash() async {
    // Esperar a que el provider cargue la tasa Y mínimo 2.5 segundos
    final provider = context.read<ConversionProvider>();
    await Future.wait([
      provider.cargarTasaActiva(),
      Future.delayed(const Duration(milliseconds: 2500)),
    ]);
    if (!mounted) return;

    final ruta = provider.tieneTasa ? '/conversor' : '/ingreso';
    Navigator.pushReplacementNamed(context, ruta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo cubriendo toda la pantalla
          CachedNetworkImage(
            imageUrl: 'https://www.conari.cl/retrobox/divisas/fondo.webp',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => const SizedBox.shrink(),
            errorWidget: (context, url, error) => const SizedBox.shrink(),
          ),

          // Loader superpuesto abajo con fondo transparente
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
