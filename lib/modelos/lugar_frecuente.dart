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
    this.orden = 0,
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
  factory LugarFrecuente.fromMap(Map<String, dynamic> m) => LugarFrecuente(
    id: m['id'],
    nombre: m['nombre'],
    direccion: m['direccion'],
    latitud: (m['latitud'] as num).toDouble(),
    longitud: (m['longitud'] as num).toDouble(),
    icono: m['icono'],
    orden: (m['orden'] as int?) ?? 0,
  );
  LugarFrecuente copyWith({
    String? id,
    String? nombre,
    String? direccion,
    double? latitud,
    double? longitud,
    String? icono,
    int? orden,
  }) => LugarFrecuente(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    direccion: direccion ?? this.direccion,
    latitud: latitud ?? this.latitud,
    longitud: longitud ?? this.longitud,
    icono: icono ?? this.icono,
    orden: orden ?? this.orden,
  );
}
