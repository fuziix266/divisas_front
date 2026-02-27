class ConversionGuardada {
  final int? id;
  final double montoSoles;
  final double montoPesos;
  final double tasaUsada;
  final String? nota;
  final String fecha;

  ConversionGuardada({
    this.id,
    required this.montoSoles,
    required this.montoPesos,
    required this.tasaUsada,
    this.nota,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monto_soles': montoSoles,
      'monto_pesos': montoPesos,
      'tasa_usada': tasaUsada,
      'nota': nota,
      'fecha': fecha,
    };
  }

  factory ConversionGuardada.fromMap(Map<String, dynamic> map) {
    return ConversionGuardada(
      id: map['id'] as int?,
      montoSoles: (map['monto_soles'] as num).toDouble(),
      montoPesos: (map['monto_pesos'] as num).toDouble(),
      tasaUsada: (map['tasa_usada'] as num).toDouble(),
      nota: map['nota'] as String?,
      fecha: map['fecha'] as String,
    );
  }
}
