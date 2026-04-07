import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rebooty_repair/DataBaseHelper.dart';
import 'package:validators/validators.dart';
import '../../models/Vehiculo.dart';

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
                  title: const Text("¿Desea guardar los datos?", style: TextStyle(fontSize: 18)),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _guardarVehiculo();
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: const Flexible(child: Text("Sí", overflow: TextOverflow.ellipsis)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Flexible(child: Text("No", overflow: TextOverflow.ellipsis)),
                        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0), // Padding ajustado
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Para añadir una foto del coche
                rutaFoto == null
                    ? GestureDetector(
                  onTap: () => _ventanaAnyadirFoto(),
                  child: Container(
                    width: 180,
                    height: 180,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple.withOpacity(0.3), width: 2),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 40),
                        SizedBox(height: 10),
                        Text("Añadir Foto", style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                )
                    : GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("¿Eliminar imagen?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                            TextButton(
                              onPressed: () {
                                setState(() => rutaFoto = null);
                                Navigator.pop(context);
                              },
                              child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 180,
                    height: 180,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(image: FileImage(File(rutaFoto!)), fit: BoxFit.cover),
                    ),
                  ),
                ),

                // Matricula y Marca
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(_matriculaController, "Matrícula", Icons.badge,
                          capitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Obligatorio";
                            final regex = RegExp(r'^\d{4}[BCDFGHJKLMNPRSTVWXYZQ]{3}$');
                            if (!regex.hasMatch(value.toUpperCase())) return "Formato incorrecto";
                            return null;
                          }),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(_marcaController, "Marca", Icons.directions_car,
                          validator: (value) => (value == null || value.isEmpty) ? "Obligatorio" : null),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Modelo y Kilometraje
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(_modeloController, "Modelo", Icons.model_training,
                          validator: (value) => (value == null || value.isEmpty) ? "Obligatorio" : null),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(_kilometrajeController, "Km", Icons.receipt_long,
                          type: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Obligatorio";
                            if (!isNumeric(value)) return "Solo números";
                            return null;
                          }),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Año y Seguro
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(_anyoController, "Año", Icons.calendar_month,
                          type: TextInputType.number,
                          validator: (value) => (value == null || value.isEmpty) ? "Obligatorio" : null),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(_fechaController, "Seguro", Icons.calendar_today,
                          readOnly: true,
                          onTap: () => seleccionarFecha(_fechaController),
                          validator: (value) => (value == null || value.isEmpty) ? "Falta fecha" : null),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // ITV y Estado
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(_itvController, "ITV", Icons.fact_check_outlined,
                          readOnly: true,
                          onTap: () => seleccionarFecha(_itvController),
                          validator: (value) => (value == null || value.isEmpty) ? "Falta ITV" : null),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: estadoActual,
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: "Estado",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          prefixIcon: const Icon(Icons.info_outline, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        items: ["Disponible", "Alquilado", "Taller"].map((estado) {
                          return DropdownMenuItem(value: estado, child: Text(estado));
                        }).toList(),
                        onChanged: (nuevo) => setState(() => estadoActual = nuevo!),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Combustible y Líneas
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        value: combustible,
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: "Motor",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                          prefixIcon: const Icon(Icons.local_gas_station_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        items: ["Diesel", "Gasoil", "Eléctrico", "Híbrido"].map((c) {
                          return DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: (elegido) => setState(() => combustible = elegido!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(_combustibleCantidadController, "Líneas", Icons.oil_barrel_outlined,
                          type: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Error";
                            int? v = int.tryParse(value);
                            if (v == null || v < 0 || v > 12) return "0-12";
                            return null;
                          }),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Color y Observaciones
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Color",
                          prefixIcon: const Icon(Icons.palette, size: 20),
                          filled: true,
                          fillColor: colorDelVehiculo,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onTap: () => mostrarSelectorColor(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(_observacionesController, "Notas", Icons.note),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Switch Limpieza
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("¿Necesita limpieza?", style: TextStyle(fontSize: 14)),
                  secondary: const Icon(Icons.cleaning_services_outlined),
                  value: necesitaLimpieza,
                  onChanged: (bool val) => setState(() => necesitaLimpieza = val),
                ),

                const SizedBox(height: 30),

                // TABLA DE PRECIOS POR DÍAS
                const Text("TABLA DE PRECIOS (€)", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(5)),
                    columnWidths: const { 0: FixedColumnWidth(50), 1: FlexColumnWidth() },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                        children: const [
                          Padding(padding: EdgeInsets.all(8.0), child: Text("Días", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(8.0), child: Text("Precio Alquiler (€)", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                      ),
                      ...List.generate(7, (index) {
                        return TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text("${index + 1}", textAlign: TextAlign.center)),
                            TextFormField(
                              controller: _preciosTableControllers[index],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(border: InputBorder.none, hintText: "0.00", contentPadding: EdgeInsets.zero),
                              validator: (value) => (value == null || value.isEmpty) ? "Indique precio" : null,
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

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
                    label: const Text("GUARDAR VEHÍCULO", style: TextStyle(fontWeight: FontWeight.bold)),
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

  // Widget auxiliar para simplificar la creación de campos
  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool readOnly = false, VoidCallback? onTap, String? Function(String?)? validator, TextInputType type = TextInputType.text, TextCapitalization capitalization = TextCapitalization.none}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      keyboardType: type,
      textCapitalization: capitalization,
      style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
    Color pickerColor = colorDelVehiculo;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selecciona un color"),
        content: SingleChildScrollView(child: ColorPicker(pickerColor: pickerColor, onColorChanged: (c) => pickerColor = c)),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(context)),
          ElevatedButton(child: const Text('Seleccionar'), onPressed: () { setState(() => colorDelVehiculo = pickerColor); Navigator.pop(context); }),
        ],
      ),
    );
  }

  Future<void> seleccionarFecha(TextEditingController controller) async {
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
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