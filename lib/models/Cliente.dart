class Cliente {
   int? id;
   String nombre;
   String tipoDocumento;
   String documentoOficial;
   String? telefono;
   String? direccion;
   String? email;
   String? rutaFoto;

  Cliente({
    this.id,
    required this.nombre,
    required this.tipoDocumento,
    required this.documentoOficial,
    this.telefono,
    this.direccion,
    this.email,
    this.rutaFoto,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nombre": nombre,
      "tipo_documento": tipoDocumento,
      "documento_oficial": documentoOficial,
      "telefono": telefono,
      "direccion": direccion,
      "email": email,
      "ruta_foto": rutaFoto,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map["id"],
      nombre: map["nombre"],
      tipoDocumento: map["tipo_documento"],
      documentoOficial: map["documento_oficial"],
      telefono: map["telefono"],
      direccion: map["direccion"],
      email: map["email"],
      rutaFoto: map["ruta_foto"],
    );
  }
}
