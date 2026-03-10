import 'package:flutter/material.dart';
import '../../database.dart';

class PantallaMultas extends StatefulWidget {
  const PantallaMultas({super.key});

  @override
  State<PantallaMultas> createState() => _PantallaMultasState();
}

class _PantallaMultasState extends State<PantallaMultas> {
  DateTime? fechaInicio;
  DateTime? fechaFin;

  Future<List<Map<String, dynamic>>> cargarAlquileres() async {
    final db = await DatabaseHelper.proyectodb();
    String query = '''
    SELECT alquileres.*, vehiculos.matricula
    FROM alquileres
    INNER JOIN vehiculos
    ON alquileres.id_coche = vehiculos.id
    ''';

    List<dynamic> args = [];

    if (fechaInicio != null && fechaFin != null) {
      query += " WHERE fecha_inicio BETWEEN ? AND ?";
      args.add(fechaInicio!.toIso8601String().split('T')[0]);
      args.add(fechaFin!.toIso8601String().split('T')[0]);
    }
    return await db.rawQuery(query, args);
  }

  Future<void> seleccionarFecha(bool esInicio) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (esInicio) {
        fechaInicio = picked;
      } else {
        fechaFin = picked;
      }
    });
  }

  String formatearFecha(DateTime? fecha) {
    if (fecha == null) return "Seleccionar fecha";

    return fecha.toIso8601String().split('T')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Listado de Alquileres"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => seleccionarFecha(true),
                    child: Text(fechaInicio == null ? "Fecha inicio" : formatearFecha(fechaInicio)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () => seleccionarFecha(false),
                    child: Text(fechaFin == null ? "Fecha fin" : formatearFecha(fechaFin)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: _listaAlquileres()),
          ],
        ),
      ),
    );
  }

  Widget _listaAlquileres() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: cargarAlquileres(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final data = snapshot.data;

        if (data == null || data.isEmpty) {
          return const Center(child: Text("No hay registros"));
        }

        return ListView.separated(
          itemCount: data.length,
          separatorBuilder: (_, __) => const Divider(),

          itemBuilder: (context, index) {
            final alquiler = data[index];

            return ListTile(
              leading: const Icon(Icons.directions_car),
              title: Text(alquiler["matricula"] ?? "Sin coche"),
              subtitle: Text(alquiler["estado"] ?? "Sin estado"),
              onTap: () async {
                await Navigator.pushNamed(context, "detalles_alquiler", arguments: alquiler["id"]);
                setState(() {});
              },
            );
          },
        );
      },
    );
  }
}
