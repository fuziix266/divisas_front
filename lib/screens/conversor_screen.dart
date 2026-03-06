import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/conversion_provider.dart';
import '../providers/historial_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/guardar_modal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import 'calculator_screen.dart';

String _formatPesos(double valor) {
  final formatter = NumberFormat('#,##0', 'en_US');
  return formatter.format(valor.round());
}

class ConversorScreen extends StatefulWidget {
  final int initialTab;
  const ConversorScreen({super.key, this.initialTab = 0});

  @override
  State<ConversorScreen> createState() => _ConversorScreenState();
}

class _ConversorScreenState extends State<ConversorScreen> {
  late int _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversionProvider>().cargarTasaActiva();
    });
  }

  void _onKeyPressed(String key) {
    final provider = context.read<ConversionProvider>();
    String current = provider.inputDisplay;

    // No permitir más de un punto decimal
    if (key == '.' && current.contains('.')) return;
    // Limitar decimales a 2
    if (current.contains('.')) {
      final decimales = current.split('.')[1];
      if (decimales.length >= 2) return;
    }

    current += key;
    provider.actualizarMonto(current);
  }

  void _onBackspace() {
    final provider = context.read<ConversionProvider>();
    String current = provider.inputDisplay;
    if (current.isNotEmpty) {
      current = current.substring(0, current.length - 1);
      provider.actualizarMonto(current);
    }
  }

  void _mostrarGuardarModal() {
    final provider = context.read<ConversionProvider>();
    if (provider.montoSoles <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ingresa un monto antes de guardar',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GuardarModal(
        montoSoles: provider.montoSoles,
        montoPesos: provider.montoPesos,
        tasa: provider.tasaActual?.valorSol ?? 0,
        onGuardar: (nota) async {
          await provider.guardarConversion(nota);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text('¡Guardado con éxito!', style: GoogleFonts.inter()),
                  ],
                ),
                backgroundColor: AppTheme.primaryColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            // Recargar historial si estamos en ese tab
            context.read<HistorialProvider>().cargarHistorial();
          }
        },
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundLight,
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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

              // Emergencias Chile
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

              // Emergencias Perú
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

              const SizedBox(height: 8),
              // Calculadora
              ListTile(
                leading: const Text('🧮', style: TextStyle(fontSize: 22)),
                title: Text(
                  'Calculadora',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalculatorScreen(),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Enlace Retrobox
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentTab,
          children: [_buildConversorView(), _buildHistorialView()],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab + 1,
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
          } else {
            setState(() {
              _currentTab = index - 1;
            });
            if (index == 2) {
              context.read<HistorialProvider>().cargarHistorial();
            }
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
            // Analytics: emergencia consultada
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

  Widget _buildConversorView() {
    return Consumer<ConversionProvider>(
      builder: (context, provider, child) {
        final tasa = provider.tasaActual;

        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  Text(
                    tasa != null
                        ? '1 SOL = ${tasa.valorSol.toStringAsFixed(0)} CLP'
                        : 'Conversor',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                ],
              ),
            ),

            // Zona de conversión
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pregunta principal
                    Text(
                      provider.solAPeso
                          ? '¿Cuántos soles pagarás?'
                          : '¿Cuántos pesos pagarás?',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Card INPUT - lo que el usuario ingresa
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Bandera + moneda
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  provider.solAPeso ? '🇵🇪' : '🇨🇱',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  provider.solAPeso ? 'SOL' : 'CLP',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Monto ingresado
                          Text(
                            provider.solAPeso ? 'S/ ' : '\$ ',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Text(
                            provider.inputDisplay.isEmpty
                                ? '0'
                                : !provider.solAPeso
                                ? _formatPesos(
                                    double.tryParse(provider.inputDisplay) ?? 0,
                                  )
                                : provider.inputDisplay,
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Botón swap
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: GestureDetector(
                        onTap: () => provider.toggleDireccion(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.swap_vert,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                    // Card RESULTADO
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          // Bandera + moneda
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  provider.solAPeso ? '🇨🇱' : '🇵🇪',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  provider.solAPeso ? 'CLP' : 'SOL',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Monto resultado
                          Text(
                            provider.solAPeso ? '\$ ' : 'S/ ',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Text(
                            provider.solAPeso
                                ? _formatPesos(provider.montoPesos)
                                : provider.montoSoles.toStringAsFixed(2),
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Frase descriptiva
                    if (provider.inputDisplay.isNotEmpty &&
                        provider.inputDisplay != '.' &&
                        provider.inputDisplay != '0')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7518),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          provider.solAPeso
                              ? 'S/${provider.montoSoles.toStringAsFixed(2)} soles peruanos son \$${_formatPesos(provider.montoPesos)} pesos chilenos'
                              : '\$${_formatPesos(provider.montoPesos)} pesos chilenos son S/${provider.montoSoles.toStringAsFixed(2)} soles peruanos',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Publicidad
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'www.retrobox.cl',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade400,
                ),
              ),
            ),

            // Teclado numérico
            NumericKeypad(
              onKeyPressed: _onKeyPressed,
              onBackspace: _onBackspace,
            ),

            // Botones guardar y limpiar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  // Botón guardar (más pequeño)
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _mostrarGuardarModal,
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('Guardar'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Botón limpiar (más grande)
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          context.read<ConversionProvider>().limpiarInput();
                        },
                        icon: const Icon(
                          Icons.cleaning_services_outlined,
                          size: 18,
                        ),
                        label: const Text('Limpiar'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistorialView() {
    return _HistorialTab(
      onOpenDrawer: () => _scaffoldKey.currentState?.openEndDrawer(),
    );
  }
}

class _HistorialTab extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  const _HistorialTab({required this.onOpenDrawer});

  @override
  State<_HistorialTab> createState() => _HistorialTabState();
}

class _HistorialTabState extends State<_HistorialTab> {
  String _filtro = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistorialProvider>().cargarHistorial();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistorialProvider>(
      builder: (context, provider, child) {
        List<dynamic> items;
        switch (_filtro) {
          case 'Hoy':
            items = provider.filtrarHoy();
            break;
          case 'Semana':
            items = provider.filtrarSemana();
            break;
          default:
            items = provider.conversiones;
        }

        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  Text(
                    'Historial',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: widget.onOpenDrawer,
                  ),
                ],
              ),
            ),

            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (q) => provider.buscar(q),
                  decoration: InputDecoration(
                    hintText: 'Buscar notas guardadas...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filtros + botón borrar todo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Filtros
                  ...['Todos', 'Hoy', 'Semana'].map((filtro) {
                    final isSelected = _filtro == filtro;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filtro = filtro),
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            filtro,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  // Botón borrar todo
                  if (items.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              '¿Eliminar todo?',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            content: Text(
                              '¿Estás seguro de que quieres eliminar todo el historial?',
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
                                  backgroundColor: Colors.red.shade500,
                                  foregroundColor: Colors.white,
                                  textStyle: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                onPressed: () {
                                  provider.eliminarTodo();
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Borrar todo',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Lista
            Expanded(
              child: provider.cargando
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_edu,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sin conversiones guardadas',
                            style: GoogleFonts.inter(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildHistorialCard(item, provider);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistorialCard(dynamic conversion, HistorialProvider provider) {
    final fecha = DateTime.tryParse(conversion.fecha);
    final fechaStr = fecha != null
        ? '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}'
        : '';

    return Dismissible(
      key: Key('conv_${conversion.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        if (conversion.id != null) {
          provider.eliminar(conversion.id!);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Botón eliminar individual (esquina superior derecha)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  if (conversion.id != null) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          '¿Eliminar conversión?',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        content: Text(
                          '¿Estás seguro de que quieres eliminar esta conversión?',
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
                              backgroundColor: Colors.red.shade500,
                              foregroundColor: Colors.white,
                              textStyle: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              provider.eliminar(conversion.id!);
                            },
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
            ),
            // Contenido del card
            Padding(
              padding: const EdgeInsets.only(right: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    'S/ ${conversion.montoSoles.toStringAsFixed(2)} ',
                              ),
                              TextSpan(
                                text: '→',
                                style: TextStyle(color: AppTheme.primaryColor),
                              ),
                              TextSpan(
                                text:
                                    ' \$ ${_formatPesos(conversion.montoPesos)} CLP',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (conversion.nota != null &&
                      conversion.nota!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '"${conversion.nota}"',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade100),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TASA',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            Text(
                              '1 SOL = ${conversion.tasaUsada.toStringAsFixed(0)} CLP',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'FECHA',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            Text(
                              fechaStr,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade500,
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
          ],
        ),
      ),
    );
  }
}
