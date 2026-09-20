class Alarma {
  final String id;
  final String lugarId;
  final String hora;
  final String dias; // NUEVO: Días seleccionados
  final bool activa;
  final int orden;

  Alarma({
    required this.id,
    required this.lugarId,
    required this.hora,
    required this.dias, // NUEVO
    this.activa = true,
    required this.orden,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'lugarId': lugarId,
    'hora': hora,
    'dias': dias, // NUEVO
    'activa': activa ? 1 : 0,
    'orden': orden,
  };

  factory Alarma.fromMap(Map<String, dynamic> map) => Alarma(
    id: map['id'] as String,
    lugarId: map['lugarId'] as String,
    hora: map['hora'] as String,
    dias: (map['dias'] as String?) ?? '', // NUEVO
    activa: (map['activa'] as int) == 1,
    orden: (map['orden'] as int?) ?? 0,
  );

  Alarma copyWith({
    String? id,
    String? lugarId,
    String? hora,
    String? dias, // NUEVO
    bool? activa,
    int? orden,
  }) {
    return Alarma(
      id: id ?? this.id,
      lugarId: lugarId ?? this.lugarId,
      hora: hora ?? this.hora,
      dias: dias ?? this.dias, // NUEVO
      activa: activa ?? this.activa,
      orden: orden ?? this.orden,
    );
  }
}
