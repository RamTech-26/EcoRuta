class LugarFrecuente {
  final String id;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;
  final String icono;
  final int orden;

  LugarFrecuente({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.icono,
    required this.orden,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'direccion': direccion,
    'latitud': latitud,
    'longitud': longitud,
    'icono': icono,
    'orden': orden,
  };

  factory LugarFrecuente.fromMap(Map<String, dynamic> map) => LugarFrecuente(
    id: map['id'] as String,
    nombre: map['nombre'] as String,
    direccion: map['direccion'] as String,
    latitud: (map['latitud'] as num).toDouble(),
    longitud: (map['longitud'] as num).toDouble(),
    icono: map['icono'] as String,
    orden: map['orden'] as int,
  );

  LugarFrecuente copyWith({
    String? id,
    String? nombre,
    String? direccion,
    double? latitud,
    double? longitud,
    String? icono,
    int? orden,
  }) {
    return LugarFrecuente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      icono: icono ?? this.icono,
      orden: orden ?? this.orden,
    );
  }
}
