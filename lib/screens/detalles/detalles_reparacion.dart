import 'package:flutter/material.dart';
import '../../database.dart';

class DetallesReparacionScreen extends StatefulWidget {
  const DetallesReparacionScreen({super.key});

  @override
  State<DetallesReparacionScreen> createState() => _DetallesReparacionScreenState();
}

class _DetallesReparacionScreenState extends State<DetallesReparacionScreen> {
  Map<String, dynamic> vehiculoReparado = {};
  Map<String, dynamic> reparacion = {};

  final _descripcionController = TextEditingController();
  final _costeController = TextEditingController();

  // metodo encargado de rellenar la variable reparacion con
  // los datos de la reparacion con el id recibido por parametro
  Future<void> cargarDatosReparacion(int idReparacion) async {
    final reparacionesConIdRecibido = await DatabaseHelper.obtenerReparacionesPorId(idReparacion);

    setState(() {
      reparacion = reparacionesConIdRecibido.first;
    });

    // aprovechamos para cargar ya los datos del coche usando id_coche de la tabla reparaciones
    cargarDatosVehiculo(reparacion["id_coche"]);
  }

  // metodo encargado de rellenar la variable vehiculo con
  // los datos del coche con el id_coche de la repacion actual
  Future<void> cargarDatosVehiculo(int idVehiculo) async {
    final vehiculosConIdRecibido = await DatabaseHelper.obtenerVehiculoPorId(idVehiculo);

    setState(() {
      vehiculoReparado = vehiculosConIdRecibido.first;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    int idReparacion = ModalRoute.of(context)?.settings.arguments as int;
    cargarDatosReparacion(idReparacion);
  }

  @override
  Widget build(BuildContext context) {
    // Si la reparación o el vehículo aún no han cargado, mostramos el cargando para evitar errores de Null
    if (reparacion.isEmpty || vehiculoReparado.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
        title: const Text("Detalles de Reparación", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Icono y título del vehículo reparado
              const CircleAvatar(radius: 35, child: Icon(Icons.build_circle, size: 40)),
              const SizedBox(height: 15),
              Text(
                "${vehiculoReparado['marca']} ${vehiculoReparado['modelo']}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "Matrícula: ${vehiculoReparado['matricula']}",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 25),

              // Card con toda la información de la reparación
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Fecha inicio
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.calendar_today, "Fecha de Inicio", reparacion['fecha_inicio'])),
                            IconButton(
                              onPressed: () => _ventanaCambioFecha("fecha_inicio"),
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(height: 30),

                        // Fecha fin
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.event_available, "Fecha de Fin", reparacion['fecha_fin'])),
                            IconButton(
                              onPressed: () => _ventanaCambioFecha("fecha_fin"),
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(height: 30),

                        // Descripción de la avería
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.description, "Descripción", reparacion['descripcion'])),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => _ventanaCambio("descripcion", _descripcionController),
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(height: 30),

                        // Coste de la reparación
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.monetization_on, "Coste Total", "${reparacion['coste']} €")),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => _ventanaCambio("coste", _costeController),
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // información de los campos
  Widget _infoRow(IconData icon, String titulo, String valor) {
    return Row(
      children: [
        Icon(icon, size: 26),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 13)),
              Text(valor, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  // Ventana para cambiar texto (descripcion o coste)
  Widget _ventanaCambio(String campoACambiar, TextEditingController controller) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text("Actualizar $campoACambiar"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Introduce el nuevo valor:"),
          const SizedBox(height: 15),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: "Escribe aquí...",
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final baseDatos = await DatabaseHelper.proyectodb();
                await baseDatos.update(
                  "reparaciones",
                  {campoACambiar: controller.text},
                  where: "id = ?",
                  whereArgs: [reparacion["id"]],
                );
                controller.clear();
                cargarDatosReparacion(reparacion["id"]);
                Navigator.pop(context);
              },
              child: const Text("GUARDAR CAMBIOS"),
            ),
          ),
        ],
      ),
    );
  }

  // Funcion para cambiar las fechas con el calendario
  Future<void> _ventanaCambioFecha(String campoFecha) async {
    DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (fechaElegida != null) {
      String fechaFormateada = "${fechaElegida.year}-${fechaElegida.month.toString().padLeft(2, '0')}-${fechaElegida.day.toString().padLeft(2, '0')}";

      final baseDatos = await DatabaseHelper.proyectodb();
      await baseDatos.update(
        "reparaciones",
        {campoFecha: fechaFormateada},
        where: "id = ?",
        whereArgs: [reparacion["id"]],
      );
      cargarDatosReparacion(reparacion["id"]);
    }
  }
}