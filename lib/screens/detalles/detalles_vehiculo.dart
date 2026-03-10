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
  final _kilometrajeController = TextEditingController();
  final _anyoController = TextEditingController();
  final _observacionesController = TextEditingController();

  Map<String, dynamic>? vehiculo;
  List<Map<String, dynamic>>? listaReparaciones;

  late int idVehiculo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    idVehiculo = ModalRoute.of(context)?.settings.arguments as int;

    cargarDatosVehiculo();
    cargarHistoricoReparaciones();
  }

  Future<void> cargarDatosVehiculo() async {
    final datos = await DatabaseHelper.obtenerVehiculoPorId(idVehiculo);

    setState(() {
      vehiculo = datos.first;
    });
  }

  Future<void> cargarHistoricoReparaciones() async {
    final lista = await DatabaseHelper.obtenerReparacionesPorIdVehiculo(idVehiculo);

    setState(() {
      listaReparaciones = lista;
    });
  }

  Future<void> actualizarVehiculo(String campo, dynamic valor) async {
    final db = await DatabaseHelper.proyectodb();

    await db.update("vehiculos", {campo: valor}, where: "id = ?", whereArgs: [idVehiculo]);

    await cargarDatosVehiculo();
  }

  @override
  Widget build(BuildContext context) {
    if (vehiculo == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Detalles del Vehículo"), centerTitle: true),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [
                      filaEditable(
                        Icons.badge,
                        "Matrícula",
                        vehiculo!["matricula"],
                        () => mostrarDialogoTexto("matricula", _matriculaController, esMatricula: true),
                      ),

                      const Divider(),

                      filaEditable(
                        Icons.branding_watermark,
                        "Marca",
                        vehiculo!["marca"],
                        () => mostrarDialogoTexto("marca", _marcaController),
                      ),

                      const Divider(),

                      filaEditable(
                        Icons.model_training,
                        "Modelo",
                        vehiculo!["modelo"],
                        () => mostrarDialogoTexto("modelo", _modeloController),
                      ),

                      const Divider(),

                      filaEditable(
                        Icons.calendar_month,
                        "Año",
                        vehiculo!["anyo"].toString(),
                        () => mostrarDialogoTexto("anyo", _anyoController, soloNumeros: true),
                      ),

                      const Divider(),

                      filaEditable(
                        Icons.speed,
                        "Kilometraje",
                        "${vehiculo!["kilometraje"]} km",
                        () => mostrarDialogoTexto("kilometraje", _kilometrajeController, soloNumeros: true),
                      ),

                      const Divider(),

                      filaEditable(
                        Icons.local_gas_station,
                        "Combustible",
                        vehiculo!["combustible"],
                        () => mostrarDropdown("combustible", vehiculo!["combustible"], [
                          "Diesel",
                          "Gasoil",
                          "Eléctrico",
                          "Híbrido",
                        ]),
                      ),

                      const Divider(),

                      filaEditable(Icons.security, "Seguro", vehiculo!["fecha_vencimiento_seguro"], seleccionarFecha),

                      const Divider(),

                      filaEditable(
                        Icons.info_outline,
                        "Estado",
                        vehiculo!["estado"],
                        () => mostrarDropdown("estado", vehiculo!["estado"], ["Disponible", "Alquilado", "Taller"]),
                      ),

                      const Divider(),

                      filaEditable(
                        Icons.note,
                        "Observaciones",
                        vehiculo!["observaciones"] ?? "Sin observaciones",
                        () => mostrarDialogoTexto("observaciones", _observacionesController),
                      ),

                      const Divider(),

                      Row(
                        children: [
                          Icon(Icons.palette, color: Color(vehiculo!["color"])),

                          const SizedBox(width: 15),

                          const Expanded(
                            child: Text("Color del vehículo", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),

                          IconButton(icon: const Icon(Icons.edit), onPressed: mostrarSelectorColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                const Text("HISTORIAL DE REPARACIONES", style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    await Navigator.pushNamed(context, "añadir_reparacion", arguments: vehiculo?["id"]);
                    // Recargamos cuando volvemos
                    cargarHistoricoReparaciones();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Añadir"),
                ),
              ],
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 130,

              child: listaReparaciones == null || listaReparaciones!.isEmpty
                  ? const Center(child: Text("No hay reparaciones"))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: listaReparaciones!.length,
                      itemBuilder: (context, index) {
                        final r = listaReparaciones![index];
                        return Card(
                          margin: const EdgeInsets.all(10),

                          child: SizedBox(
                            width: 200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.history),
                                Text("${r["fecha_inicio"]} / ${r["fecha_fin"]}"),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, "detalles_reparacion", arguments: r["id"]);
                                  },
                                  child: const Text("Ver detalles"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget filaEditable(IconData icono, String titulo, String valor, VoidCallback onEdit) {
    return Row(
      children: [
        Icon(icono),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo),
              Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
      ],
    );
  }

  void mostrarDialogoTexto(
    String campo,
    TextEditingController controller, {
    bool soloNumeros = false,
    bool esMatricula = false,
  }) {
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Actualizar $campo"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                keyboardType: soloNumeros ? TextInputType.number : TextInputType.text,
                textCapitalization: esMatricula ? TextCapitalization.characters : TextCapitalization.none,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Campo obligatorio";
                  }
                  if (soloNumeros && !RegExp(r'^\d+$').hasMatch(value)) {
                    return "Solo números";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await actualizarVehiculo(campo, controller.text);
                    controller.clear();
                    Navigator.pop(context);
                  }
                },
                child: const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void mostrarDropdown(String campo, String valorActual, List<String> opciones) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Actualizar $campo"),
        content: DropdownButtonFormField(
          value: valorActual,
          items: opciones.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (nuevo) async {
            await actualizarVehiculo(campo, nuevo);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (fecha == null) return;

    String fechaFormateada =
        "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";

    await actualizarVehiculo("fecha_vencimiento_seguro", fechaFormateada);
  }

  void mostrarSelectorColor() {
    List<Color> colores = [
      Colors.white,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.yellow,
      Colors.pink,
      Colors.black,
      Colors.grey,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selecciona un color"),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colores.map((c) {
            return GestureDetector(
              onTap: () async {
                await actualizarVehiculo("color", c.value);
                Navigator.pop(context);
              },
              child: CircleAvatar(backgroundColor: c),
            );
          }).toList(),
        ),
      ),
    );
  }
}
