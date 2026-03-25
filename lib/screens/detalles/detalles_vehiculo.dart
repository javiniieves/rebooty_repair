import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:rebooty_repair/models/Reparacion.dart';
import 'package:rebooty_repair/models/Vehiculo.dart';
import '../../DataBaseHelper.dart';
import 'package:image_picker/image_picker.dart';

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
  final _combustibleController = TextEditingController();
  final _editPrecioController = TextEditingController();

  final regex = RegExp(r'^\d{4}[BCDFGHJKLMNPRSTVWXYZQ]{3}$');

  late Vehiculo vehiculo;
  List<Reparacion>? listaReparaciones;
  late bool confirmar;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    vehiculo = ModalRoute.of(context)!.settings.arguments as Vehiculo;
    cargarDatosVehiculo();
    cargarHistoricoReparaciones();
  }

  Future<void> cargarDatosVehiculo() async {
    final datos = await DatabaseHelper.instance.obtenerVehiculoPorId(vehiculo.id!);

    if (datos != null) {
      setState(() {
        vehiculo = datos;
      });
    }
  }

  Future<void> cargarHistoricoReparaciones() async {
    final lista = await DatabaseHelper.instance.obtenerReparacionesPorVehiculo(vehiculo.id!);
    setState(() {
      listaReparaciones = lista;
    });
  }

  Future<void> actualizarVehiculo(String campo, dynamic valor) async {
    await DatabaseHelper.instance.actualizarCampoVehiculo(vehiculo.id!, campo, valor);
    await cargarDatosVehiculo();
  }

  // Función para cambiar la foto
  Future<void> cambiarFoto() async {
    final picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      await actualizarVehiculo("ruta_foto", imagen.path);
    }
  }

  // Función para cambiar el estado de limpieza
  Future<void> cambiarLimpieza(bool nuevoValorCheck) async {
    // Actualizamos el estado local primero para que la animación sea fluida
    setState(() {
      vehiculo.necesitaLimpieza = nuevoValorCheck ? 1 : 0;
    });

    // Guardamos en la base de datos
    try {
      actualizarVehiculo('necesita_limpieza', vehiculo.necesitaLimpieza);
    } catch (e) {
      debugPrint("Error al guardar limpieza: $e");
    }
  }

  void editarPrecioDia(int index, List<String> listaPrecios) {
    _editPrecioController.text = listaPrecios[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Editar Precio Día ${index + 1}"),
        content: TextFormField(
          controller: _editPrecioController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            labelText: "Precio en Euros",
            suffixText: "€",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR")
          ),
          ElevatedButton(
            onPressed: () async {
              String valorLimpio = _editPrecioController.text.trim();
              if (valorLimpio.isEmpty) valorLimpio = "0.0";

              listaPrecios[index] = valorLimpio;
              String nuevoChurro = listaPrecios.join(',');

              await actualizarVehiculo("precios", nuevoChurro);
              Navigator.pop(context);
            },
            child: const Text("GUARDAR"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> listaPrecios = (vehiculo.precios ?? "0,0,0,0,0,0,0").split(',');

    return Scaffold(
      appBar: AppBar(title: const Text("Detalles del Vehículo"), centerTitle: true),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Mostramos la imagen del coche si existe
            if (vehiculo.rutaFoto != null)
              GestureDetector(
                onTap: cambiarFoto, // Al pulsar, dejamos editar imaegn
                child: Container(
                  width: 200,
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 10)),
                    ],
                    image: DecorationImage(image: FileImage(File(vehiculo.rutaFoto!)), fit: BoxFit.cover),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BLOQUE IZQUIERDO
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        child: Column(
                          children: [
                            filaEditable(
                              Icons.badge,
                              "Matrícula",
                              vehiculo.matricula,
                                  () => mostrarDialogoTexto("matricula", _matriculaController, esMatricula: true),
                            ),
                            const Divider(),
                            filaEditable(
                              Icons.model_training,
                              "Modelo",
                              vehiculo.modelo,
                                  () => mostrarDialogoTexto("modelo", _modeloController),
                            ),
                            const Divider(),
                            filaEditable(
                              Icons.speed,
                              "Kilometraje",
                              "${vehiculo.kilometraje} km",
                                  () => mostrarDialogoTexto("kilometraje", _kilometrajeController, soloNumeros: true),
                            ),
                            const Divider(),
                            filaEditable(
                              Icons.security,
                              "Fin Seguro",
                              vehiculo.fechaVencimientoSeguro!,
                                  () => seleccionarFecha("fecha_vencimiento_seguro"),
                            ),
                            const Divider(),
                            filaEditable(
                              Icons.fact_check_outlined,
                              "Próxima ITV",
                              vehiculo.fechaProximaItv ?? "Sin fecha",
                                  () => seleccionarFecha("fecha_proxima_itv"),
                            ),
                            const Divider(),
                            filaEditable(
                              Icons.oil_barrel_outlined,
                              "Líneas Combustible",
                              "${vehiculo.cantidadCombustible}",
                                  () => mostrarDialogoTexto(
                                "cantidad_combustible",
                                _combustibleController,
                                soloNumeros: true,
                                esCombustible: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 5),

                  // BLOQUE DERECHO
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        child: Column(
                          children: [
                            filaEditable(
                              Icons.branding_watermark,
                              "Marca",
                              vehiculo.marca,
                                  () => mostrarDialogoTexto("marca", _marcaController),
                            ),
                            const Divider(),
                            filaEditable(
                              Icons.calendar_month,
                              "Año",
                              vehiculo.anyo.toString(),
                                  () => mostrarDialogoTexto("anyo", _anyoController, soloNumeros: true),
                            ),
                            const Divider(),
                            filaEditable(
                              Icons.info_outline,
                              "Estado",
                              vehiculo.estado,
                                  () => mostrarDropdown("estado", vehiculo.estado, [
                                "Disponible",
                                "Alquilado",
                                "Taller",
                              ]),
                            ),
                            const Divider(),
                            filaEditable(
                              Icons.local_gas_station,
                              "Combustible",
                              vehiculo.combustible!,
                                  () => mostrarDropdown("combustible", vehiculo.combustible!, [
                                "Diesel",
                                "Gasoil",
                                "Eléctrico",
                                "Híbrido",
                              ]),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.palette, color: Color(vehiculo.color!), size: 20),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      "Color",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 30,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.edit, size: 16),
                                      onPressed: mostrarSelectorColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            filaEditable(
                              Icons.note,
                              "Notas",
                              vehiculo.observaciones ?? "Sin notas",
                                  () => mostrarDialogoTexto("observaciones", _observacionesController),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: SwitchListTile(
                  title: const Text(
                    "¿EL VEHÍCULO NECESITA LIMPIEZA?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  secondary: const Icon(Icons.cleaning_services_outlined, color: Colors.black),
                  activeColor: Colors.deepPurple,
                  value: vehiculo.necesitaLimpieza == 1,
                  onChanged: (bool nuevoValor) {
                    cambiarLimpieza(nuevoValor);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text("PRECIOS POR DÍAS (Click para editar)", style: TextStyle(fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    children: const [
                      Padding(padding: EdgeInsets.all(8.0), child: Text("Día", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(8.0), child: Text("Precio (€)", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  ...List.generate(7, (index) {
                    return TableRow(
                      children: [
                        Padding(padding: const EdgeInsets.all(12.0), child: Text("${index + 1}", textAlign: TextAlign.center)),
                        InkWell(
                          onTap: () => editarPrecioDia(index, listaPrecios),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text("${listaPrecios[index]} €", textAlign: TextAlign.center, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 10),

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
                    await Navigator.pushNamed(context, "añadir_reparacion", arguments: vehiculo.id);
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
                          Text("${r.fechaInicio} / ${r.fechaFin}", style: TextStyle(fontSize: 12)),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "detalles_reparacion", arguments: r.id);
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icono, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(
                  valor,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 30,
            child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.edit, size: 16), onPressed: onEdit),
          ),
        ],
      ),
    );
  }

  void mostrarDialogoTexto(
      String campo,
      TextEditingController controller, {
        bool soloNumeros = false,
        bool esMatricula = false,
        bool esCombustible = false,
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
                  if (esMatricula && !regex.hasMatch(value.toUpperCase())) {
                    return "4 números y 3 consonantes";
                  }
                  if (esCombustible) {
                    int? valor = int.tryParse(value);
                    if (valor == null || valor < 0 || valor > 12) {
                      return "De 0 a 12 líneas";
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  confirmar = await confirmacion();
                  if (!confirmar) return Navigator.pop(context);

                  if (formKey.currentState!.validate()) {
                    dynamic valorAGuardar = soloNumeros ? int.parse(controller.text) : controller.text;
                    await actualizarVehiculo(campo, valorAGuardar);
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
            confirmar = await confirmacion();
            if (!confirmar) return Navigator.pop(context);

            await actualizarVehiculo(campo, nuevo);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> seleccionarFecha(String campo) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (fecha == null) return;

    String fechaFormateada =
        "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";

    await actualizarVehiculo(campo, fechaFormateada);
  }

  void mostrarSelectorColor() {
    Color pickerColor = Color(vehiculo.color!);

    void changeColor(Color color) {
      setState(() => pickerColor = color);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selecciona un color"),
        content: SingleChildScrollView(
          child: ColorPicker(pickerColor: pickerColor, onColorChanged: changeColor),
        ),
        actions: [
          ElevatedButton(
            child: const Text('seleccionar'),
            onPressed: () async {
              confirmar = await confirmacion();
              if (!confirmar) return Navigator.pop(context);

              await actualizarVehiculo("color", pickerColor.value);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
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
                TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.pop(context, false)),
                ElevatedButton(child: const Text("Confirmar"), onPressed: () => Navigator.pop(context, true)),
              ],
            );
          },
        ) ??
            false;
    return confirmar;
  }
}