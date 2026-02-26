class ConversionGuardada {
  final int? id;
  final double montoSoles;
  final double montoPesos;
  final double tasaUsada;
  final String? nota;
  final String fecha;
  final bool synced;

  ConversionGuardada({
    this.id,
    required this.montoSoles,
    required this.montoPesos,
    required this.tasaUsada,
    this.nota,
    required this.fecha,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monto_soles': montoSoles,
      'monto_pesos': montoPesos,
      'tasa_usada': tasaUsada,
      'nota': nota,
      'fecha': fecha,
      'synced': synced ? 1 : 0,
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
      synced: (map['synced'] as int) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monto_soles': montoSoles,
      'monto_pesos': montoPesos,
      'tasa_usada': tasaUsada,
      'nota': nota,
      'fecha': fecha,
    };
  }
}
