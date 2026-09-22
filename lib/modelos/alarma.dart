class Alarma {
  final String id;
  final String lugarId;
  final String hora;
  final String dias;
  final bool activa;
  final int orden;
  final bool loopAudio;
  final bool vibrar;
  final String sonido;
  final bool volumenPersonalizado;
  final double volumen;

  Alarma({
    required this.id,
    required this.lugarId,
    required this.hora,
    required this.dias,
    this.activa = true,
    required this.orden,
    this.loopAudio = true,
    this.vibrar = true,
    this.sonido = 'Marimba',
    this.volumenPersonalizado = false,
    this.volumen = 0.8,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'lugarId': lugarId,
    'hora': hora,
    'dias': dias,
    'activa': activa ? 1 : 0,
    'orden': orden,
    'loopAudio': loopAudio ? 1 : 0,
    'vibrar': vibrar ? 1 : 0,
    'sonido': sonido,
    'volumenPersonalizado': volumenPersonalizado ? 1 : 0,
    'volumen': volumen,
  };

  factory Alarma.fromMap(Map<String, dynamic> map) => Alarma(
    id: map['id'] as String,
    lugarId: map['lugarId'] as String,
    hora: map['hora'] as String,
    dias: map['dias'] as String,
    activa: (map['activa'] as int) == 1,
    orden: (map['orden'] as int?) ?? 0,
    loopAudio: (map['loopAudio'] as int?) == 1,
    vibrar: (map['vibrar'] as int?) == 1,
    sonido: (map['sonido'] as String?) ?? 'Marimba',
    volumenPersonalizado: (map['volumenPersonalizado'] as int?) == 1,
    volumen: (map['volumen'] as num?)?.toDouble() ?? 0.8,
  );

  Alarma copyWith({
    String? id,
    String? lugarId,
    String? hora,
    String? dias,
    bool? activa,
    int? orden,
    bool? loopAudio,
    bool? vibrar,
    String? sonido,
    bool? volumenPersonalizado,
    double? volumen,
  }) => Alarma(
    id: id ?? this.id,
    lugarId: lugarId ?? this.lugarId,
    hora: hora ?? this.hora,
    dias: dias ?? this.dias,
    activa: activa ?? this.activa,
    orden: orden ?? this.orden,
    loopAudio: loopAudio ?? this.loopAudio,
    vibrar: vibrar ?? this.vibrar,
    sonido: sonido ?? this.sonido,
    volumenPersonalizado: volumenPersonalizado ?? this.volumenPersonalizado,
    volumen: volumen ?? this.volumen,
  );

  // Mapea texto de días a enteros (1 = Lunes, 7 = Domingo)
  List<int> get diasEnEnteros {
    if (dias.isEmpty) return [];
    final mapaDias = {
      'Lun': 1, 'Mar': 2, 'Mié': 3, 'Jue': 4, 'Vie': 5, 'Sáb': 6, 'Dom': 7
    };
    return dias
        .split(', ')
        .map((d) => mapaDias[d.trim()])
        .whereType<int>()
        .toList();
  }

  // Calcula el próximo DateTime válido
  DateTime obtenerProximaFecha() {
    final partesHora = hora.split(':');
    final horaInt = int.parse(partesHora[0]);
    final minutoInt = int.parse(partesHora[1]);
    final ahora = DateTime.now();
    final diasSeleccionados = diasEnEnteros;

    if (diasSeleccionados.isEmpty) {
      var fechaTentativa = DateTime(ahora.year, ahora.month, ahora.day, horaInt, minutoInt);
      if (fechaTentativa.isBefore(ahora)) {
        fechaTentativa = fechaTentativa.add(const Duration(days: 1));
      }
      return fechaTentativa;
    }

    for (int i = 0; i < 7; i++) {
      final fechaTentativa = ahora.add(Duration(days: i));
      if (diasSeleccionados.contains(fechaTentativa.weekday)) {
        final fechaConHora = DateTime(
          fechaTentativa.year,
          fechaTentativa.month,
          fechaTentativa.day,
          horaInt,
          minutoInt,
        );
        if (fechaConHora.isAfter(ahora)) {
          return fechaConHora;
        }
      }
    }
    return ahora.add(const Duration(days: 1));
  }
}