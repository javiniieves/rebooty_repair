import 'package:flutter/material.dart';
import 'package:rebooty_repair/database.dart';

class DetallesAlquilerScreen extends StatefulWidget {
  const DetallesAlquilerScreen({super.key});

  @override
  State<DetallesAlquilerScreen> createState() => _DetallesAlquilerScreenState();
}

class _DetallesAlquilerScreenState extends State<DetallesAlquilerScreen> {
  Map<String, dynamic> alquiler = {};

  TextEditingController _fechaInicioControler = TextEditingController();
  TextEditingController _fechaLimiteControler = TextEditingController();
  String _estadoActual = "";

  Future<void> cargarAlquiler(int idAlquiler) async {
    // guardamos el alquiler con el id recibido
    final alquileresConIdRecibido = await DatabaseHelper.obtenerAlquilerPorId(idAlquiler);

    setState(() {
      alquiler = alquileresConIdRecibido.first;
    });

    // rellenamos los controladores con los campos del alquiler que acabamos de guardar
    _fechaInicioControler = TextEditingController(text: alquiler['fecha_inicio']);
    _fechaLimiteControler = TextEditingController(text: alquiler['fecha_fin']);
    _estadoActual = alquiler['estado'];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    int idAlquiler = ModalRoute.of(context)?.settings.arguments as int;

    cargarAlquiler(idAlquiler);
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text("Detalles del Alquiler", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),

              // Card con información de los campos del alquiler
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 180),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    child: Column(
                      children: [
                        // fecha inicio
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.date_range, "Fecha de inicio", _fechaInicioControler)),

                            IconButton(
                              onPressed: () {
                                _ventanaCambioFecha("fecha_inicio", _fechaInicioControler);
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),

                        const Divider(),

                        // fecha límite
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.date_range_outlined, "Fecha limite", _fechaLimiteControler)),

                            IconButton(
                              onPressed: () {
                                _ventanaCambioFecha("fecha_fin", _fechaLimiteControler);
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),

                        const Divider(),

                        // estado de la devolución
                        Row(
                          children: [
                            Expanded(child: _infoRowEstado(Icons.directions_car, "Estado de la devolucion", _estadoActual)),

                            IconButton(
                              onPressed: () {
                                showDialog(context: context, builder: (context) => _ventanaCambioEstado("estado", _estadoActual),);
                              },
                              icon: Icon(Icons.edit),
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

  Widget _infoRow(IconData icon, String titulo, TextEditingController controller) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 15),
        Expanded(child: Text("$titulo: ${controller.text}", style: const TextStyle(fontSize: 17))),
      ],
    );
  }

  Widget _infoRowEstado(IconData icon, String titulo, String estado) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 15),
        Expanded(child: Text("$titulo: $estado", style: const TextStyle(fontSize: 17))),
      ],
    );
  }

  Future<void> _ventanaCambioFecha(String nombreCampo, TextEditingController controllerFecha) async {
    DateTime fechaHoy = DateTime.now();

    // dejamos que el usuario elija la fecha y la guardamos esa fecha
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      // el día en el que se abrirá el calendario
      // si no ha escogido fecha de inicio es el dia de hoy
      // si ya la ha elegido (es porque va a rellenar la fecha de fin)
      // por lo que mostramos es calendario a partir de la fecha de inicio
      initialDate: fechaHoy,
      firstDate: DateTime(2024),
      // limite es dentro de 5 años
      lastDate: fechaHoy.add(const Duration(days: 365 * 5)),
    );
    if (fechaElegida != null) {
        // Guardamos la fecha y la formateamos para el texto (Año-Mes-Día)
        String fechaFormateada = "${fechaElegida.year}-${fechaElegida.month.toString().padLeft(2, '0')}-${fechaElegida.day.toString().padLeft(2, '0')}";

        final baseDatos = await DatabaseHelper.proyectodb();

        // cambiamos la fecha (inicio o fin) del alquiler del que estamos mostrando los detalles
        await baseDatos.update("alquileres", {nombreCampo: fechaFormateada}, where: "id = ?", whereArgs: [alquiler["id"]]);
    }
  }

  Widget _ventanaCambioEstado(String campoACambiar, String estadoActual) {
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),

            // el desplegable tiene 3 estado a elegir
            // cada uno de esos estados lo mapeamos para crearlo como DropdownMenuItem
            // su valor y es el mismo que su texto (ej: "Pendiente", "Terminado"...)
            items: ["Pendiente", "En proceso", "Terminado"].map((estadoActual) {
              return DropdownMenuItem(value: estadoActual, child: Text(estadoActual));
            }).toList(),
            // convertimos a lista porque items nos pide la lista con los valores del DropdownButtonFormField

            // al pulsar en uno de los desplegables del menú, actualizamos la variable con
            // el estado actual del coche para que sea ahora el valor del desplegable pulsado
            onChanged: (nuevoEstado) async {
              final baseDatos = await DatabaseHelper.proyectodb();

              // cambiamos el estado del alquiler del que estamos mostrando los detalles
              await baseDatos.update("alquileres", {"estado": nuevoEstado}, where: "id = ?", whereArgs: [alquiler["id"]]);

              setState(() {
                estadoActual = nuevoEstado!;
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
    );
  }
}
