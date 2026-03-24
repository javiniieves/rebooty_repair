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

                  // Filtrado por Matrícula según lo escrito en el TextField (corregido)
                  final filtro = _idController.text.toLowerCase();
                  final alquileresFiltrados = snapshot.data!.where((alquiler) {
                    final mat = alquiler['matricula']?.toString().toLowerCase() ?? '';
                    return mat.contains(filtro);
                  }).toList();

                  return Row(
                    children: [
                      // a la izquierda la lista con todos los alquileres encontrado
                      Expanded(
                        flex: 2,
                        child: ListView.separated(
                          separatorBuilder: (context, index) => const Divider(),
                          itemCount: alquileresFiltrados.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> alquiler = alquileresFiltrados[index];

                            return ListTile(
                              // en leading no podemos usar la imagen del coche directamente
                              // tenemos que usar future ya que necesiamos usar un metodo que llama a la base de datos
                              leading: FutureBuilder<String?>(
                                future: obtenerImagenVehiculo(alquiler['id_coche']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    );
                                  }
                                  if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                                    return const Icon(Icons.directions_car, size: 50);
                                  }
                                  return Image.file(File(snapshot.data!), width: 50, height: 50, fit: BoxFit.cover);
                                },
                              ),
                              // Matrícula y Fechas en el centro como Fila
                              title: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      alquiler['matricula'] ?? 'Sin coche',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "${alquiler['fecha_inicio']} / ${alquiler['fecha_fin']}",
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(alquiler['estado'] ?? 'Sin estado'),
                              onTap: () async {
                                await Navigator.pushNamed(context, "detalles_alquiler", arguments: alquiler["id"]);
                                setState(() {});
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                          "¿Estás seguro de que quieres borrar este alquiler de la base de datos?",
                                        ),

                                        content: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () async {
                                                await DatabaseHelper.instance.borrarAlquiler(alquiler['id']);
                                                setState(() {});
                                                Navigator.pop(context);
                                              },
                                              label: const Row(children: [Icon(Icons.check), Text("Confirmar")]),
                                            ),

                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              label: const Row(
                                                children: [Icon(Icons.cancel_outlined), Text("Cancelar")],
                                              ),
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
                        ),
                      ),

                      const SizedBox(width: 10),

                      // a la derecha los avisos de los alquileres
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Alquileres a recibir mañana"),
                            const SizedBox(height: 4),
                            listaAlquileresADevolver(false),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Alquileres pendientes a recibir"),
                            const SizedBox(height: 4),
                            listaAlquileresADevolver(true),
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

  Expanded listaAlquileresADevolver(bool pendiente) {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: alquileresARecibirPronto(pendiente),
        builder: (context, snapshotAlquileresARecibirPronto) {
          if (!snapshotAlquileresARecibirPronto.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final listaAlquileresARecibirPronto = snapshotAlquileresARecibirPronto.data!;

          return ListView.builder(
            itemCount: listaAlquileresARecibirPronto.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> alquilerActual = listaAlquileresARecibirPronto[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "detalles_alquiler", arguments: alquilerActual["id"]);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                alquilerActual['matricula'] ?? '---',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  pendiente ? "PENDIENTE" : "MAÑANA",
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        // Información del coche
                        Row(
                          children: [
                            const Icon(Icons.directions_car_filled, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              "${alquilerActual['marca']} ${alquilerActual['modelo']}",
                              style: const TextStyle(fontSize: 13, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Información del cliente
                        Row(
                          children: [
                            const Icon(Icons.person, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${alquilerActual['nombre']} (${alquilerActual['documento_oficial']})",
                                style: const TextStyle(fontSize: 12, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Fecha de devolucion (${alquilerActual['fecha_fin']})",
                                style: const TextStyle(fontSize: 12, color: Colors.white),
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
        },
      ),
    );
  }

  // metodo encargado de mediante un id de un vehiculo sacar su imagen de la base de datos
  Future<String?> obtenerImagenVehiculo(int idVehiculo) async {
    final Vehiculo? vehiculo = await DatabaseHelper.instance.obtenerVehiculoPorId(idVehiculo);
    return vehiculo?.rutaFoto;
  }

  Future<List<Map<String, dynamic>>> alquileresARecibirPronto(bool pendientes) async {
    // Cargamos todos los alquileres
    List<Map<String, dynamic>> todosLosAlquileres = await cargarAlquileres();

    // Obtenemos la fecha de hoy sin horas para comparar solo días
    DateTime fechaHoy = DateTime.now();
    DateTime fechaManyana = DateTime(fechaHoy.year, fechaHoy.month, fechaHoy.day + 1);

    List<Map<String, dynamic>> alquileresFiltrados;

    // Filtramos la lista de alquileres para dejar solo los de que tienen que devolver mañana
    if (!pendientes) {
      alquileresFiltrados = todosLosAlquileres.where((alquiler) {
        // Convertimos el String "YYYY-MM-DD" de la base de datos a DateTime
        DateTime fechaFin = DateTime.parse(alquiler["fecha_fin"]);

        // Comparamos si es el mismo año, mes y día que mañana
        return fechaFin.year == fechaManyana.year &&
            fechaFin.month == fechaManyana.month &&
            fechaFin.day == fechaManyana.day;
      }).toList();
    } else {
      alquileresFiltrados = todosLosAlquileres.where((alquiler) {
        DateTime fechaFin = DateTime.parse(alquiler["fecha_fin"]);
        String estado = (alquiler["estado"] ?? "").toLowerCase();

        return fechaFin.isBefore(fechaHoy) && estado != "terminado";
      }).toList();
    }

    return alquileresFiltrados;
  }
}
