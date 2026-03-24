class Foto {
  final int? id;
  final int idAlquiler;
  final String ruta;

  Foto({this.id, required this.idAlquiler, required this.ruta});

  Map<String, dynamic> toMap() {
    return {"id": id, "id_alquiler": idAlquiler, "ruta": ruta};
  }

  factory Foto.fromMap(Map<String, dynamic> map) {
    return Foto(id: map["id"], idAlquiler: map["id_alquiler"], ruta: map["ruta"]);
  }
}
