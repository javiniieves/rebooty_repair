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
        title: const Text("Detalles de Reparación"),
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
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Fecha inicio
                        _infoRow(Icons.calendar_today, "Fecha de Inicio", reparacion['fecha_inicio']),
                        const Divider(height: 30),

                        // Fecha fin
                        _infoRow(Icons.event_available, "Fecha de Fin", reparacion['fecha_fin']),
                        const Divider(height: 30),

                        // Descripción de la avería
                        _infoRow(Icons.description, "Descripción", reparacion['descripcion']),
                        const Divider(height: 30),

                        // Coste de la reparación
                        _infoRow(Icons.monetization_on, "Coste Total", "${reparacion['coste']} €"),
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

  // Tu metodo infoRow para mantener la misma estética que en DetallesVehiculo
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
              Text(valor, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
