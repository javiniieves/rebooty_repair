import 'package:flutter/material.dart';

import '../../database.dart';

class PantallaBusquedaAlquiler extends StatefulWidget {
  const PantallaBusquedaAlquiler({super.key});

  @override
  State<PantallaBusquedaAlquiler> createState() => _PantallaBusquedaAlquilerState();
}

class _PantallaBusquedaAlquilerState extends State<PantallaBusquedaAlquiler> {
  late TextEditingController _idController;
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
  void initState() {
    super.initState();
    _idController = TextEditingController();
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de Alquileres"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left_outlined),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: "Matricula",
                      prefixIcon: const Icon(Icons.car_rental),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Buscar'),
                ),
              ],
            ),

            const SizedBox(height: 30),

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

            const SizedBox(height: 30),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: cargarAlquileres(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No hay registros"));
                  }

                  // Filtrado por DNI según lo escrito en el TextField
                  final filtro = _idController.text.toLowerCase();
                  final alquileresFiltrados = snapshot.data!.where((alquiler) {
                    final id = alquiler['id']?.toString().toLowerCase() ?? '';
                    return id.startsWith(filtro);
                  }).toList();

                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: alquileresFiltrados.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic>? alquiler = alquileresFiltrados[index];
                      return ListTile(
                        leading: const Icon(Icons.directions_car_filled),
                        title: Text(alquiler['matricula'] ?? 'Sin coche'),
                        subtitle: Text(alquiler['estado'] ?? 'Sin estado'),
                        onTap: () async {
                          await Navigator.pushNamed(context, "detalles_alquiler", arguments: alquiler?["id"]);
                          setState(() {});
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("¿Estás seguro de que quieres borrar este campo de la base de datos?"),

                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await DatabaseHelper.borrarAlquiler(alquiler?["id"]);
                                          setState(() {
                                            alquiler = null;
                                          });

                                          Navigator.pop(context);
                                        },
                                        label: Row(children: [Icon(Icons.check), Text("Confirmar")]),
                                      ),

                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        label: Row(children: [Icon(Icons.cancel_outlined), Text("Cancelar")]),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
