import 'package:flutter/material.dart';
import 'package:rebooty_repair/models/Reparacion.dart';
import 'package:rebooty_repair/models/Vehiculo.dart';
import '../../DataBaseHelper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DetallesReparacionScreen extends StatefulWidget {
  const DetallesReparacionScreen({super.key});

  @override
  State<DetallesReparacionScreen> createState() => _DetallesReparacionScreenState();
}

class _DetallesReparacionScreenState extends State<DetallesReparacionScreen> {
  late Vehiculo vehiculoReparado;
  late Reparacion reparacion;
  late int idReparacion;
  late bool confirmar;
  bool cargando = true;

  final _descripcionController = TextEditingController();
  final _costeController = TextEditingController();

  // Para seleccionar nuevas fotos
  final ImagePicker _picker = ImagePicker();

  // metodo encargado de rellenar la variable reparacion con
  // los datos de la reparacion con el id recibido por parametro
  Future<void> cargarDatos() async {
    reparacion = (await DatabaseHelper.instance.obtenerReparacionPorId(idReparacion))!;
    vehiculoReparado = (await DatabaseHelper.instance.obtenerVehiculoPorId(reparacion.idCoche!))!;

    setState(() {
      cargando = false;
    });
  }

  // metodo para añadir más fotos a las que ya existen
  Future<void> agregarMasFotos() async {
    final List<XFile> nuevasFotos = await _picker.pickMultiImage();

    if (nuevasFotos.isNotEmpty) {
      // Cogemos las fotos que ya hay (si no hay, cadena vacía)
      String fotosActuales = reparacion.rutasFotos ?? "";

      // Convertimos las nuevas a una cadena separada por comas
      String nuevasRutas = nuevasFotos.map((f) => f.path).join(",");

      // Si ya había fotos, las juntamos con una coma en medio
      String resultadoFinal = fotosActuales.isEmpty ? nuevasRutas : "$fotosActuales,$nuevasRutas";

      await actualizarCampo("ruta_foto", resultadoFinal);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) return;

    idReparacion = args as int;
    cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    // Si la reparación o el vehículo aún no han cargado, mostramos el cargando para evitar errores de Null
    List<String>? listaFotos = [];
    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (reparacion.rutasFotos != null && reparacion.rutasFotos!.isNotEmpty) {
      listaFotos = reparacion.rutasFotos?.split(",");
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              // Icono y título del vehículo reparado
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(radius: 35, child: Icon(Icons.build_circle, size: 40)),
                    const SizedBox(height: 15),
                    Text(
                      "${vehiculoReparado.marca} ${vehiculoReparado.modelo}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Matrícula: ${vehiculoReparado.matricula}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
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
                          reparacion.fechaInicio,
                          () => _ventanaCambioFecha("fecha_inicio"),
                        ),
                        const Divider(),
                        _filaEditable(
                          Icons.event_available,
                          "Fecha Fin",
                          reparacion.fechaFin,
                          () => _ventanaCambioFecha("fecha_fin"),
                        ),
                        const Divider(),
                        _filaEditable(Icons.description, "Descripción", reparacion.descripcion, () {
                          showDialog(
                            context: context,
                            builder: (_) => _ventanaCambio("descripcion", _descripcionController),
                          );
                        }),
                        const Divider(),
                        _filaEditable(Icons.monetization_on, "Coste", "${reparacion.coste} €", () {
                          showDialog(context: context, builder: (_) => _ventanaCambio("coste", _costeController));
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // Sección de Fotos de la reparación alineada a la izquierda
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Fotos de la reparación", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),

                    // Botón para añadir fotos alineado a la izquierda
                    OutlinedButton.icon(
                      onPressed: agregarMasFotos,
                      icon: const Icon(Icons.add_a_photo, size: 20),
                      label: const Text("Añadir fotos"),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (listaFotos!.isEmpty)
                      const Text("No hay fotos añadidas", style: TextStyle(color: Colors.grey))
                    else
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: listaFotos.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 15),
                              width: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                image: DecorationImage(image: FileImage(File(listaFotos![index])), fit: BoxFit.cover),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 50),
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
    await DatabaseHelper.instance.actualizarCampoReparacion(idReparacion, campo, valor);
    await cargarDatos();
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
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
                ElevatedButton(
                  child: const Text("Confirmar"),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
    return confirmar;
  }
}
