import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import 'models/Alquiler.dart';
import 'models/Cliente.dart';
import 'models/Foto.dart';
import 'models/Multa.dart';
import 'models/Reparacion.dart';
import 'models/Vehiculo.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('alquileres.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = join(await getDatabasesPath(), filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE vehiculos (
      id INTEGER PRIMARY KEY,
      matricula TEXT,
      marca TEXT,
      modelo TEXT,
      estado TEXT,
      color INTEGER,
      kilometraje REAL,
      anyo INTEGER,
      combustible TEXT,
      observaciones TEXT,
      fecha_vencimiento_seguro TEXT,
      ruta_foto TEXT,
      cantidad_combustible INTEGER,
      fecha_proxima_itv TEXT,
      necesita_limpieza INTEGER,
      precios REAL
    )
    ''');

    await db.execute('''
    CREATE TABLE clientes (
      id INTEGER PRIMARY KEY,
      nombre TEXT,
      tipo_documento TEXT,
      documento_oficial TEXT UNIQUE NOT NULL,
      telefono TEXT,
      direccion TEXT,
      email TEXT,
      ruta_foto TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE alquileres (
      id INTEGER PRIMARY KEY,
      id_coche INTEGER,
      id_cliente INTEGER,
      fecha_inicio TEXT,
      fecha_fin TEXT,
      fecha_devolucion TEXT,
      precio REAL,
      estado TEXT,
      observaciones TEXT,
      forma_pago TEXT,
      fianza REAL,
      devolver_fianza INTEGER
    )
    ''');

    await db.execute('''
    CREATE TABLE reparaciones (
      id INTEGER PRIMARY KEY,
      id_coche INTEGER,
      descripcion TEXT,
      fecha_inicio TEXT,
      fecha_fin TEXT,
      coste REAL,
      rutas_fotos TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE fotos (
      id INTEGER PRIMARY KEY,
      id_alquiler INTEGER,
      ruta TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE multas (
      id INTEGER PRIMARY KEY,
      id_alquiler INTEGER,
      descripcion TEXT,
      fecha TEXT,
      fecha_limite TEXT,
      precio REAL,
      pagada INTEGER
    )
    ''');
  }

  // ========================
  // 👤 CLIENTES
  // ========================

  Future<int> insertarCliente(Cliente cliente) async {
    final db = await instance.database;
    return await db.insert("clientes", cliente.toMap());
  }

  Future<List<Cliente>> obtenerClientes() async {
    final db = await instance.database;
    final result = await db.query("clientes");
    return result.map((e) => Cliente.fromMap(e)).toList();
  }

  Future<Cliente?> obtenerClientePorId(int id) async {
    final db = await instance.database;
    final result = await db.query("clientes", where: "id = ?", whereArgs: [id]);

    return result.isNotEmpty ? Cliente.fromMap(result.first) : null;
  }

  Future<int> actualizarCliente(Cliente cliente) async {
    final db = await instance.database;
    return await db.update("clientes", cliente.toMap(), where: "id = ?", whereArgs: [cliente.id]);
  }

  Future<int> borrarCliente(int id) async {
    final db = await instance.database;
    await db.delete("alquileres", where: "id_cliente = ?", whereArgs: [id]);
    return await db.delete("clientes", where: "id = ?", whereArgs: [id]);
  }

  // ========================
  // 🚗 VEHICULOS
  // ========================

  Future<int> insertarVehiculo(Vehiculo v) async {
    final db = await instance.database;
    return await db.insert("vehiculos", v.toMap());
  }

  Future<Vehiculo?> obtenerVehiculoPorId(int id) async {
    final db = await instance.database;
    final result = await db.query("vehiculos", where: "id = ?", whereArgs: [id]);

    return result.isNotEmpty ? Vehiculo.fromMap(result.first) : null;
  }

  Future<List<Vehiculo>> obtenerVehiculos() async {
    final db = await instance.database;
    final result = await db.query("vehiculos");
    return result.map((e) => Vehiculo.fromMap(e)).toList();
  }

  Future<List<Vehiculo>> obtenerVehiculosDisponibles() async {
    final db = await instance.database;
    final result = await db.query("vehiculos", where: "estado = ?", whereArgs: ["Disponible"]);
    return result.map((e) => Vehiculo.fromMap(e)).toList();
  }

  Future<int> borrarVehiculo(int id) async {
    final db = await instance.database;
    await db.delete("reparaciones", where: "id_coche = ?", whereArgs: [id]);
    await db.delete("alquileres", where: "id_coche = ?", whereArgs: [id]);
    return await db.delete("vehiculos", where: "id = ?", whereArgs: [id]);
  }

  Future<int> actualizarCampoVehiculo(int id, String campo, dynamic valor) async {
    final db = await instance.database;
    return await db.update("vehiculos", {campo: valor}, where: "id = ?", whereArgs: [id]);
  }

  Future<bool> cocheEstaDisponible(int idVehiculo, String inicio, String fin) async {
    final db = await instance.database;

    // 🔴 1. Comprobar alquileres que se solapen
    final alquileresOcupados = await db.query(
      "alquileres",
      where: '''
      id_coche = ? 
      AND estado != ? 
      AND ? <= fecha_fin 
      AND ? >= fecha_inicio
    ''',
      whereArgs: [idVehiculo, "Terminado", inicio, fin],
    );

    if (alquileresOcupados.isNotEmpty) return false;

    // 🔴 2. Comprobar reparaciones (taller)
    final reparacionesOcupadas = await db.query(
      "reparaciones",
      where: '''
      id_coche = ? 
      AND ? <= fecha_fin 
      AND ? >= fecha_inicio
    ''',
      whereArgs: [idVehiculo, inicio, fin],
    );

    return reparacionesOcupadas.isEmpty;
  }

  // ========================
  // 📄 ALQUILERES
  // ========================

  Future<int> insertarAlquiler(Alquiler a) async {
    final db = await instance.database;
    return await db.insert("alquileres", a.toMap());
  }

  Future<List<Alquiler>> obtenerAlquileres() async {
    final db = await instance.database;
    final result = await db.query("alquileres");
    return result.map((e) => Alquiler.fromMap(e)).toList();
  }

  Future<int> borrarAlquiler(int id) async {
    final db = await instance.database;

    final alquiler = await db.query(
      "alquileres",
      where: "id = ?",
      whereArgs: [id],
    );

    if (alquiler.isNotEmpty) {
      final idCoche = alquiler.first["id_coche"];

      // Obtener el estado actual del vehículo
      final vehiculo = await db.query(
        "vehiculos",
        where: "id = ?",
        whereArgs: [idCoche],
      );

      String? estadoActual;
      if (vehiculo.isNotEmpty) {
        estadoActual = vehiculo.first["estado"] as String?;
      }

      // Borrar alquiler
      await db.delete(
        "alquileres",
        where: "id = ?",
        whereArgs: [id],
      );

      // Solo cambiar a Disponible si NO estaba en Taller
      if (estadoActual != "Taller") {
        await db.update(
          "vehiculos",
          {"estado": "Disponible"},
          where: "id = ?",
          whereArgs: [idCoche],
        );
      }
    }

    return 1;
  }

  Future<Alquiler?> obtenerAlquilerPorId(int id) async {
    final db = await instance.database;

    final result = await db.query("alquileres", where: "id = ?", whereArgs: [id]);

    if (result.isNotEmpty) {
      return Alquiler.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerAlquileresConDetalles({DateTime? fechaInicio, DateTime? fechaFin}) async {
    final db = await instance.database;

    String query = '''
    SELECT alquileres.*, 
           vehiculos.matricula, vehiculos.marca, vehiculos.modelo,
           clientes.nombre, clientes.documento_oficial
    FROM alquileres
    INNER JOIN vehiculos ON alquileres.id_coche = vehiculos.id
    INNER JOIN clientes ON alquileres.id_cliente = clientes.id
  ''';

    List<dynamic> args = [];

    if (fechaInicio != null && fechaFin != null) {
      query += " WHERE fecha_inicio BETWEEN ? AND ?";
      args.add(fechaInicio.toIso8601String().split('T')[0]);
      args.add(fechaFin.toIso8601String().split('T')[0]);
    }

    return await db.rawQuery(query, args);
  }

  Future<List<Alquiler>> obtenerAlquileresOcupados({
    required int idVehiculo,
    required String fechaInicio,
    required String fechaFin,
  }) async {
    final db = await instance.database;

    String whereClause = "id_coche = ? AND estado != ? AND ? <= fecha_fin AND ? >= fecha_inicio";
    List<dynamic> args = [idVehiculo, "Terminado", fechaInicio, fechaFin];

    final result = await db.query("alquileres", where: whereClause, whereArgs: args);
    return result.map((e) => Alquiler.fromMap(e)).toList();
  }

  Future<int> actualizarCampoAlquiler(int id, String campo, dynamic valor) async {
    final db = await instance.database;
    return await db.update("alquileres", {campo: valor}, where: "id = ?", whereArgs: [id]);
  }

  // ========================
  // 🔧 REPARACIONES
  // ========================

  Future<int> insertarReparacion(Reparacion reparacion) async {
    final db = await instance.database;
    return await db.insert("reparaciones", reparacion.toMap());
  }

  Future<List<Reparacion>> obtenerReparacionesPorVehiculo(int idVehiculo) async {
    final db = await instance.database;
    final result = await db.query("reparaciones", where: "id_coche = ?", whereArgs: [idVehiculo]);
    return result.map((e) => Reparacion.fromMap(e)).toList();
  }

  Future<Reparacion?> obtenerReparacionPorId(int idReparacion) async {
    final db = await instance.database;
    final result = await db.query("reparaciones", where: "id = ?", whereArgs: [idReparacion]);
    return result.isNotEmpty ? Reparacion.fromMap(result.first) : null;
  }

  Future<List<Reparacion>> obtenerReparacionesOcupadas({
    required int idVehiculo,
    required String fechaInicio,
    required String fechaFin,
  }) async {
    final db = await instance.database;
    final result = await db.query(
      "reparaciones",
      where: "id_coche = ? AND ? <= fecha_fin AND ? >= fecha_inicio",
      whereArgs: [idVehiculo, fechaInicio, fechaFin],
    );
    return result.map((e) => Reparacion.fromMap(e)).toList();
  }

  Future<int> actualizarCampoReparacion(int id, String campo, dynamic valor) async {
    final db = await instance.database;
    return await db.update("reparaciones", {campo: valor}, where: "id = ?", whereArgs: [id]);
  }

  // ========================
  // 📸 FOTOS
  // ========================

  Future<List<Foto>> obtenerFotosPorAlquiler(int idAlquiler) async {
    final db = await instance.database;
    final result = await db.query("fotos", where: "id_alquiler = ?", whereArgs: [idAlquiler]);
    return result.map((e) => Foto.fromMap(e)).toList();
  }

  Future<int> insertarFoto(int idAlquiler, String imagen) async {
    final db = await instance.database;
    return await db.insert("fotos", {"id_alquiler": idAlquiler, "ruta": imagen});
  }

  Future<int> borrarFoto(Foto foto) async {
    final db = await instance.database;
    return await db.delete("fotos", where: "id = ?", whereArgs: [foto.id]);
  }

  // ========================
  // 🚨 MULTAS
  // ========================

  Future<int> insertarMulta(Multa multa) async {
    final db = await instance.database;
    return await db.insert("multas", multa.toMap());
  }

  Future<int> borrarMulta(Multa multa) async {
    final db = await instance.database;
    return await db.delete("multas", where: "id = ?", whereArgs: [multa.id]);
  }

  Future<int> actualizarCampoMulta(int id, String campo, dynamic valor) async {
    final db = await instance.database;
    return await db.update("multas", {campo: valor}, where: "id = ?", whereArgs: [id]);
  }

  Future<List<Multa>> obtenerMultasPorAlquiler(int idAlquiler) async {
    final db = await instance.database;
    final result = await db.query("multas", where: "id_alquiler = ?", whereArgs: [idAlquiler]);
    return result.map((e) => Multa.fromMap(e)).toList();
  }

  Future<Multa?> obtenerMultaPorId(int idMulta) async {
    final db = await instance.database;
    final result = await db.query("multas", where: "id = ?", whereArgs: [idMulta]);
    return result.isNotEmpty ? Multa.fromMap(result.first) : null;
  }

  // ========================
  // Operaciones
  // ========================

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
      final db = await instance.database;
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
      final db = await instance.database;

      await db.delete("vehiculos");
      await db.delete("reparaciones");
      await db.delete("clientes");
      await db.delete("alquileres");
      await db.delete("fotos");
    } catch (e) {
      print("Error al borrar los registros de la base de datos");
    }
  }

  static Future<Map<String, double>> obtenerContabilidadPorFechas(String inicio, String fin) async {
    final db = await instance.database;

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
    final db = await instance.database;

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
}
