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
          "color INTEGER, kilometraje REAL, anyo INTEGER, combustible TEXT, observaciones TEXT, fecha_vencimiento_seguro TEXT, "
          "ruta_foto TEXT, cantidad_combustible INTEGER, fecha_proxima_itv TEXT, necesita_limpieza INTEGER, precios TEXT)",
        );

        // tabla reparaciones (se relacione con coche)
        await db.execute(
          "CREATE TABLE reparaciones (id INTEGER PRIMARY KEY, id_coche INTEGER, descripcion TEXT, fecha_inicio TEXT, fecha_fin TEXT, coste REAL, rutas_fotos TEXT)",
        );

        // Tabla de los Clientes (se relaciona con coche mediante la tabla Alquileres)
        await db.execute(
          "CREATE TABLE clientes (id INTEGER PRIMARY KEY, nombre TEXT, tipo_documento TEXT, documento_oficial TEXT UNIQUE NOT NULL, telefono TEXT, direccion TEXT, email TEXT, ruta_foto TEXT)",
        );

        // Tabla de los Alquileres (La que une coche y cliente)
        await db.execute(
          "CREATE TABLE alquileres (id INTEGER PRIMARY KEY, id_coche INTEGER, id_cliente INTEGER, fecha_inicio TEXT, fecha_fin TEXT, "
          "fecha_devolucion TEXT, precio REAL, estado TEXT, observaciones TEXT, forma_pago TEXT, fianza REAL, devolver_fianza INTEGER)",
        );

        // tabla fotos (se relaciona con alquileres)
        await db.execute("CREATE TABLE fotos (id INTEGER PRIMARY KEY, id_alquiler INTEGER, ruta TEXT)");

        // tabla multas (se relaciona con alquiler)
        // tiene el campo pagada que es un int ya que no hay bool (0 = no pagada, 1 = si pagada)
        await db.execute(
          "CREATE TABLE multas (id INTEGER PRIMARY KEY, id_alquiler INTEGER, descripcion TEXT, fecha TEXT, fecha_limite TEXT, precio REAL, pagada INTEGER)",
        );
      },
    );
  }

  static Future<bool> exportarBD() async {
    try {
      String pathBaseDatos = await getDatabasesPath();
      String rutaBaseDatos = join(pathBaseDatos, "alquileres.db");
      File archivo = File(rutaBaseDatos);

      if (!await archivo.exists()) {
        print("No se encuentra el archivo .db");
        return false;
      }

      if (Platform.isWindows) {
        //si el windows Usa el explorador de archivos para guardar
        String? rutaDestino = await FilePicker.platform.saveFile(
          dialogTitle: '¿Dónde quieres guardar la base de datos?',
          fileName: 'alquileres.db',
        );

        if (rutaDestino == null) {
          return false; // usuario canceló
        }

        await archivo.copy(rutaDestino);
        print("Copiado a: $rutaDestino");
        return true;
      } else {
        // si el movil usamos el menú de compartir (WhatsApp, Drive, etc)
        await Share.shareXFiles([XFile(rutaBaseDatos)], text: "Copia de seguridad");
        return true;
      }
    } catch (e) {
      print("Error al exportar: $e");
      return false;
    }
  }

  static Future<bool> importarBD() async {
    try {
      // Seleccionar el archivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'], // Solo permite archivos con esta extensión
      );

      if (result == null || result.files.single.path == null) {
        return false; // El usuario canceló
      }

      File archivoNuevo = File(result.files.single.path!);

      // Obtener la ruta donde la app guarda su base de datos actual
      String pathBaseDatos = await getDatabasesPath();
      String rutaDestino = join(pathBaseDatos, "alquileres.db");

      // Cerrar la base de datos actual antes de sobrescribir
      final db = await proyectodb();
      await db.close();

      // Copiar el archivo seleccionado a la ruta interna
      await archivoNuevo.copy(rutaDestino);

      print("Base de datos importada desde: ${archivoNuevo.path}");
      return true;
    } catch (e) {
      print("Error al importar: $e");
      return false;
    }
  }

  static Future<void> limpiarRegistrosBaseDatos() async {
    try {
      final db = await proyectodb();

      await db.delete("vehiculos");
      await db.delete("reparaciones");
      await db.delete("clientes");
      await db.delete("alquileres");
      await db.delete("fotos");
    } catch (e) {
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

  static Future<List<Map<String, dynamic>>> obtenerMultasPorId(int idMulta) async {
    final baseDatos = await proyectodb();
    return await baseDatos.query("multas", where: "id = ?", whereArgs: [idMulta]);
  }

  static Future<List<Map<String, dynamic>>> obtenerMultasPorIdAlquiler(int idAlquiler) async {
    final baseDatos = await proyectodb();
    return await baseDatos.query("multas", where: "id_alquiler = ?", whereArgs: [idAlquiler]);
  }

  static Future<void> borrarCliente(int idCliente) async {
    final db = await proyectodb();
    await db.delete("alquileres", where: "id_cliente = ?", whereArgs: [idCliente]);
    await db.delete("clientes", where: "id = ?", whereArgs: [idCliente]);
  }

  static Future<void> borrarVehiculo(int idVehiculo) async {
    final db = await proyectodb();
    await db.delete("reparaciones", where: "id_coche = ?", whereArgs: [idVehiculo]);
    await db.delete("alquileres", where: "id_coche = ?", whereArgs: [idVehiculo]);
    await db.delete("vehiculos", where: "id = ?", whereArgs: [idVehiculo]);
  }

  static Future<void> borrarAlquiler(int idAlquiler) async {
    final db = await proyectodb();

    // obtener el alquiler para saber qué coche estaba alquilado
    final alquiler = await db.query("alquileres", where: "id = ?", whereArgs: [idAlquiler]);

    if (alquiler.isNotEmpty) {
      Object? idCoche = alquiler.first["id_coche"];
      // borrar alquiler
      await db.delete("alquileres", where: "id = ?", whereArgs: [idAlquiler]);
      // cambiar coche a disponible
      await db.update("vehiculos", {"estado": "Disponible"}, where: "id = ?", whereArgs: [idCoche]);
    }
  }

  static Future<void> borrarReparacion(int idReparacion) async {
    final db = await proyectodb();
    await db.delete("reparaciones", where: "id = ?", whereArgs: [idReparacion]);
  }

  static Future<bool> cocheEstaDisponible(int idVehiculo, String inicio, String fin) async {
    final db = await proyectodb();

    // 1. Comprobar si hay alquileres que coincidan
    final alquileresOcupados = await db.query(
      "alquileres",
      where: "id_coche = ? AND estado != ? AND ? <= fecha_fin AND ? >= fecha_inicio",
      whereArgs: [idVehiculo, "Terminado", inicio, fin],
    );

    if (alquileresOcupados.isNotEmpty) return false;

    // 2. Comprobar si hay reparaciones (Taller) que coincidan
    // Usamos fecha_inicio y fecha_fin de la tabla reparaciones
    final tallerOcupado = await db.query(
      "reparaciones",
      where: "id_coche = ? AND ? <= fecha_fin AND ? >= fecha_inicio",
      whereArgs: [idVehiculo, inicio, fin],
    );

    return tallerOcupado.isEmpty;
  }

  static Future<Map<String, double>> obtenerContabilidadPorFechas(String inicio, String fin) async {
    final db = await DatabaseHelper.proyectodb();

    final List<Map<String, dynamic>> resultados = await db.rawQuery(
      '''SELECT forma_pago, 
       SUM(
         IFNULL(precio, 0) + 
         CASE WHEN devolver_fianza = 0 THEN IFNULL(fianza, 0) ELSE 0 END
       ) as total 
       FROM alquileres 
       WHERE estado = 'Terminado'
       AND fecha_inicio BETWEEN ? AND ?  -- CAMBIO AQUÍ: Usamos BETWEEN
       GROUP BY forma_pago''',
      [inicio, fin], // Ahora el orden es Inicio, Fin
    );

    Map<String, double> totales = {"Efectivo": 0.0, "Tarjeta": 0.0, "Transferencia": 0.0};

    for (var row in resultados) {
      String? fp = row['forma_pago'];
      // Asegúrate de que comparas exactamente con los strings del mapa
      if (fp != null && totales.containsKey(fp)) {
        totales[fp] = (row['total'] as num).toDouble();
      }
    }

    return totales;
  }

  // Metodo para comprobar si hoy hay reparaciones activas y actualizar el estado del vehiculo a "Taller"
  static Future<void> actualizarEstadosTallerAutomaticamente() async {
    final db = await proyectodb();

    // Sacamos la fecha de hoy en formato YYYY-MM-DD
    DateTime fechaHoy = DateTime.now();
    String hoyStr =
        "${fechaHoy.year}-${fechaHoy.month.toString().padLeft(2, '0')}-${fechaHoy.day.toString().padLeft(2, '0')}";

    // Actualizamos a 'Taller' todos los vehículos que tengan una reparación
    // donde la fecha de inicio sea <= hoy y la fecha de fin sea >= hoy
    await db.rawUpdate(
      '''
      UPDATE vehiculos 
      SET estado = 'Taller' 
      WHERE id IN (
        SELECT id_coche 
        FROM reparaciones 
        WHERE fecha_inicio <= ? AND fecha_fin >= ?
      )
    ''',
      [hoyStr, hoyStr],
    );

    // los coches salgan del taller automáticamente si la fecha de fin ya pasó
    // vuelvan a estar 'Disponible' (siempre que su estado actual sea 'Taller')
    await db.rawUpdate(
      '''
      UPDATE vehiculos 
      SET estado = 'Disponible' 
      WHERE estado = 'Taller' AND id NOT IN (
        SELECT id_coche 
        FROM reparaciones 
        WHERE fecha_inicio <= ? AND fecha_fin >= ?
      )
    ''',
      [hoyStr, hoyStr],
    );

    print("Estados de taller actualizados automáticamente para la fecha: $hoyStr");
  }

  /*static Future<void> insertarCliente(Cliente cliente) async {
    final db = await proyectodb();

    await db.insert(
      "clientes",
      cliente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }*/
}

