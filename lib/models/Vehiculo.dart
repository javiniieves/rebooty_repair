import 'dart:ffi';

class Vehiculo {
  final int? id;
  final String matricula;
  final String marca;
  final String modelo;
  final String estado;
  final int? color;
  final double? kilometraje;
  final int? anyo;
  final String? combustible;
  final String? observaciones;
  final String? fechaVencimientoSeguro;
  final String? rutaFoto;
  final int? cantidadCombustible;
  final String? fechaProximaItv;
  int? necesitaLimpieza;
  // Cambiado de double a String para guardar los 7 precios de la tabla
  String? precios;

  Vehiculo({
    this.id,
    required this.matricula,
    required this.marca,
    required this.modelo,
    required this.estado,
    this.color,
    this.kilometraje,
    this.anyo,
    this.combustible,
    this.observaciones,
    this.fechaVencimientoSeguro,
    this.rutaFoto,
    this.cantidadCombustible,
    this.fechaProximaItv,
    this.necesitaLimpieza,
    this.precios
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "matricula": matricula,
      "marca": marca,
      "modelo": modelo,
      "estado": estado,
      "color": color,
      "kilometraje": kilometraje,
      "anyo": anyo,
      "combustible": combustible,
      "observaciones": observaciones,
      "fecha_vencimiento_seguro": fechaVencimientoSeguro,
      "ruta_foto": rutaFoto,
      "cantidad_combustible": cantidadCombustible,
      "fecha_proxima_itv": fechaProximaItv,
      "necesita_limpieza": necesitaLimpieza,
      "precios" : precios // Mapeado como String
    };
  }

  factory Vehiculo.fromMap(Map<String, dynamic> map) {
    return Vehiculo(
        id: map["id"],
        matricula: map["matricula"],
        marca: map["marca"],
        modelo: map["modelo"],
        estado: map["estado"],
        color: map["color"],
        kilometraje: map["kilometraje"],
        anyo: map["anyo"],
        combustible: map["combustible"],
        observaciones: map["observaciones"],
        fechaVencimientoSeguro: map["fecha_vencimiento_seguro"],
        rutaFoto: map["ruta_foto"],
        cantidadCombustible: map["cantidad_combustible"],
        fechaProximaItv: map["fecha_proxima_itv"],
        necesitaLimpieza: map["necesita_limpieza"],
        precios: map["precios"] // Mapeado como String
    );
  }
}