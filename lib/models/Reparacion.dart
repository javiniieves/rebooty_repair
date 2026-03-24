class Reparacion {
  final int? id;
  final int? idCoche;
  final String descripcion;
  final String fechaInicio;
  final String fechaFin;
  final double? coste;
  final String? rutasFotos;

  Reparacion({
    this.id,
    required this.idCoche,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    this.coste,
    this.rutasFotos,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "id_coche": idCoche,
      "descripcion": descripcion,
      "fecha_inicio": fechaInicio,
      "fecha_fin": fechaFin,
      "coste": coste,
      "rutas_fotos": rutasFotos,
    };
  }

  factory Reparacion.fromMap(Map<String, dynamic> map) {
    return Reparacion(
      id: map['id'] as int?,
      idCoche: map['id_coche'] as int,
      descripcion: map['descripcion'] as String,
      fechaInicio: map['fecha_inicio'] as String,
      fechaFin: map['fecha_fin'] as String,
      coste: map['coste'] != null
          ? (map['coste'] is double
          ? map['coste'] as double
          : double.tryParse(map['coste'].toString()))
          : null,
      rutasFotos: map['rutas_fotos'] as String?,
    );
  }
}