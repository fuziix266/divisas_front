import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/conversion_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/numeric_keypad.dart';

class IngresoSolScreen extends StatefulWidget {
  const IngresoSolScreen({super.key});

  @override
  State<IngresoSolScreen> createState() => _IngresoSolScreenState();
}

class _IngresoSolScreenState extends State<IngresoSolScreen> {
  String _input = '';

  void _onKeyPressed(String key) {
    setState(() {
      // No permitir más de un punto decimal
      if (key == '.' && _input.contains('.')) return;
      // Limitar decimales a 2
      if (_input.contains('.')) {
        final decimales = _input.split('.')[1];
        if (decimales.length >= 2) return;
      }
      _input += key;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_input.isNotEmpty) {
        _input = _input.substring(0, _input.length - 1);
      }
    });
  }

  String get _displayValue {
    if (_input.isEmpty) return '0';
    return _input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header con paso
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const SizedBox(width: 40), // Spacer
                  Expanded(
                    child: Center(
                      child: Text(
                        'PASO 1 DE 2',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Barra de progreso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.5,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Título y descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Ingresa el valor del Sol',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¿A cuántos pesos chilenos compraste el sol?\nEj: Si pagaste 260 pesos por 1 sol, ingresa 260.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Valor grande
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$',
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _displayValue,
                            style: GoogleFonts.inter(
                              fontSize: 56,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Badge CLP/SOL
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🇨🇱', style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              'CLP por 1 SOL',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text('🇵🇪', style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botón confirmar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _input.isNotEmpty
                      ? () async {
                          final valor = double.tryParse(_input);
                          if (valor != null && valor > 0) {
                            final provider = context.read<ConversionProvider>();
                            await provider.guardarTasa(valor);
                            provider.limpiar();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                context,
                                '/conversor',
                              );
                            }
                          }
                        }
                      : null,
                  child: const Text('Comenzar a Convertir'),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PUEDES CAMBIAR ESTE VALOR DESPUÉS',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Teclado numérico
            NumericKeypad(
              onKeyPressed: _onKeyPressed,
              onBackspace: _onBackspace,
            ),
          ],
        ),
      ),
    );
  }
}
