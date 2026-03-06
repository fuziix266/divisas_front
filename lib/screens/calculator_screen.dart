import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/conversion_provider.dart';
import '../providers/historial_provider.dart';
import '../main.dart';
import 'conversor_screen.dart';
import 'package:url_launcher/url_launcher.dart';

String _formatPesos(double valor) {
  final formatter = NumberFormat('#,##0', 'en_US');
  return formatter.format(valor.round());
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  String _display = '0';
  String _expression = '';
  double _result = 0;
  String _operator = '';
  double _firstOperand = 0;
  bool _shouldResetDisplay = false;
  String _lastOperation = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistorialProvider>().cargarHistorial();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    setState(() {
      if (_shouldResetDisplay) {
        _display = digit;
        _shouldResetDisplay = false;
      } else {
        if (_display == '0' && digit != '.') {
          _display = digit;
        } else {
          if (digit == '.' && _display.contains('.')) return;
          _display += digit;
        }
      }
    });
    _animController.forward().then((_) => _animController.reverse());
  }

  void _onOperator(String op) {
    setState(() {
      if (_operator.isNotEmpty && !_shouldResetDisplay) {
        _calculate();
      }
      _firstOperand = double.tryParse(_display) ?? 0;
      _operator = op;
      _expression = '${_formatNumber(_firstOperand)} $op';
      _shouldResetDisplay = true;
    });
  }

  void _calculate() {
    if (_operator.isEmpty) return;
    double secondOperand = double.tryParse(_display) ?? 0;

    setState(() {
      _lastOperation =
          '${_formatNumber(_firstOperand)} $_operator ${_formatNumber(secondOperand)}';

      switch (_operator) {
        case '+':
          _result = _firstOperand + secondOperand;
          break;
        case '−':
          _result = _firstOperand - secondOperand;
          break;
        case '×':
          _result = _firstOperand * secondOperand;
          break;
        case '÷':
          if (secondOperand == 0) {
            _display = 'Error';
            _expression = '';
            _operator = '';
            _shouldResetDisplay = true;
            return;
          }
          _result = _firstOperand / secondOperand;
          break;
      }

      if (_result == _result.toInt().toDouble()) {
        _display = _result.toInt().toString();
      } else {
        _display = _result.toStringAsFixed(8);
        _display = _display.replaceAll(RegExp(r'0+$'), '');
        _display = _display.replaceAll(RegExp(r'\.$'), '');
      }

      _expression = _lastOperation;
      _operator = '';
      _shouldResetDisplay = true;
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _expression = '';
      _result = 0;
      _operator = '';
      _firstOperand = 0;
      _shouldResetDisplay = false;
      _lastOperation = '';
    });
  }

  void _backspace() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display != '0' && _display != 'Error') {
        if (_display.startsWith('-')) {
          _display = _display.substring(1);
        } else {
          _display = '-$_display';
        }
      }
    });
  }

  void _percentage() {
    setState(() {
      double value = double.tryParse(_display) ?? 0;
      value = value / 100;
      if (value == value.toInt().toDouble()) {
        _display = value.toInt().toString();
      } else {
        _display = value.toString();
      }
    });
  }

  String _formatNumber(double value) {
    if (value == value.toInt().toDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  // ── Drawer (mismo estilo del conversor) ──
  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'PE\$OL',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const Divider(height: 1),
            ExpansionTile(
              leading: const Text('🇨🇱', style: TextStyle(fontSize: 22)),
              title: Text(
                'Emergencias Chile',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              children: [
                _buildEmergencyButton(
                  'Carabineros',
                  '133',
                  const Color(0xFF4A6741),
                  Icons.shield,
                ),
                _buildEmergencyButton(
                  'Bomberos',
                  '132',
                  const Color(0xFFCE0E2D),
                  Icons.local_fire_department,
                ),
                _buildEmergencyButton(
                  'SAMU',
                  '131',
                  const Color(0xFFD4A017),
                  Icons.medical_services,
                ),
                _buildEmergencyButton(
                  'PDI',
                  '134',
                  const Color(0xFF1A3C6E),
                  Icons.policy,
                ),
              ],
            ),
            ExpansionTile(
              leading: const Text('🇵🇪', style: TextStyle(fontSize: 22)),
              title: Text(
                'Emergencias Perú',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              children: [
                _buildEmergencyButton(
                  'PNP (Policía)',
                  '105',
                  const Color(0xFF2E5E3F),
                  Icons.local_police,
                ),
                _buildEmergencyButton(
                  'Bomberos',
                  '116',
                  const Color(0xFFCC0000),
                  Icons.local_fire_department,
                ),
                _buildEmergencyButton(
                  'SAMU',
                  '106',
                  const Color(0xFFE65100),
                  Icons.medical_services,
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        '¿Quieres visitar nuestra página?',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      content: Text(
                        'Serás redirigido a www.retrobox.cl',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'No, gracias',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            textStyle: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            launchUrl(
                              Uri.parse('https://www.retrobox.cl'),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          child: const Text('Sí, visitarla'),
                        ),
                      ],
                    ),
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                          children: const [
                            TextSpan(
                              text:
                                  'Te invitamos a visitar nuestra página,\nhacemos cosas bonitas ',
                            ),
                            TextSpan(
                              text: '❤️',
                              style: TextStyle(fontFamily: ''),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'www.retrobox.cl',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(
    String nombre,
    String numero,
    Color color,
    IconData icono,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.pop(context);
            launchUrl(Uri.parse('tel:$numero'));
            analytics.logEvent(
              name: 'emergencia_consultada',
              parameters: {'institucion': nombre, 'numero': numero},
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icono, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nombre,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    numero,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundLight,
      endDrawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Header con menú hamburguesa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 48),
                  const Spacer(),
                  Text(
                    'Calculadora',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                ],
              ),
            ),

            // Display area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 22,
                    child: Text(
                      _expression.isNotEmpty ? _expression : ' ',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _display,
                        style: GoogleFonts.inter(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                          letterSpacing: -1,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Keypad compacto
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRow([
                    _CalcButton(
                      label: 'C',
                      type: _ButtonType.function,
                      onTap: _clear,
                    ),
                    _CalcButton(
                      label: '±',
                      type: _ButtonType.function,
                      onTap: _toggleSign,
                    ),
                    _CalcButton(
                      label: '%',
                      type: _ButtonType.function,
                      onTap: _percentage,
                    ),
                    _CalcButton(
                      label: '÷',
                      type: _ButtonType.operator,
                      isActive: _operator == '÷',
                      onTap: () => _onOperator('÷'),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _buildRow([
                    _CalcButton(label: '7', onTap: () => _onDigit('7')),
                    _CalcButton(label: '8', onTap: () => _onDigit('8')),
                    _CalcButton(label: '9', onTap: () => _onDigit('9')),
                    _CalcButton(
                      label: '×',
                      type: _ButtonType.operator,
                      isActive: _operator == '×',
                      onTap: () => _onOperator('×'),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _buildRow([
                    _CalcButton(label: '4', onTap: () => _onDigit('4')),
                    _CalcButton(label: '5', onTap: () => _onDigit('5')),
                    _CalcButton(label: '6', onTap: () => _onDigit('6')),
                    _CalcButton(
                      label: '−',
                      type: _ButtonType.operator,
                      isActive: _operator == '−',
                      onTap: () => _onOperator('−'),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _buildRow([
                    _CalcButton(label: '1', onTap: () => _onDigit('1')),
                    _CalcButton(label: '2', onTap: () => _onDigit('2')),
                    _CalcButton(label: '3', onTap: () => _onDigit('3')),
                    _CalcButton(
                      label: '+',
                      type: _ButtonType.operator,
                      isActive: _operator == '+',
                      onTap: () => _onOperator('+'),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _buildRow([
                    _CalcButton(
                      icon: Icons.backspace_outlined,
                      type: _ButtonType.function,
                      onTap: _backspace,
                    ),
                    _CalcButton(label: '0', onTap: () => _onDigit('0')),
                    _CalcButton(label: '.', onTap: () => _onDigit('.')),
                    _CalcButton(
                      label: '=',
                      type: _ButtonType.equals,
                      onTap: _calculate,
                    ),
                  ]),
                ],
              ),
            ),

            // Título Historial
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Historial',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const Spacer(),
                  Consumer<HistorialProvider>(
                    builder: (context, provider, _) => Text(
                      '${provider.conversiones.length} registro${provider.conversiones.length != 1 ? 's' : ''}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Historial siempre visible
            Expanded(
              child: Container(
                color: Colors.white,
                child: Consumer<HistorialProvider>(
                  builder: (context, provider, child) {
                    if (provider.cargando) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      );
                    }

                    final items = provider.conversiones;

                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history_edu,
                              size: 42,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sin conversiones guardadas',
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Guarda conversiones para verlas aquí',
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade300,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildHistorialMiniCard(item);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.grey.shade600,
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          if (index == 0) {
            // Cambiar valor del sol
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  '¿Cambiar valor del sol?',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
                content: Text(
                  'Podrás ingresar un nuevo valor de cambio para tu conversión.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<ConversionProvider>().limpiar();
                      Navigator.pushReplacementNamed(context, '/ingreso');
                    },
                    child: const Text('Sí, cambiar'),
                  ),
                ],
              ),
            );
          } else if (index == 1) {
            // Ir al conversor
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ConversorScreen()),
            );
          } else if (index == 2) {
            // Ir al conversor con tab historial
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ConversorScreen(initialTab: 1),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            label: 'Cambiar valor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
            label: 'Conversor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialMiniCard(dynamic conversion) {
    final fecha = DateTime.tryParse(conversion.fecha);
    final fechaStr = fecha != null
        ? '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.currency_exchange,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                        children: [
                          TextSpan(
                            text:
                                'S/ ${conversion.montoSoles.toStringAsFixed(2)}',
                          ),
                          TextSpan(
                            text: ' → ',
                            style: TextStyle(color: AppTheme.primaryColor),
                          ),
                          TextSpan(
                            text: '\$ ${_formatPesos(conversion.montoPesos)}',
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (conversion.nota != null &&
                            conversion.nota!.isNotEmpty) ...[
                          Expanded(
                            child: Text(
                              conversion.nota!,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          fechaStr,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<_CalcButton> buttons) {
    return Row(
      children: buttons.map((btn) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildButton(btn),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(_CalcButton btn) {
    Color bgColor;
    Color textColor;
    double fontSize;
    FontWeight fontWeight;

    switch (btn.type) {
      case _ButtonType.function:
        bgColor = Colors.grey.shade100;
        textColor = AppTheme.textDark;
        fontSize = 16;
        fontWeight = FontWeight.w600;
        break;
      case _ButtonType.operator:
        bgColor = btn.isActive
            ? AppTheme.primaryColor
            : AppTheme.primaryColor.withValues(alpha: 0.12);
        textColor = btn.isActive ? Colors.white : AppTheme.primaryColor;
        fontSize = 20;
        fontWeight = FontWeight.w700;
        break;
      case _ButtonType.equals:
        bgColor = AppTheme.primaryColor;
        textColor = Colors.white;
        fontSize = 22;
        fontWeight = FontWeight.w700;
        break;
      case _ButtonType.digit:
        bgColor = Colors.white;
        textColor = AppTheme.textDark;
        fontSize = 22;
        fontWeight = FontWeight.w600;
        break;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: btn.onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppTheme.primaryColor.withValues(alpha: 0.15),
        highlightColor: AppTheme.primaryColor.withValues(alpha: 0.08),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: btn.type == _ButtonType.digit
                ? Border.all(color: Colors.grey.shade200)
                : null,
            boxShadow: btn.type == _ButtonType.equals
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: btn.icon != null
              ? Icon(btn.icon, size: 20, color: textColor)
              : Text(
                  btn.label ?? '',
                  style: GoogleFonts.inter(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}

enum _ButtonType { digit, operator, function, equals }

class _CalcButton {
  final String? label;
  final IconData? icon;
  final _ButtonType type;
  final VoidCallback onTap;
  final bool isActive;

  _CalcButton({
    this.label,
    this.icon,
    this.type = _ButtonType.digit,
    required this.onTap,
    this.isActive = false,
  });
}
