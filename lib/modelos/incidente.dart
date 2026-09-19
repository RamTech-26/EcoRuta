/// Modelo de un incidente reportado por el usuario.
/// Guarda los tipos marcados, una descripción opcional, la calle
/// y la fecha automática del reporte.
class Incidente {
  final String id;              // identificador único
  final List<String> tipos;     // lista de tipos marcados (Choque, Inundación, etc.)
  final String descripcion;     // texto libre del campo "Otros" (puede quedar vacío)
  final String calle;           // calle o intersección escrita por el usuario
  final String fecha;           // fecha y hora del reporte (formato ISO)
  final String foto;            // ruta de la foto (vacío por ahora)

  Incidente({
    required this.id,
    required this.tipos,
    required this.descripcion,
    required this.calle,
    required this.fecha,
    required this.foto,
  });

  /// Convierte el incidente a un mapa para guardarlo en la base.
  Map<String, dynamic> toMap() => {
        'id': id,
        'tipos': tipos.join('|'),   // se guardan separados por "|"
        'descripcion': descripcion,
        'calle': calle,
        'fecha': fecha,
        'foto': foto,
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
      );

  /// Copia con cambios opcionales.
  Incidente copyWith({
    String? id,
    List<String>? tipos,
    String? descripcion,
    String? calle,
    String? fecha,
    String? foto,
  }) =>
      Incidente(
        id: id ?? this.id,
        tipos: tipos ?? this.tipos,
        descripcion: descripcion ?? this.descripcion,
        calle: calle ?? this.calle,
        fecha: fecha ?? this.fecha,
        foto: foto ?? this.foto,
      );
}