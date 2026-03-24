class Multa {
  final int? id;
  final int idAlquiler;
  final String descripcion;
  final String fecha;
  final String fechaLimite;
  final double precio;
  final int pagada; // 0 o 1

  Multa({
    this.id,
    required this.idAlquiler,
    required this.descripcion,
    required this.fecha,
    required this.fechaLimite,
    required this.precio,
    required this.pagada,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "id_alquiler": idAlquiler,
      "descripcion": descripcion,
      "fecha": fecha,
      "fecha_limite": fechaLimite,
      "precio": precio,
      "pagada": pagada,
    };
  }

  factory Multa.fromMap(Map<String, dynamic> map) {
    return Multa(
      id: map["id"],
      idAlquiler: map["id_alquiler"],
      descripcion: map["descripcion"],
      fecha: map["fecha"],
      fechaLimite: map["fecha_limite"],
      precio: map["precio"],
      pagada: map["pagada"],
    );
  }
}
