class Alquiler {
  final int? id;
  final int idCoche;
  final int idCliente;
  String fechaInicio;
  String fechaFin;
  String? fechaDevolucion;
  double? precio;
  String estado;
  String? observaciones;
  String? formaPago;
  double? fianza;
  int? devolverFianza;

  Alquiler({
    this.id,
    required this.idCoche,
    required this.idCliente,
    required this.fechaInicio,
    required this.fechaFin,
    this.fechaDevolucion,
    this.precio,
    required this.estado,
    this.observaciones,
    this.formaPago,
    this.fianza,
    this.devolverFianza,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "id_coche": idCoche,
      "id_cliente": idCliente,
      "fecha_inicio": fechaInicio,
      "fecha_fin": fechaFin,
      "fecha_devolucion": fechaDevolucion,
      "precio": precio,
      "estado": estado,
      "observaciones": observaciones,
      "forma_pago": formaPago,
      "fianza": fianza,
      "devolver_fianza": devolverFianza,
    };
  }

  factory Alquiler.fromMap(Map<String, dynamic> map) {
    return Alquiler(
      id: map["id"],
      idCoche: map["id_coche"],
      idCliente: map["id_cliente"],
      fechaInicio: map["fecha_inicio"],
      fechaFin: map["fecha_fin"],
      fechaDevolucion: map["fecha_devolucion"],
      precio: map["precio"],
      estado: map["estado"],
      observaciones: map["observaciones"],
      formaPago: map["forma_pago"],
      fianza: map["fianza"],
      devolverFianza: map["devolver_fianza"],
    );
  }
}
