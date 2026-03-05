import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Future<Database> proyectodb() async {
    final ruta = await getDatabasesPath();

    final path = join(ruta, "alquileres.db");

    print("Ruta base de datos: $path");

    return openDatabase(path, version: 1, onCreate: (db, version) async {

      // tabla vehículos
      await db.execute("CREATE TABLE vehiculos (id INTEGER PRIMARY KEY, matricula TEXT, marca TEXT, modelo TEXT, estado TEXT)");

      // tabla reparaciones (se relacione con coche)
      await db.execute("CREATE TABLE reparaciones (id INTEGER PRIMARY KEY, id_coche INTEGER, descripcion TEXT, fecha_inicio TEXT, fecha_fin TEXT, coste REAL)");

      // Tabla de los Clientes (se relaciona con coche mediante la tabla Alquileres)
      await db.execute("CREATE TABLE clientes (id INTEGER PRIMARY KEY, nombre TEXT, dni TEXT, telefono TEXT)");

      // Tabla de los Alquileres (La que une coche y cliente)
      await db.execute("CREATE TABLE alquileres (id INTEGER PRIMARY KEY, id_coche INTEGER, id_cliente INTEGER, fecha_inicio TEXT, fecha_fin TEXT, fecha_devolucion TEXT, estado TEXT)");

      // tabla fotos (se relaciona con alquileres)
      await db.execute("CREATE TABLE fotos (id INTEGER PRIMARY KEY, id_alquiler INTEGER, ruta TEXT)");
    });
  }
}
