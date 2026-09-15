class LugarFrecuente {                          // modelo de un lugar guardado
  final String id;                              // identificador único
  final String nombre;                          // ej: "Casa", "Trabajo", "Gimnasio"
  final double latitud;                         // coordenada
  final double longitud;                        // coordenada
  final String direccion;                       // dirección textual (opcional)
  final String icono;                           // nombre del ícono: "home", "work", "gym"

  const LugarFrecuente({                        // constructor constante
    required this.id,
    required this.nombre,
    required this.latitud,
    required this.longitud,
    required this.direccion,
    required this.icono,
  });

  Map<String, dynamic> toMap() {                // convierte a mapa para guardar
    return {
      'id': id,
      'nombre': nombre,
      'latitud': latitud,
      'longitud': longitud,
      'direccion': direccion,
      'icono': icono,
    };
  }

  factory LugarFrecuente.fromMap(Map<String, dynamic> mapa) { // convierte desde mapa
    return LugarFrecuente(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String,
      latitud: (mapa['latitud'] as num).toDouble(),
      longitud: (mapa['longitud'] as num).toDouble(),
      direccion: mapa['direccion'] as String,
      icono: mapa['icono'] as String,
    );
  }

  LugarFrecuente copyWith({                     // copia modificada sin mutar el original
    String? id,
    String? nombre, 
    double? latitud,
    double? longitud,
    String? direccion,
    String? icono,
  }) {
    return LugarFrecuente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      direccion: direccion ?? this.direccion,
      icono: icono ?? this.icono,
    );
  }

  @override
  bool operator ==(Object other) {              // comparación por id
    if (identical(this, other)) return true;
    return other is LugarFrecuente && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;              // hash basado en id
}