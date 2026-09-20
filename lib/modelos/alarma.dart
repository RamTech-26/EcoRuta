class Alarma {
  final String id;
  final String lugarId;
  final String hora; // Formato HH:mm
  final bool activa;

  Alarma({
    required this.id,
    required this.lugarId,
    required this.hora,
    this.activa = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'lugarId': lugarId,
    'hora': hora,
    'activa': activa ? 1 : 0,
  };

  factory Alarma.fromMap(Map<String, dynamic> map) => Alarma(
    id: map['id'] as String,
    lugarId: map['lugarId'] as String,
    hora: map['hora'] as String,
    activa: (map['activa'] as int) == 1,
  );

  Alarma copyWith({
    String? id,
    String? lugarId,
    String? hora,
    bool? activa,
  }) {
    return Alarma(
      id: id ?? this.id,
      lugarId: lugarId ?? this.lugarId,
      hora: hora ?? this.hora,
      activa: activa ?? this.activa,
    );
  }
}