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
  late int idReparacion;
  late bool confirmar;

  final _descripcionController = TextEditingController();
  final _costeController = TextEditingController();

  // metodo encargado de rellenar la variable reparacion con
  // los datos de la reparacion con el id recibido por parametro
  Future<void> cargarDatosReparacion() async {
    final reparaciones = await DatabaseHelper.obtenerReparacionesPorId(idReparacion);
    reparacion = reparaciones.first;

    final vehiculos = await DatabaseHelper.obtenerVehiculoPorId(reparacion["id_coche"]);
    vehiculoReparado = vehiculos.first;

    setState(() {});
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
    idReparacion = ModalRoute.of(context)?.settings.arguments as int;
    cargarDatosReparacion();
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
        title: Text("Detalles de Reparación", style: TextStyle(fontWeight: FontWeight.bold)),
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
                        _filaEditable(
                          Icons.calendar_today,
                          "Fecha Inicio",
                          reparacion['fecha_inicio'],
                          () => _ventanaCambioFecha("fecha_inicio"),
                        ),

                        const Divider(),

                        _filaEditable(
                          Icons.event_available,
                          "Fecha Fin",
                          reparacion['fecha_fin'],
                          () => _ventanaCambioFecha("fecha_fin"),
                        ),

                        const Divider(),

                        _filaEditable(Icons.description, "Descripción", reparacion['descripcion'], () {
                          showDialog(
                            context: context,
                            builder: (_) => _ventanaCambio("descripcion", _descripcionController),
                          );
                        }),

                        const Divider(),

                        _filaEditable(Icons.monetization_on, "Coste", "${reparacion['coste']} €", () {
                          showDialog(context: context, builder: (_) => _ventanaCambio("coste", _costeController));
                        }),
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

  Widget _filaEditable(IconData icono, String titulo, String valor, VoidCallback onEdit) {
    return Row(
      children: [
        Expanded(child: _infoRow(icono, titulo, valor)),
        IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
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
                confirmar = await confirmacion();
                if (!confirmar) return Navigator.pop(context);

                await actualizarCampo(campoACambiar, controller.text);
                controller.clear();
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
  Future<void> _ventanaCambioFecha(String campo) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (fecha == null) return;

    String fechaFormateada =
        "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";

    await actualizarCampo(campo, fechaFormateada);
  }

  Future<void> actualizarCampo(String campo, dynamic valor) async {
    final db = await DatabaseHelper.proyectodb();
    await db.update("reparaciones", {campo: valor}, where: "id = ?", whereArgs: [idReparacion]);
    await cargarDatosReparacion();
  }

  Future<bool> confirmacion() async {
    confirmar =
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Confirmar cambio"),
              content: const Text("¿Seguro que quieres actualizar los datos?"),
              actions: [
                TextButton(
                  child: const Text("Cancelar"),
                  onPressed: () {Navigator.pop(context, false);},
                ),
                ElevatedButton(
                  child: const Text("Confirmar"),
                  onPressed: () {Navigator.pop(context, true);},
                ),
              ],
            );
          },
        ) ?? false;
    return confirmar;
  }
}
