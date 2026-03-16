import 'dart:io';
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
        title: const Text("Listado de Vehiculos"),
        centerTitle: true,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left_outlined)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Barra de búsqueda
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _matriculaController,
                    decoration: InputDecoration(
                      labelText: "Matricula",
                      prefixIcon: const Icon(Icons.car_rental),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: () => setState(() {}), child: const Text('Buscar')),
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

                  // Filtrado por matrícula según lo escrito en el TextField
                  final filtro = _matriculaController.text.toLowerCase();
                  final vehiculosFiltrados = snapshot.data!.where((vehiculo) {
                    final matricula = vehiculo['matricula']?.toString().toLowerCase() ?? '';
                    return matricula.startsWith(filtro);
                  }).toList();

                  // Filtramos solo los que necesitan limpieza para el panel derecho
                  final vehiculosParaLimpiar = vehiculosFiltrados.where((vehiculo) {
                    return vehiculo['necesita_limpieza'] == 1;
                  }).toList();

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LADO IZQUIERDO: listamos todos los coches que coinciden con la búsqueda
                      Expanded(
                        flex: 2,
                        child: ListView.separated(
                          separatorBuilder: (context, index) => const Divider(),
                          itemCount: vehiculosFiltrados.length,
                          itemBuilder: (context, index) {
                            final vehiculo = vehiculosFiltrados[index];
                            return ListTile(
                              leading: Image(image: FileImage(File(vehiculo["ruta_foto"]))),
                              title: Text(vehiculo['matricula'] ?? 'Sin matricula'),
                              subtitle: Text(vehiculo['estado'] ?? 'Sin estado'),
                              onTap: () async {
                                await Navigator.pushNamed(context, "detalles_vehiculo", arguments: vehiculo["id"]);
                                setState(() {});
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _confirmarBorrado(vehiculo["id"]),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      // LADO DERECHO:  mostramos los avisos de los vehiculos que necesitan limpieza
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            const Text(
                              "Vehículos a Limpiar",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: vehiculosParaLimpiar.isEmpty
                                  ? const Center(
                                      child: Text("Todo limpio", style: TextStyle(color: Colors.black)),
                                    )
                                  // si hay coches que limpiar los mostramos
                                  : ListView.builder(
                                      itemCount: vehiculosParaLimpiar.length,
                                      itemBuilder: (context, index) {
                                        final vehiculo = vehiculosParaLimpiar[index];

                                        return GestureDetector(
                                          onTap: () async {
                                            await Navigator.pushNamed(
                                              context,
                                              "detalles_vehiculo",
                                              arguments: vehiculo["id"],
                                            );
                                            // Al volver, ejecutamos setState para que
                                            // el FutureBuilder vuelva a llamar a cargarVehiculos()
                                            setState(() {});
                                          },

                                          child: Card(
                                            color: Colors.red.shade50,
                                            margin: const EdgeInsets.symmetric(vertical: 5),
                                            child: ListTile(
                                              dense: true,
                                              title: Text(
                                                vehiculo['matricula'],
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                              subtitle: const Text(
                                                "¡LIMPIAR!",
                                                style: TextStyle(color: Colors.red, fontSize: 11),
                                              ),
                                              trailing: const Icon(Icons.warning, color: Colors.red, size: 18),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarBorrado(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Estás seguro de que quieres borrar este vehículo de la base de datos?"),
        actions: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await DatabaseHelper.borrarVehiculo(id);
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text("Confirmar"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
