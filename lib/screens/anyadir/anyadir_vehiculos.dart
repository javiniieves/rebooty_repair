import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rebooty_repair/database.dart';
import 'package:validators/validators.dart';

class PantallaAnyadirVehiculos extends StatefulWidget {
  const PantallaAnyadirVehiculos({super.key});

  @override
  State<PantallaAnyadirVehiculos> createState() => _PantallaAnyadirVehiculosState();
}

class _PantallaAnyadirVehiculosState extends State<PantallaAnyadirVehiculos> {
  late final _formKey;

  late TextEditingController _matriculaController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _kilometrajeController;
  late TextEditingController _anyoController;
  late TextEditingController _observacionesController;
  late TextEditingController _fechaController;

  // nuevos controladores
  late TextEditingController _itvController;
  late TextEditingController _combustibleCantidadController;

  // estado por defecto al añadir un coche
  String estadoActual = "Disponible";

  Color colorDelVehiculo = Colors.white;

  String combustible = "Gasoil";

  DateTime? fechaVencimientoSeguro;

  String? rutaFoto;

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
    // inicializamos los nuevos
    _itvController = TextEditingController();
    _combustibleCantidadController = TextEditingController();

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
    // liberamos los nuevos
    _itvController.dispose();
    _combustibleCantidadController.dispose();

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
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left_outlined),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(30.0),
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
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.deepPurple.withOpacity(0.3), width: 2),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: Column(
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
                                title: Text("¿Eliminar imagen?"),
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
                                      child: Text("Eliminar"),
                                    ),

                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancelar"),
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
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 10)),
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
                        decoration: InputDecoration(
                          labelText: "Matricula",
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        // Validación de matrícula
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
                        // Validación de marca
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

                // Modelo y Combustible
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
                        // Validación de modelo
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
                      child: DropdownButtonFormField(
                        value: combustible,
                        decoration: InputDecoration(
                          labelText: "Combustible",
                          prefixIcon: Icon(Icons.local_gas_station_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        items: ["Diesel", "Gasoil", "Eléctrico", "Híbrido"].map((combustibleActual) {
                          return DropdownMenuItem(
                            value: combustibleActual,
                            child: Text(
                              combustibleActual,
                              style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (combustibleElegido) {
                          setState(() {
                            combustible = combustibleElegido!;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Año y Kilometraje
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                        controller: _anyoController,
                        decoration: InputDecoration(
                          labelText: "Año",
                          prefixIcon: const Icon(Icons.calendar_month),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        // Validación del año
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
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                        controller: _kilometrajeController,
                        decoration: InputDecoration(
                          labelText: "Kilometraje",
                          prefixIcon: Icon(Icons.receipt_long),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        // Validación del año
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

                SizedBox(height: 20),

                // Seguro y Estado
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _fechaController,
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 12),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Fecha finalización del seguro",
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onTap: () => seleccionarFecha(_fechaController),
                        // Validación de fecha obligatoria
                        validator: (value) => (value == null || value.isEmpty) ? "Introduzca la fecha de finalización del seguro" : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: estadoActual,
                        decoration: InputDecoration(
                          labelText: "Estado",
                          prefixIcon: Icon(Icons.info_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        items: ["Disponible", "Alquilado", "Taller"].map((estadoActual) {
                          return DropdownMenuItem(
                            value: estadoActual,
                            child: Text(estadoActual, style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
                          );
                        }).toList(),
                        onChanged: (nuevoEstado) {
                          setState(() {
                            estadoActual = nuevoEstado!;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // ITV y Cantidad Combustible
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
                        // Validación de fecha
                        validator: (value) => (value == null || value.isEmpty) ? "Falta la ITV" : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                        controller: _combustibleCantidadController,
                        decoration: InputDecoration(
                          labelText: "Lineas de combustible",
                          prefixIcon: Icon(Icons.oil_barrel_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Introduzca las líneas de combustible";
                          }
                          if (!isNumeric(value)) {
                            return "Solo se permiten números";
                          }

                          int? valueInt = int.tryParse(value);

                          if (valueInt! < 0) {
                            return 'No puede tener líneas negativas';
                          }

                          if (valueInt > 10) {
                            return 'El máximo son 12 lineas';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Color y Observaciones
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Color",
                          prefixIcon: const Icon(Icons.palette),
                          filled: true,
                          fillColor: colorDelVehiculo,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onTap: () {
                          mostrarSelectorColor();
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                        controller: _observacionesController,
                        decoration: InputDecoration(
                          labelText: "Notas",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // botón de añadir coche
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Validamos el formulario antes de guardar
                      if (_formKey.currentState!.validate()) {
                        if (rutaFoto == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Debes seleccionar una foto del vehículo"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // guardamos la base de datos
                        final baseDatos = await DatabaseHelper.proyectodb();

                        // insertamos en la tabal "vehiculos" el coche con los datos que hemos cogido
                        await baseDatos.insert("vehiculos", {
                          "matricula": _matriculaController.text,
                          "marca": _marcaController.text,
                          "modelo": _modeloController.text,
                          "estado": estadoActual,
                          "color": colorDelVehiculo,
                          "kilometraje": _kilometrajeController.text,
                          "anyo": _anyoController.text,
                          "combustible": combustible,
                          "observaciones": _observacionesController.text,
                          "fecha_vencimiento_seguro": _fechaController.text,
                          "fecha_proxima_itv": _itvController.text,
                          "cantidad_combustible": int.parse(_combustibleCantidadController.text),
                          "ruta_foto": rutaFoto,
                        });

                        _matriculaController.clear();
                        _marcaController.clear();
                        _modeloController.clear();
                        _observacionesController.clear();
                        _kilometrajeController.clear();
                        _anyoController.clear();
                        _itvController.clear();
                        _combustibleCantidadController.clear();

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text("Vehículo guardado correctamente")));
                        // Volvemos atrás tras el éxito
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("GUARDAR"),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void mostrarSelectorColor() {
    Color pickerColor = Color(0xff443a49);
    Color currentColor = Color(0xff443a49);

    void changeColor(Color color) {
      setState(() => pickerColor = color);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selecciona un color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text('seleccionar'),
            onPressed: () async {
              setState(() => colorDelVehiculo = pickerColor);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /// metodo para elegir una fecha (ahora recibe un controlador para ser reutilizado)
  Future<void> seleccionarFecha(TextEditingController controller) async {
    DateTime fechaHoy = DateTime.now();

    // dejamos que el usuario elija la fecha y la guardamos esa fecha
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      // el día en el que se abrirá el calendario
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      // limite es dentro de 5 años
      lastDate: fechaHoy.add(const Duration(days: 365 * 5)),
    );

    if (fechaElegida != null) {
      setState(() {
        String fechaFormateada =
            "${fechaElegida.year}-${fechaElegida.month.toString().padLeft(2, '0')}-${fechaElegida.day.toString().padLeft(2, '0')}";
        controller.text = fechaFormateada;
      });
    }
  }

  Future<void> _ventanaAnyadirFoto() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? imagen = await imagePicker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      setState(() {
        rutaFoto = imagen.path;
      });
    }
  }
}
