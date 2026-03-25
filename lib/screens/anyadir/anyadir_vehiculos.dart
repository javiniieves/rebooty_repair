import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rebooty_repair/database.dart' hide DatabaseHelper;
import 'package:validators/validators.dart';

import '../../models/Vehiculo.dart';
import '../../DataBaseHelper.dart';

class PantallaAnyadirVehiculos extends StatefulWidget {
  const PantallaAnyadirVehiculos({super.key});

  @override
  State<PantallaAnyadirVehiculos> createState() => _PantallaAnyadirVehiculosState();
}

class _PantallaAnyadirVehiculosState extends State<PantallaAnyadirVehiculos> {
  late final GlobalKey<FormState> _formKey;

  late TextEditingController _matriculaController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _kilometrajeController;
  late TextEditingController _anyoController;
  late TextEditingController _observacionesController;
  late TextEditingController _fechaController;
  late TextEditingController _itvController;
  late TextEditingController _combustibleCantidadController;

  // Lista de controladores para la tabla de precios (Días 1 al 7)
  late List<TextEditingController> _preciosTableControllers;

  // estado por defecto al añadir un coche
  String estadoActual = "Disponible";
  Color colorDelVehiculo = Colors.white;
  String combustible = "Gasoil";
  DateTime? fechaVencimientoSeguro;
  String? rutaFoto;
  bool necesitaLimpieza = false;

  @override
  void initState() {
    super.initState();
    _matriculaController = TextEditingController();
    _marcaController = TextEditingController();
    _modeloController = TextEditingController();
    _kilometrajeController = TextEditingController();
    _anyoController = TextEditingController();
    _observacionesController = TextEditingController();
    _fechaController = TextEditingController();
    _itvController = TextEditingController();
    _combustibleCantidadController = TextEditingController();

    // Inicialización de los 7 campos de la tabla de precios
    _preciosTableControllers = List.generate(7, (index) => TextEditingController());

    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _matriculaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _kilometrajeController.dispose();
    _anyoController.dispose();
    _observacionesController.dispose();
    _fechaController.dispose();
    _itvController.dispose();
    _combustibleCantidadController.dispose();
    for (var controller in _preciosTableControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Añade un nuevo vehículo"),
        centerTitle: true,
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
                          await _guardarVehiculo();
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

      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Para añadir una foto del coche
                rutaFoto == null
                // si aún no ha elegido foto, le damos la opción
                    ? GestureDetector(
                  onTap: () => _ventanaAnyadirFoto(),
                  child: Container(
                    width: 200,
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple.withOpacity(0.3), width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 50),
                        SizedBox(height: 10),
                        Text("Añadir Foto", style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  // si hay foto elegida la mostramos
                )
                    : GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("¿Eliminar imagen?"),
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    rutaFoto = null;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text("Eliminar"),
                              ),

                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancelar"),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      image: DecorationImage(image: FileImage(File(rutaFoto!)), fit: BoxFit.cover),
                    ),
                  ),
                ),

                // Matricula y Marca
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                        controller: _matriculaController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: "Matricula",
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Escribe la matrícula";
                          }
                          final regex = RegExp(r'^\d{4}[BCDFGHJKLMNPRSTVWXYZQ]{3}$');
                          if (!regex.hasMatch(value.toUpperCase())) {
                            return "4 números y 3 consonantes";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                        controller: _marcaController,
                        decoration: InputDecoration(
                          labelText: "Marca",
                          prefixIcon: const Icon(Icons.directions_car),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Escribe la marca";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Modelo y Kilometraje
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                        controller: _modeloController,
                        decoration: InputDecoration(
                          labelText: "Modelo",
                          prefixIcon: const Icon(Icons.model_training),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Escribe el modelo";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                        controller: _kilometrajeController,
                        decoration: InputDecoration(
                          labelText: "Kilometraje",
                          prefixIcon: const Icon(Icons.receipt_long),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Escribe los kilómetros del coche";
                          }
                          if (!isNumeric(value)) {
                            return "Solo se pueden números";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Año y Seguro
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                        controller: _anyoController,
                        decoration: InputDecoration(
                          labelText: "Año",
                          prefixIcon: const Icon(Icons.calendar_month),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Escribe el año";
                          }
                          if (!isNumeric(value)) {
                            return "Solo se pueden números";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        controller: _fechaController,
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 12),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Fin del seguro",
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onTap: () => seleccionarFecha(_fechaController),
                        validator: (value) =>
                        (value == null || value.isEmpty) ? "Falta fecha seguro" : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ITV y Estado
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _itvController,
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 12),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Próxima ITV",
                          prefixIcon: const Icon(Icons.fact_check_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onTap: () => seleccionarFecha(_itvController),
                        validator: (value) => (value == null || value.isEmpty) ? "Falta la ITV" : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: estadoActual,
                        decoration: InputDecoration(
                          labelText: "Estado",
                          prefixIcon: const Icon(Icons.info_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        items: ["Disponible", "Alquilado", "Taller"].map((estado) {
                          return DropdownMenuItem(
                            value: estado,
                            child: Text(estado, style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
                          );
                        }).toList(),
                        onChanged: (nuevo) => setState(() => estadoActual = nuevo!),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Combustible y Líneas
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        value: combustible,
                        decoration: InputDecoration(
                          labelText: "Combustible",
                          prefixIcon: const Icon(Icons.local_gas_station_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        items: ["Diesel", "Gasoil", "Eléctrico", "Híbrido"].map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c, style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (elegido) => setState(() => combustible = elegido!),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                        controller: _combustibleCantidadController,
                        decoration: InputDecoration(
                          labelText: "Líneas combustible",
                          prefixIcon: const Icon(Icons.oil_barrel_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Introduzca líneas";
                          int? v = int.tryParse(value);
                          if (v == null || v < 0 || v > 12) return "Máximo 12 líneas";
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Color y Observaciones
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Color",
                          prefixIcon: const Icon(Icons.palette),
                          filled: true,
                          fillColor: colorDelVehiculo,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onTap: () => mostrarSelectorColor(),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                        controller: _observacionesController,
                        decoration: InputDecoration(
                          labelText: "Notas",
                          prefixIcon: const Icon(Icons.note),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Switch Limpieza
                SwitchListTile(
                  title: const Text("¿Necesita limpieza?", style: TextStyle(fontSize: 14)),
                  secondary: const Icon(Icons.cleaning_services_outlined),
                  value: necesitaLimpieza,
                  onChanged: (bool val) => setState(() => necesitaLimpieza = val),
                ),

                const SizedBox(height: 30),

                // TABLA DE PRECIOS POR DÍAS (TIPO EXCEL)
                const Text("TABLA DE PRECIOS (€)", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(5)),
                  columnWidths: const { 0: FixedColumnWidth(60) },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      children: const [
                        Padding(padding: EdgeInsets.all(8.0), child: Text("Días", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text("Precio del alquiler (€)", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    ...List.generate(7, (index) {
                      return TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Text("${index + 1}", textAlign: TextAlign.center)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              controller: _preciosTableControllers[index],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(border: InputBorder.none, hintText: "0.00"),
                              validator: (value) => (value == null || value.isEmpty) ? "Indique precio" : null,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (rutaFoto == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Seleccione una foto"), backgroundColor: Colors.red));
                        return;
                      }
                      await _guardarVehiculo();
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("GUARDAR"),
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _guardarVehiculo() async {
    if (!_formKey.currentState!.validate()) return;

    String? rutaFinal;
    if (rutaFoto != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final nombreImagen = p.basename(rutaFoto!);
      final imagenGuardada = await File(rutaFoto!).copy('${appDir.path}/$nombreImagen');
      rutaFinal = imagenGuardada.path;
    }

    // Unimos los 7 precios en un solo String separado por comas
    String preciosConcatenados = _preciosTableControllers
        .map((controller) => controller.text.trim().isEmpty ? "0.0" : controller.text.trim())
        .join(',');

    final vehiculo = Vehiculo(
      matricula: _matriculaController.text.toUpperCase(),
      marca: _marcaController.text,
      modelo: _modeloController.text,
      estado: estadoActual,
      color: colorDelVehiculo.value,
      kilometraje: double.tryParse(_kilometrajeController.text),
      anyo: int.tryParse(_anyoController.text),
      combustible: combustible,
      observaciones: _observacionesController.text,
      fechaVencimientoSeguro: _fechaController.text,
      fechaProximaItv: _itvController.text,
      cantidadCombustible: int.parse(_combustibleCantidadController.text),
      rutaFoto: rutaFinal,
      necesitaLimpieza: necesitaLimpieza ? 1 : 0,
      precios: preciosConcatenados,
    );

    await DatabaseHelper.instance.insertarVehiculo(vehiculo);
    _limpiarCampos();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vehículo guardado correctamente")));
      Navigator.pop(context);
    }
  }

  void _limpiarCampos() {
    _matriculaController.clear();
    _marcaController.clear();
    _modeloController.clear();
    _observacionesController.clear();
    _kilometrajeController.clear();
    _anyoController.clear();
    _itvController.clear();
    _combustibleCantidadController.clear();
    for (var c in _preciosTableControllers) { c.clear(); }
    setState(() => rutaFoto = null);
  }

  void mostrarSelectorColor() {
    Color pickerColor = const Color(0xff443a49);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selecciona un color"),
        content: SingleChildScrollView(child: ColorPicker(pickerColor: pickerColor, onColorChanged: (c) => pickerColor = c)),
        actions: [
          ElevatedButton(child: const Text('seleccionar'), onPressed: () { setState(() => colorDelVehiculo = pickerColor); Navigator.pop(context); }),
        ],
      ),
    );
  }

  Future<void> seleccionarFecha(TextEditingController controller) async {
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (fechaElegida != null) {
      setState(() {
        controller.text = "${fechaElegida.year}-${fechaElegida.month.toString().padLeft(2, '0')}-${fechaElegida.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _ventanaAnyadirFoto() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? imagen = await imagePicker.pickImage(source: ImageSource.gallery);
    if (imagen != null) setState(() => rutaFoto = imagen.path);
  }
}