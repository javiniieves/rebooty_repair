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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_outlined),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding ajustado para móvil
        child: Column(
          children: [
            const SizedBox(height: 10),
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
                    onChanged: (value) => setState(() {}), // Búsqueda en tiempo real
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: () => setState(() {}), child: const Text('Buscar')),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
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

                  // Si el ancho es menor a 800px (Móvil), usamos scroll vertical único
                  if (constraints.maxWidth < 800) {
                    return ListView(
                      children: [
                        const Text("LISTADO GENERAL", style: TextStyle(fontWeight: FontWeight.bold)),
                        _buildListaPrincipal(vehiculosFiltrados, shrinkWrap: true),

                        if (vehiculosParaLimpiar.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text("VEHÍCULOS A LIMPIAR", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          _construirListaAlertasVehiculo(vehiculosParaLimpiar, "¡LIMPIAR!", Colors.red, true),
                        ],

                        if (vehiculosEnTaller.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text("VEHÍCULOS EN TALLER", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                          _construirListaAlertasVehiculo(vehiculosEnTaller, "EN TALLER", Colors.orange, true),
                        ],
                      ],
                    );
                  }

                  // Si es Windows/Pantalla ancha, mantenemos las columnas
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildListaPrincipal(vehiculosFiltrados),
                      ),
                      const SizedBox(width: 15),
                      /// LIMPIEZA
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Vehículos a Limpiar", style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: _construirListaAlertasVehiculo(vehiculosParaLimpiar, "¡LIMPIAR!", Colors.red, false),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      /// TALLER
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Vehículos en Taller", style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: _construirListaAlertasVehiculo(vehiculosEnTaller, "EN TALLER", Colors.orange, false),
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

  // Widget extraído para la lista principal para evitar duplicar código
  Widget _buildListaPrincipal(List<Vehiculo> filtrados, {bool shrinkWrap = false}) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const Divider(),
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final vehiculo = filtrados[index];
        return ListTile(
          leading: vehiculo.rutaFoto != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(File(vehiculo.rutaFoto!), width: 50, height: 50, fit: BoxFit.cover),
          )
              : const Icon(Icons.car_rental),
          title: Text("${vehiculo.matricula} - ${vehiculo.marca}/${vehiculo.modelo}"),
          subtitle: Text(vehiculo.estado),
          onTap: () async {
            await Navigator.pushNamed(context, "detalles_vehiculo", arguments: vehiculo);
            cargarVehiculos(); // refrescar
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _confirmarBorrado(vehiculo.id!),
          ),
        );
      },
    );
  }

  Widget _construirListaAlertasVehiculo(List<Vehiculo> lista, String etiqueta, Color colorTema, bool isMobile) {
    if (lista.isEmpty) {
      return const Center(child: Text("Sin avisos", style: TextStyle(fontSize: 12)));
    }
    return ListView.builder(
      shrinkWrap: isMobile,
      physics: isMobile ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
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
              cargarVehiculos();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await DatabaseHelper.instance.borrarVehiculo(id);
                  Navigator.pop(context);
                  await cargarVehiculos();
                },
                child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}