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

                  // Filtrado para alertas de limpieza
                  final vehiculosParaLimpiar = vehiculosFiltrados.where((vehiculo) {
                    return vehiculo['necesita_limpieza'] == 1;
                  }).toList();

                  // Filtrado para alertas de taller
                  final vehiculosEnTaller = vehiculosFiltrados.where((vehiculo) {
                    return vehiculo['estado'] == 'Taller';
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
                              title: Text(
                                "${vehiculo['matricula'] ?? 'Sin matricula'} - ${vehiculo['marca']}/${vehiculo['modelo']}",
                              ),
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
                      // LADO DERECHO: alertas de limpieza
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Vehículos a Limpiar",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            Expanded(child: _construirListaAlertas(vehiculosParaLimpiar, "¡LIMPIAR!", Colors.red)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // LADO DERECHO (EXTREMO): alertas de taller
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Vehículos en Taller",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            Expanded(child: _construirListaAlertas(vehiculosEnTaller, "EN TALLER", Colors.orange)),
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

  Widget _construirListaAlertas(List<Map<String, dynamic>> lista, String etiqueta, Color colorTema) {
    if (lista.isEmpty) {
      return const Center(child: Text("Sin avisos", style: TextStyle(fontSize: 12)));
    }
    return ListView.builder(
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final vehiculo = lista[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, "detalles_vehiculo", arguments: vehiculo["id"]);
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        vehiculo['matricula'] ?? '---',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorTema.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          etiqueta,
                          style: TextStyle(color: colorTema, fontWeight: FontWeight.bold, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Icon(Icons.directions_car, size: 16, color: colorTema),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          "${vehiculo['marca'] ?? ''} ${vehiculo['modelo'] ?? ''}",
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
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
