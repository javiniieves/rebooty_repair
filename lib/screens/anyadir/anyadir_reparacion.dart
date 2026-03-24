import 'package:flutter/material.dart';
import 'package:rebooty_repair/models/Reparacion.dart';
import 'package:rebooty_repair/models/Vehiculo.dart';
import '../../DataBaseHelper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PantallaAnyadirReparacion extends StatefulWidget {
  const PantallaAnyadirReparacion({super.key});

  @override
  State<PantallaAnyadirReparacion> createState() => _PantallaAnyadirReparacionState();
}

class _PantallaAnyadirReparacionState extends State<PantallaAnyadirReparacion> {
  late Vehiculo vehiculo;

  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  DateTime? fechaInicio;
  final _fechaFinController = TextEditingController();
  DateTime? fechaFin;
  final _costeController = TextEditingController();

  // Lista para guardar las fotos seleccionadas temporalmente
  List<XFile> imagenesSeleccionadas = [];
  final ImagePicker _picker = ImagePicker();

  // metodo encargado de rellenar la variable vehiculo con
  // los datos del coche con el id recibido por parametro
  Future<void> cargarDatosVehiculo(int idVehiculo) async {
    final vehiculosConIdRecibido = await DatabaseHelper.instance.obtenerVehiculoPorId(idVehiculo);

    setState(() {
      vehiculo = vehiculosConIdRecibido!;
    });
  }

  // 2. Método para seleccionar fotos
  Future<void> seleccionarFotos() async {
    final List<XFile> fotos = await _picker.pickMultiImage();
    if (fotos.isNotEmpty) {
      setState(() {
        imagenesSeleccionadas.addAll(fotos);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    int idVehiculo = ModalRoute.of(context)?.settings.arguments as int;
    cargarDatosVehiculo(idVehiculo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Añade reparación al vehiculo",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("¿Desea guardar los datos que ha introducido?"),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _guardarReparacion();
                        },
                        label: const Row(children: [Icon(Icons.check), Text("Confirmar")]),
                      ),

                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        label: const Row(children: [Icon(Icons.cancel_outlined), Text("Cancelar")]),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          icon: const Icon(Icons.chevron_left_outlined),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          // Añadido para evitar errores con el teclado
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0), // Padding general
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // Card decorativa para agrupar las fechas
                Card(
                  elevation: 3,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // elegir fecha inicio
                        TextFormField(
                          style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                          controller: _fechaInicioController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Fecha inicio",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.2)),
                            ),
                          ),
                          onTap: () => seleccionarFecha(true),
                          // Validación de fecha obligatoria
                          validator: (value) =>
                              (value == null || value.isEmpty) ? "Selecciona la fecha de inicio" : null,
                        ),

                        const SizedBox(height: 25),

                        // elegir fecha fin
                        TextFormField(
                          style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                          controller: _fechaFinController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Fecha fin",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.2)),
                            ),
                          ),
                          onTap: () => seleccionarFecha(false),
                          // Validación de fecha obligatoria y coherencia temporal
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Selecciona la fecha de fin";
                            if (fechaInicio != null && fechaFin != null) {
                              if (fechaFin!.isBefore(fechaInicio!)) {
                                return "La fecha de fin no puede ser anterior al inicio";
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // introduir descripción con mejor diseño
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3, // Para que pueda escribir más texto
                  decoration: InputDecoration(
                    labelText: "Añade una descripción...",
                    alignLabelWithHint: true, // Alinea el label arriba si hay maxLines
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.2)),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // introducir precio
                TextFormField(
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  controller: _costeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Precio",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.2)),
                    ),
                  ),
                  validator: (value) {
                    // Comprobamos si el precio está vacío
                    if (value == null || value.isEmpty) {
                      return "Por favor, introduce un precio";
                    }

                    // Intentamos convertirlo a número
                    final numero = double.tryParse(value);

                    // Si el resultado es null, es que no es un número válido
                    if (numero == null) {
                      return "Introduce un número válido (ej: 10.50)";
                    }

                    // Validación extra: precio no negativo
                    if (numero < 0) {
                      return "El precio no puede ser negativo";
                    }

                    // Si está bien, devolvemos null
                    return null;
                  },
                ),

                const SizedBox(height: 25),

                // mostrar las fotos seleccionadas
                if (imagenesSeleccionadas.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imagenesSeleccionadas.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: FileImage(File(imagenesSeleccionadas[index].path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 5,
                              top: -5,
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    imagenesSeleccionadas.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 15),

                // Botón para añadir fotos
                OutlinedButton.icon(
                  onPressed: seleccionarFotos,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text("AÑADIR FOTOS"),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 60),

                // botón de añadir reparación con estilo mejorado
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _guardarReparacion();
                    },
                    icon: const Icon(Icons.save),
                    label: const Text(
                      "GUARDAR REPARACIÓN",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    // Texto corregido
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Espacio final
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _guardarReparacion() async {
    if (!_formKey.currentState!.validate()) return;

    final reparacio = Reparacion(
      idCoche: vehiculo.id,
      descripcion: _descripcionController.text,
      fechaInicio: _fechaInicioController.text,
      fechaFin: _fechaFinController.text,
      coste: double.parse(_costeController.text)
    );

    await DatabaseHelper.instance.insertarReparacion(reparacio);

    // Aviso de éxito (Corregido texto: Alquiler -> Reparación)
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reparación guardada correctamente")));

    // Volvemos atrás después de guardar
    Navigator.pop(context);
  }

  /// metodo para elegir una fecha
  Future<void> seleccionarFecha(bool esInicio) async {
    DateTime fechaHoy = DateTime.now();

    // dejamos que el usuario elija la fecha y la guardamos esa fecha
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      // el día en el que se abrirá el calendario
      // si no ha escogido fecha de inicio es el dia de hoy
      // si ya la ha elegido (es porque va a rellenar la fecha de fin)
      // por lo que mostramos es calendario a partir de la fecha de inicio
      initialDate: esInicio ? (fechaInicio ?? fechaHoy) : (fechaFin ?? fechaInicio ?? fechaHoy),
      firstDate: DateTime(2024),
      // limite es dentro de 5 años
      lastDate: fechaHoy.add(const Duration(days: 365 * 5)),
    );

    if (fechaElegida != null) {
      setState(() {
        // Guardamos la fecha y la formateamos para el texto (Año-Mes-Día)
        String fechaFormateada =
            "${fechaElegida.year}-${fechaElegida.month.toString().padLeft(2, '0')}-${fechaElegida.day.toString().padLeft(2, '0')}";

        if (esInicio) {
          fechaInicio = fechaElegida;
          _fechaInicioController.text = fechaFormateada;
          // Si la fecha de fin es anterior a la nueva fecha de inicio, la reseteamos
          if (fechaFin != null && fechaFin!.isBefore(fechaInicio!)) {
            fechaFin = null;
            _fechaFinController.clear();
          }
        } else {
          fechaFin = fechaElegida;
          _fechaFinController.text = fechaFormateada;
        }
      });
    }
  }
}
