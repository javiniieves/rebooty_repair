import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class DatabaseHelper {
  static Future<Database> proyectodb() async {
    final ruta = await getDatabasesPath();

    final path = join(ruta, "alquileres.db");

    print("Ruta base de datos: $path");

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // tabla vehículos
        await db.execute(
          "CREATE TABLE vehiculos (id INTEGER PRIMARY KEY, matricula TEXT, marca TEXT, modelo TEXT, estado TEXT, "
          "color INTEGER, kilometraje REAL, anyo INTEGER, combustible TEXT, observaciones TEXT, fecha_vencimiento_seguro TEXT)",
        );

        // tabla reparaciones (se relacione con coche)
        await db.execute(
          "CREATE TABLE reparaciones (id INTEGER PRIMARY KEY, id_coche INTEGER, descripcion TEXT, fecha_inicio TEXT, fecha_fin TEXT, coste REAL)",
        );

        // Tabla de los Clientes (se relaciona con coche mediante la tabla Alquileres)
        await db.execute(
          "CREATE TABLE clientes (id INTEGER PRIMARY KEY, nombre TEXT, dni TEXT, telefono TEXT, direccion TEXT, email TEXT)",
        );

        // Tabla de los Alquileres (La que une coche y cliente)
        await db.execute(
          "CREATE TABLE alquileres (id INTEGER PRIMARY KEY, id_coche INTEGER, id_cliente INTEGER, fecha_inicio TEXT, fecha_fin TEXT, fecha_devolucion TEXT, precio REAL, estado TEXT)",
        );

        // tabla fotos (se relaciona con alquileres)
        await db.execute("CREATE TABLE fotos (id INTEGER PRIMARY KEY, id_alquiler INTEGER, ruta TEXT)");
      },
    );
  }

  static Future<void> exportarBD() async {
    try {
      String pathBaseDatos = await getDatabasesPath();
      String rutaBaseDatos = join(pathBaseDatos, "alquileres.db");
      File archivo = File(rutaBaseDatos);

      if (!await archivo.exists()) {
        print("No se encuentra el archivo .db");
        return;
      }

      if (Platform.isWindows) {
        //si el windows Usa el explorador de archivos para guardar
        String? rutaDestino = await FilePicker.platform.saveFile(
          dialogTitle: '¿Dónde quieres guardar la base de datos?',
          fileName: 'alquileres.db',
        );

        if (rutaDestino != null) {
          await archivo.copy(rutaDestino);
          print("Copiado a: $rutaDestino");
        }
      } else {
        // si el movil usamos el menú de compartir (WhatsApp, Drive, etc)
        await Share.shareXFiles([XFile(rutaBaseDatos)], text: "Copia de seguridad");
      }
    } catch (e) {
      print("Error al exportar: $e");
    }
  }

  static Future<void> limpiarRegistrosBaseDatos() async {
    try{
      final db = await proyectodb();

      await db.delete("vehiculos");
      await db.delete("reparaciones");
      await db.delete("clientes");
      await db.delete("alquileres");
      await db.delete("fotos");

    } catch(e){
      print("Error al borrar los registros de la base de datos");
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerClientesPorId(int idCliente) async {
    final db = await proyectodb();
    return await db.query("clientes", where: "id = ?", whereArgs: [idCliente]);
  }

  static Future<List<Map<String, Object?>>> obtenerVehiculoPorId(int idVehiculo) async {
    final db = await proyectodb();
    return await db.query("vehiculos", where: "id = ?", whereArgs: [idVehiculo]);
  }

  static Future<List<Map<String, dynamic>>> obtenerVehiculosDisponibles() async {
    final baseDatos = await proyectodb();
    return await baseDatos.query("vehiculos", where: "estado = ?", whereArgs: ["Disponible"]);
  }

  static Future<List<Map<String, dynamic>>> obtenerAlquilerPorId(int idAlquiler) async {
    final baseDatos = await proyectodb();
    return await baseDatos.query("alquileres", where: "id = ?", whereArgs: [idAlquiler]);
  }

  static Future<List<Map<String, dynamic>>> obtenerFotosPorIdAlquiler(int idAlquiler) async {
    final baseDatos = await proyectodb();
    return await baseDatos.query("fotos", where: "id_alquiler = ?", whereArgs: [idAlquiler]);
  }

  static Future<List<Map<String, dynamic>>> obtenerReparacionesPorIdVehiculo(int idVehiculo) async {
    final baseDatos = await proyectodb();
    return await baseDatos.query("reparaciones", where: "id_coche = ?", whereArgs: [idVehiculo]);
  }

  static Future<List<Map<String, dynamic>>> obtenerReparacionesPorId(int idReparacion) async {
    final baseDatos = await proyectodb();
    return await baseDatos.query("reparaciones", where: "id = ?", whereArgs: [idReparacion]);
  }
}
