/// Modelo de un incidente reportado por el usuario.
/// Guarda los tipos marcados, una descripción opcional, la calle,
/// la fecha automática del reporte, la foto y la ubicación GPS.
class Incidente {
  final String id;              // identificador único
  final List<String> tipos;     // lista de tipos marcados (Choque, Inundación, etc.)
  final String descripcion;     // texto libre del campo "Otros" (puede quedar vacío)
  final String calle;           // calle o intersección escrita por el usuario
  final String fecha;           // fecha y hora del reporte (formato ISO)
  final String foto;            // ruta local de la foto (vacío si no se adjuntó)
  final double? latitud;        // ubicación GPS (null si no se pudo obtener)
  final double? longitud;

  Incidente({
    required this.id,
    required this.tipos,
    required this.descripcion,
    required this.calle,
    required this.fecha,
    required this.foto,
    this.latitud,
    this.longitud,
  });

  /// Indica si el incidente tiene ubicación GPS.
  bool get tieneUbicacion => latitud != null && longitud != null;

  /// Convierte el incidente a un mapa para guardarlo en la base.
  Map<String, dynamic> toMap() => {
        'id': id,
        'tipos': tipos.join('|'),   // se guardan separados por "|"
        'descripcion': descripcion,
        'calle': calle,
        'fecha': fecha,
        'foto': foto,
        'latitud': latitud,
        'longitud': longitud,
      };

  /// Reconstruye un incidente desde un mapa leído de la base.
  factory Incidente.fromMap(Map<String, dynamic> map) => Incidente(
        id: map['id'] as String,
        tipos: (map['tipos'] as String).isEmpty
            ? []
            : (map['tipos'] as String).split('|'),
        descripcion: map['descripcion'] as String,
        calle: map['calle'] as String,
        fecha: map['fecha'] as String,
        foto: map['foto'] as String,
        latitud: (map['latitud'] as num?)?.toDouble(),
        longitud: (map['longitud'] as num?)?.toDouble(),
      );

  /// Copia con cambios opcionales.
  Incidente copyWith({
    String? id,
    List<String>? tipos,
    String? descripcion,
    String? calle,
    String? fecha,
    String? foto,
    double? latitud,
    double? longitud,
  }) =>
      Incidente(
        id: id ?? this.id,
        tipos: tipos ?? this.tipos,
        descripcion: descripcion ?? this.descripcion,
        calle: calle ?? this.calle,
        fecha: fecha ?? this.fecha,
        foto: foto ?? this.foto,
        latitud: latitud ?? this.latitud,
        longitud: longitud ?? this.longitud,
      );
}