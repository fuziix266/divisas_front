class TasaCambio {
  final int? id;
  final double valorSol; // Cuántos pesos chilenos vale 1 sol
  final String fechaRegistro;
  final bool activa;

  TasaCambio({
    this.id,
    required this.valorSol,
    required this.fechaRegistro,
    this.activa = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'valor_sol': valorSol,
      'fecha_registro': fechaRegistro,
      'activa': activa ? 1 : 0,
    };
  }

  factory TasaCambio.fromMap(Map<String, dynamic> map) {
    return TasaCambio(
      id: map['id'] as int?,
      valorSol: (map['valor_sol'] as num).toDouble(),
      fechaRegistro: map['fecha_registro'] as String,
      activa: (map['activa'] as int) == 1,
    );
  }

  TasaCambio copyWith({
    int? id,
    double? valorSol,
    String? fechaRegistro,
    bool? activa,
  }) {
    return TasaCambio(
      id: id ?? this.id,
      valorSol: valorSol ?? this.valorSol,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      activa: activa ?? this.activa,
    );
  }
}
