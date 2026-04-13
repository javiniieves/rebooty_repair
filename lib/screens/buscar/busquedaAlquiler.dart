import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rebooty_repair/models/Vehiculo.dart';
import '../../DataBaseHelper.dart';

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
    return await DatabaseHelper.instance.obtenerAlquileresConDetalles(fechaInicio: fechaInicio, fechaFin: fechaFin);
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_outlined),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Reducido para mejor ajuste en móvil
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Barra de búsqueda
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
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Buscar'),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => seleccionarFecha(true),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(fechaInicio == null ? "Inicio" : formatearFecha(fechaInicio)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => seleccionarFecha(false),
                    icon: const Icon(Icons.event, size: 16),
                    label: Text(fechaFin == null ? "Fin" : formatearFecha(fechaFin)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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

                  final filtro = _idController.text.toLowerCase();
                  final alquileresFiltrados = snapshot.data!.where((alquiler) {
                    final mat = alquiler['matricula']?.toString().toLowerCase() ?? '';
                    return mat.contains(filtro);
                  }).toList();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // MÓVIL (Ancho menor a 800)
                      if (constraints.maxWidth < 800) {
                        return ListView(
                          children: [
                            const Text("ALERTAS", style: TextStyle(fontWeight: FontWeight.bold)),
                            const Divider(),
                            _seccionAvisoMovil("Mañana", false),
                            _seccionAvisoMovil("Pendientes", true),
                            const SizedBox(height: 20),
                            const Text("LISTADO GENERAL", style: TextStyle(fontWeight: FontWeight.bold)),
                            const Divider(),
                            _buildListaPrincipal(alquileresFiltrados, shrinkWrap: true),
                          ],
                        );
                      }

                      // WINDOWS / DESKTOP (3 Columnas)
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildListaPrincipal(alquileresFiltrados)),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              children: [
                                const Text("Mañana", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                listaAlquileresADevolver(false),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              children: [
                                const Text("Pendientes", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                listaAlquileresADevolver(true),
                              ],
                            ),
                          ),
                        ],
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

  // Widget para mostrar avisos en el scroll de móvil
  Widget _seccionAvisoMovil(String titulo, bool pendiente) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: alquileresARecibirPronto(pendiente),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(titulo, style: TextStyle(color: pendiente ? Colors.orange : Colors.blue, fontWeight: FontWeight.bold)),
            ),
            _buildListaCards(snapshot.data!, pendiente, isMobile: true),
          ],
        );
      },
    );
  }

  Widget _buildListaPrincipal(List<Map<String, dynamic>> alquileres, {bool shrinkWrap = false}) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: alquileres.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> alquiler = alquileres[index];
        return ListTile(
          leading: FutureBuilder<String?>(
            future: obtenerImagenVehiculo(alquiler['id_coche']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(width: 50, height: 50);
              if (!snapshot.hasData || snapshot.data == null) return const Icon(Icons.directions_car, size: 50);
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(snapshot.data!), width: 50, height: 50, fit: BoxFit.cover),
              );
            },
          ),
          title: Text(alquiler['matricula'] ?? 'Sin coche', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${alquiler['fecha_inicio']} a ${alquiler['fecha_fin']}\nEstado: ${alquiler['estado']}"),
          isThreeLine: true,
          onTap: () async {
            await Navigator.pushNamed(context, "detalles_alquiler", arguments: alquiler["id"]);
            setState(() {});
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmarBorrado(alquiler['id']),
          ),
        );
      },
    );
  }

  Expanded listaAlquileresADevolver(bool pendiente) {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: alquileresARecibirPronto(pendiente),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return _buildListaCards(snapshot.data!, pendiente);
        },
      ),
    );
  }

  Widget _buildListaCards(List<Map<String, dynamic>> lista, bool pendiente, {bool isMobile = false}) {
    return ListView.builder(
      shrinkWrap: isMobile,
      physics: isMobile ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> alquilerActual = lista[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            title: Text(alquilerActual['matricula'] ?? '---', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${alquilerActual['marca']} ${alquilerActual['modelo']}\nDevolución: ${alquilerActual['fecha_fin']}"),
            trailing: Icon(Icons.warning_amber_rounded, color: pendiente ? Colors.orange : Colors.blue),
            onTap: () => Navigator.pushNamed(context, "detalles_alquiler", arguments: alquilerActual["id"]),
          ),
        );
      },
    );
  }

  void _confirmarBorrado(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Borrar este alquiler?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.borrarAlquiler(id);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  Future<String?> obtenerImagenVehiculo(int idVehiculo) async {
    final Vehiculo? vehiculo = await DatabaseHelper.instance.obtenerVehiculoPorId(idVehiculo);
    return vehiculo?.rutaFoto;
  }

  Future<List<Map<String, dynamic>>> alquileresARecibirPronto(bool pendientes) async {
    List<Map<String, dynamic>> todosLosAlquileres = await cargarAlquileres();
    DateTime fechaHoy = DateTime.now();
    DateTime hoySoloFecha = DateTime(fechaHoy.year, fechaHoy.month, fechaHoy.day);
    DateTime fechaManyana = DateTime(fechaHoy.year, fechaHoy.month, fechaHoy.day + 1);

    if (!pendientes) {
      return todosLosAlquileres.where((alquiler) {
        DateTime fechaFin = DateTime.parse(alquiler["fecha_fin"]);
        return fechaFin.year == fechaManyana.year && fechaFin.month == fechaManyana.month && fechaFin.day == fechaManyana.day;
      }).toList();
    } else {
      return todosLosAlquileres.where((alquiler) {
        DateTime fechaFin = DateTime.parse(alquiler["fecha_fin"]);
        String estado = (alquiler["estado"] ?? "").toLowerCase();
        return fechaFin.isBefore(hoySoloFecha) && estado != "terminado";
      }).toList();
    }
  }
}