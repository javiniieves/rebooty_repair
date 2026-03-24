import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rebooty_repair/models/Vehiculo.dart';
import '../../DataBaseHelper.dart';

class PantallaBusquedaVehiculo extends StatefulWidget {
  const PantallaBusquedaVehiculo({super.key});

  @override
  State<PantallaBusquedaVehiculo> createState() => _PantallaBusquedaVehiculoState();
}

class _PantallaBusquedaVehiculoState extends State<PantallaBusquedaVehiculo> {
  late TextEditingController _matriculaController;

  List<Vehiculo> listaVehiculos = [];

  Future<void> cargarVehiculos() async {
    final vehiculos = await DatabaseHelper.instance.obtenerVehiculos();
    setState(() {
      listaVehiculos = vehiculos;
    });
  }

  @override
  void initState() {
    super.initState();
    _matriculaController = TextEditingController();
    cargarVehiculos();
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
              child: Builder(
                builder: (context) {
                  final filtro = _matriculaController.text.toLowerCase();

                  final vehiculosFiltrados = listaVehiculos.where((vehiculo) {
                    return vehiculo.matricula.toLowerCase().startsWith(filtro);
                  }).toList();

                  final vehiculosParaLimpiar = vehiculosFiltrados.where((v) {
                    return v.necesitaLimpieza == 1;
                  }).toList();

                  final vehiculosEnTaller = vehiculosFiltrados.where((v) {
                    return v.estado == 'Taller';
                  }).toList();

                  if (vehiculosFiltrados.isEmpty) {
                    return const Center(child: Text("No hay Vehículos"));
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: ListView.separated(
                          separatorBuilder: (_, __) => const Divider(),
                          itemCount: vehiculosFiltrados.length,
                          itemBuilder: (context, index) {
                            final vehiculo = vehiculosFiltrados[index];

                            return ListTile(
                              leading: vehiculo.rutaFoto != null
                                  ? Image.file(File(vehiculo.rutaFoto!))
                                  : const Icon(Icons.car_rental),

                              title: Text("${vehiculo.matricula} - ${vehiculo.marca}/${vehiculo.modelo}"),

                              subtitle: Text(vehiculo.estado),

                              onTap: () async {
                                await Navigator.pushNamed(context, "detalles_vehiculo", arguments: vehiculo);
                                cargarVehiculos(); // refrescar
                              },

                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _confirmarBorrado(vehiculo.id!),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 15),

                      /// LIMPIEZA
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Vehículos a Limpiar"),
                            Expanded(
                              child: _construirListaAlertasVehiculo(vehiculosParaLimpiar, "¡LIMPIAR!", Colors.red),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// TALLER
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Vehículos en Taller"),
                            Expanded(
                              child: _construirListaAlertasVehiculo(vehiculosEnTaller, "EN TALLER", Colors.orange),
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

  Widget _construirListaAlertasVehiculo(List<Vehiculo> lista, String etiqueta, Color colorTema) {
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
              await Navigator.pushNamed(context, "detalles_vehiculo", arguments: vehiculo);
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
                      Text(vehiculo.matricula, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                          "${vehiculo.marca} ${vehiculo.modelo}",
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
                    await DatabaseHelper.instance.borrarVehiculo(id);
                    Navigator.pop(context);
                    await cargarVehiculos();
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
