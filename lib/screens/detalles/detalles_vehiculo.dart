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

  List<Map<String, dynamic>>? listaRepaciones;

  // metodo encargado de rellenar la variable vehiculo con
  // los datos del coche con el id recibido por parametro
  Future<void> cargarDatosVehiculo(int idVehiculo) async {
    final vehiculosConIdRecibido = await DatabaseHelper.obtenerVehiculoPorId(idVehiculo);

    setState(() {
      vehiculo = vehiculosConIdRecibido.first;
    });
  }

  // metodo encargado de rellenar la variable listaReparaciones con
  // los datos de las reparaciones del coche con el id recibido por parametro
  Future<void> cargarHistoriasReparaciones(int idVehiculo) async {
    final listaReparacionesDelVehiculo = await DatabaseHelper.obtenerReparacionesPorIdVehiculo(idVehiculo);

    setState(() {
      listaRepaciones = listaReparacionesDelVehiculo;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    int idVehiculo = ModalRoute.of(context)?.settings.arguments as int;

    cargarDatosVehiculo(idVehiculo);
    cargarHistoriasReparaciones(idVehiculo);
  }

  @override
  Widget build(BuildContext context) {
    if (vehiculo == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Detalles del Vehículo", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Card con información
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // información matrícula
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.badge, "Matrícula", vehiculo!['matricula'])),

                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      _ventanaCambio(vehiculo!["id"], "matricula", _matriculaController, esMatricula: true),
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),

                        const Divider(height: 30),

                        // información marca
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.branding_watermark, "Marca", vehiculo!['marca'])),

                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => _ventanaCambio(vehiculo!["id"], "marca", _marcaController),
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),

                        const Divider(height: 30),

                        // información modelo
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.model_training, "Modelo", vehiculo!['modelo'])),

                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => _ventanaCambio(vehiculo!["id"], "modelo", _modeloController),
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),

                        const Divider(height: 30),

                        // informacion combustible
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.local_gas_station, "Combustible", vehiculo!['combustible'])),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      _ventanaCambioCombustible(vehiculo!["id"], vehiculo!["combustible"]),
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),

                        const Divider(height: 30),

                        // informacion año
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.calendar_month, "Año", vehiculo!['anyo'].toString())),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      _ventanaCambio(vehiculo!["id"], "anyo", _anyoController, soloNumeros: true),
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),

                        const Divider(height: 30),

                        // informacion kilometraje
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.speed, "Kilometraje", "${vehiculo!['kilometraje']} km")),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => _ventanaCambio(
                                    vehiculo!["id"],
                                    "kilometraje",
                                    _kilometrajeController,
                                    soloNumeros: true,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),

                        const Divider(height: 30),

                        // informacion seguro
                        Row(
                          children: [
                            Expanded(
                              child: _infoRow(
                                Icons.security,
                                "Vencimiento Seguro",
                                vehiculo!['fecha_vencimiento_seguro'],
                              ),
                            ),
                            IconButton(
                              onPressed: () => seleccionarFecha(vehiculo!["id"]),
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),

                        const Divider(height: 30),

                        // informacion color
                        Row(
                          children: [
                            Icon(Icons.palette, size: 26, color: Color(vehiculo!['color'])),
                            const SizedBox(width: 15),
                            const Expanded(
                              child: Text(
                                "Color del vehículo",
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _ventanaCambioColor(vehiculo!["id"]),
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),

                        const Divider(height: 30),

                        // información estado
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.info_outline, "Estado", vehiculo!['estado'])),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      _ventanaCambioEstado(vehiculo!["id"], "Estado", vehiculo!["estado"]),
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),

                        const Divider(height: 30),

                        // informacion observaciones
                        Row(
                          children: [
                            Expanded(
                              child: _infoRow(
                                Icons.note,
                                "Observaciones",
                                vehiculo!['observaciones'] ?? "Sin observaciones",
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      _ventanaCambio(vehiculo!["id"], "observaciones", _observacionesController),
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

              const SizedBox(height: 40),

              // historial de reparaciones cabecera
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "HISTORIAL DE REPARACIONES",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),

                    const SizedBox(width: 20),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        await Navigator.pushNamed(context, "añadir_reparacion", arguments: vehiculo?["id"]);
                        // Recargamos cuando volvemos
                        cargarHistoriasReparaciones(vehiculo!["id"]);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Añadir"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // lista de reparaciones mejorada
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 130,
                  child: listaRepaciones == null || listaRepaciones!.isEmpty
                      ? const Center(child: Text("No hay reparaciones registradas"))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: listaRepaciones?.length,
                          itemBuilder: (context, index) {
                            // guardamos la reparacion actual y mostramos su informacion
                            Map<String, dynamic>? reparacionActual = listaRepaciones?[index];

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(right: 15, bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Container(
                                width: 200,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history, color: Colors.deepPurple.withOpacity(0.7)),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${reparacionActual?["fecha_inicio"]} / ${reparacionActual?["fecha_fin"]}",
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          "detalles_reparacion",
                                          arguments: reparacionActual?["id"],
                                        );
                                      },
                                      icon: const Icon(Icons.remove_red_eye, size: 16, color: Colors.white),
                                      label: const Text(
                                        "Ver detalles",
                                        style: TextStyle(fontSize: 13, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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

  Widget _ventanaCambio(
    int idVehiculo,
    String campoACambiar,
    TextEditingController controllerCampoACambiar, {
    bool soloNumeros = false,
    bool esMatricula = false,
  }) {
    final formKeyCambio = GlobalKey<FormState>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text("Actualizar $campoACambiar"),
      content: Form(
        key: formKeyCambio,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Introduce el nuevo valor para el campo:"),
            const SizedBox(height: 15),
            TextFormField(
              style: const TextStyle(color: Color(0xFFC8A97E)),
              controller: controllerCampoACambiar,
              keyboardType: soloNumeros ? TextInputType.number : TextInputType.text,
              textCapitalization: esMatricula ? TextCapitalization.characters : TextCapitalization.none,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: "Escribe aquí...",
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "El campo no puede estar vacío";

                if (esMatricula) {
                  final regex = RegExp(r'^\d{4}[BCDFGHJKLMNPRSTVWXYZ]{3}$');
                  if (!regex.hasMatch(value.toUpperCase())) {
                    return "Formato inválido (ej: 1234ABC)";
                  }
                }

                if (soloNumeros && !RegExp(r'^\d+$').hasMatch(value)) {
                  return "Introduce solo números válidos";
                }

                return null;
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  if (formKeyCambio.currentState!.validate()) {
                    final baseDatos = await DatabaseHelper.proyectodb();

                    await baseDatos.update(
                      "vehiculos",
                      {campoACambiar: controllerCampoACambiar.text},
                      where: "id = ?",
                      whereArgs: [idVehiculo],
                    );

                    controllerCampoACambiar.clear();
                    cargarDatosVehiculo(idVehiculo);
                    Navigator.pop(context);
                  }
                },
                child: const Text("GUARDAR CAMBIOS"),
              ),
            ),
          ],
        ),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),

            // el desplegable tiene 3 estado a elegir
            // cada uno de esos estados lo mapeamos para crearlo como DropdownMenuItem
            // su valor y es el mismo que su texto (ej: "Alquilado", "Taller"...)
            items: ["Disponible", "Alquilado", "Taller"].map((estadoActual) {
              return DropdownMenuItem(value: estadoActual, child: Text(estadoActual));
            }).toList(),
            // convertimos a lista porque items nos pide la lista con los valores del DropdownButtonFormField

            // al pulsar en uno de los desplegables del menú, actualizamos la variable con
            // el estado actual del coche para que sea ahora el valor del desplegable pulsado
            onChanged: (nuevoEstado) async {
              final baseDatos = await DatabaseHelper.proyectodb();

              await baseDatos.update("vehiculos", {"estado": nuevoEstado}, where: "id = ?", whereArgs: [idVehiculo]);

              cargarDatosVehiculo(idVehiculo);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _ventanaCambioCombustible(int idVehiculo, String combustibleActual) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text("Actualizar Combustible"),
      content: DropdownButtonFormField(
        value: combustibleActual,
        decoration: InputDecoration(
          labelText: "Combustible",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: ["Diesel", "Gasoil", "Eléctrico", "Híbrido"].map((c) {
          return DropdownMenuItem(value: c, child: Text(c));
        }).toList(),
        onChanged: (nuevo) async {
          final baseDatos = await DatabaseHelper.proyectodb();
          await baseDatos.update("vehiculos", {"combustible": nuevo}, where: "id = ?", whereArgs: [idVehiculo]);
          cargarDatosVehiculo(idVehiculo);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> seleccionarFecha(int idVehiculo) async {
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (fechaElegida != null) {
      String fechaFormateada =
          "${fechaElegida.year}-${fechaElegida.month.toString().padLeft(2, '0')}-${fechaElegida.day.toString().padLeft(2, '0')}";
      final baseDatos = await DatabaseHelper.proyectodb();
      await baseDatos.update(
        "vehiculos",
        {"fecha_vencimiento_seguro": fechaFormateada},
        where: "id = ?",
        whereArgs: [idVehiculo],
      );
      cargarDatosVehiculo(idVehiculo);
    }
  }

  void _ventanaCambioColor(int idVehiculo) {
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
        title: const Text("Elige un color"),
        content: Wrap(
          spacing: 10,
          children: colores
              .map(
                (c) => GestureDetector(
                  onTap: () async {
                    final baseDatos = await DatabaseHelper.proyectodb();
                    await baseDatos.update("vehiculos", {"color": c.value}, where: "id = ?", whereArgs: [idVehiculo]);
                    cargarDatosVehiculo(idVehiculo);
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(backgroundColor: c, radius: 20),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
