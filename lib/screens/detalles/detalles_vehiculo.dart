import 'package:flutter/material.dart';
import 'package:rebooty_repair/database.dart';

class DetallesVehiculoScreen extends StatefulWidget {
  const DetallesVehiculoScreen({super.key});

  @override
  State<DetallesVehiculoScreen> createState() => _DetallesVehiculoScreenState();
}

class _DetallesVehiculoScreenState extends State<DetallesVehiculoScreen> {
  final _matriculaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();

  Map<String, dynamic>? vehiculo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    int idVehiculo = ModalRoute.of(context)?.settings.arguments as int;

    cargarDatosVehiculo(idVehiculo);
  }

  // metodo encargado de rellenar la variable vehiculo con
  // los datos del coche con el id recibido por parametro
  Future<void> cargarDatosVehiculo(int idVehiculo) async {
    final vehiculosConIdRecibido = await DatabaseHelper.obtenerVehiculoPorId(idVehiculo);

    setState(() {
      vehiculo = vehiculosConIdRecibido.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (vehiculo == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Detalles del Vehículo",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Avatar
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.deepPurple,
                child: Icon(
                  Icons.directions_car_filled,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 15),

              // informacion coche
              Text(
                "${vehiculo!['marca']} ${vehiculo!['modelo']}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // Card con información
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // información matrícula
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => _ventanaCambio(vehiculo!["id"], "matricula", _matriculaController),
                            );
                          },
                          child: _infoRow(Icons.badge, "Matrícula", vehiculo!['matricula']),
                        ),

                        const Divider(height: 30),

                        // información marca
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => _ventanaCambio(
                                vehiculo!["id"],
                                "marca",
                                _marcaController,
                              ),
                            );
                          },
                          child: _infoRow(
                            Icons.branding_watermark,
                            "Marca",
                            vehiculo!['marca'],
                          ),
                        ),

                        const Divider(height: 30),

                        // información modelo
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => _ventanaCambio(
                                vehiculo!["id"],
                                "modelo",
                                _modeloController,
                              ),
                            );
                          },
                          child: _infoRow(
                            Icons.model_training,
                            "Modelo",
                            vehiculo!['modelo'],
                          ),
                        ),

                        const Divider(height: 30),

                        // información estado
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => _ventanaCambioEstado(
                                vehiculo!["id"],
                                "Estado",
                                vehiculo!["estado"],
                              ),
                            );
                          },
                          child: _infoRow(Icons.model_training, "Estado", vehiculo!['estado']),
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

  Widget _infoRow(IconData icon, String titulo, String valor) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 26),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ventanaCambio(
    int idVehiculo,
    String campoACambiar,
    TextEditingController controllerCampoACambiar,
  ) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text("Actualizar $campoACambiar"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Introduce el nuevo valor para el campo:"),
          const SizedBox(height: 15),
          TextFormField(
            controller: controllerCampoACambiar,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: "Escribe aquí...",
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final baseDatos = await DatabaseHelper.proyectodb();

                // actualizamos en la tabla vehiculos
                // de el vehiculo que tenga el id del vehiculo actual
                // actualizamos el campo correspondiente
                await baseDatos.update(
                  "vehiculos",
                  {campoACambiar: controllerCampoACambiar.text},
                  where: "id = ?",
                  whereArgs: [idVehiculo],
                );

                controllerCampoACambiar.clear();
                Navigator.pop(context);
                cargarDatosVehiculo(idVehiculo);
              },
              child: const Text("GUARDAR CAMBIOS"),
            ),
          ),
        ],
      ),
    );
  }


  Widget _ventanaCambioEstado(int idVehiculo, String campoACambiar, String estadoActual) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text("Actualizar $campoACambiar"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Introduce el nuevo valor para el campo:"),
          const SizedBox(height: 15),
          DropdownButtonFormField(
            // el valor será la variable que indica el estado actual del coche
            value: estadoActual,

            decoration: InputDecoration(
              labelText: "Estado",
              prefixIcon: const Icon(Icons.info_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // el desplegable tiene 3 estado a elegir
            // cada uno de esos estados lo mapeamos para crearlo como DropdownMenuItem
            // su valor y es el mismo que su texto (ej: "Alquilado", "Taller"...)
            items: ["Disponible", "Alquilado", "Taller"].map((estadoActual) {
              return DropdownMenuItem(
                value: estadoActual,
                child: Text(estadoActual),
              );
            }).toList(), // convertimos a lista porque items nos pide la lista con los valores del DropdownButtonFormField

            // al pulsar en uno de los desplegables del menú, actualizamos la variable con
            // el estado actual del coche para que sea ahora el valor del desplegable pulsado
            onChanged: (nuevoEstado) async {
              final baseDatos = await DatabaseHelper.proyectodb();

              await baseDatos.update(
                "vehiculos", {"estado": nuevoEstado},
                where: "id = ?",
                whereArgs: [idVehiculo],
              );

              setState(() {
                estadoActual = nuevoEstado!;
                Navigator.pop(context);
                cargarDatosVehiculo(idVehiculo);
              });
            },
          ),
        ],
      ),
    );
  }
}
