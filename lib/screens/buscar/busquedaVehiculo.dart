import 'package:flutter/material.dart';

import '../../database.dart';

class PantallaBusquedaVehiculo extends StatefulWidget {
  const PantallaBusquedaVehiculo({super.key});

  @override
  State<PantallaBusquedaVehiculo> createState() => _PantallaBusquedaVehiculoState();
}

class _PantallaBusquedaVehiculoState extends State<PantallaBusquedaVehiculo> {
  late TextEditingController _matriculaController;

  Future<List<Map<String, dynamic>>> cargarVehiculos() async {
    final baseDatos = await DatabaseHelper.proyectodb();

    final List<Map<String, dynamic>> vehiculos = await baseDatos.query("vehiculos");
    return vehiculos;
  }

  @override
  void initState() {
    super.initState();
    _matriculaController = TextEditingController();
  }

  @override
  void dispose() {
    _matriculaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de vehiculos"),
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
                    controller: _matriculaController,
                    decoration: InputDecoration(
                      labelText: "Matricula",
                      prefixIcon: const Icon(Icons.car_rental),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: cargarVehiculos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No hay Vehiculos"));
                  }

                  // Filtrado por DNI según lo escrito en el TextField
                  final filtro = _matriculaController.text.toLowerCase();
                  final vehiculosFiltrados = snapshot.data!.where((vehiculo) {
                    final matricula = vehiculo['matricula']?.toString().toLowerCase() ?? '';
                    return matricula.startsWith(filtro);
                  }).toList();

                  // listamos los coches que empiezan con lo escrito
                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: vehiculosFiltrados.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic>? vehiculo = vehiculosFiltrados[index];
                      return ListTile(
                        leading: const Icon(Icons.directions_car_filled),
                        title: Text(vehiculo['matricula'] ?? 'Sin matricula'),
                        subtitle: Text(vehiculo['estado'] ?? 'Sin estado'),
                        onTap: () async {
                          await Navigator.pushNamed(context, "detalles_vehiculo", arguments: vehiculo?["id"]);
                          setState(() {});
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await DatabaseHelper.borrarVehiculo(vehiculo?["id"]);
                            setState(() {
                              vehiculo = null;
                            });
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