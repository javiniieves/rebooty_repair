import 'dart:io';
import 'package:flutter/material.dart';
import '../../DataBaseHelper.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/Cliente.dart';

class PantallaAnyadirClientes extends StatefulWidget {
  const PantallaAnyadirClientes({super.key});

  @override
  State<PantallaAnyadirClientes> createState() => _PantallaAnyadirClientesState();
}

class _PantallaAnyadirClientesState extends State<PantallaAnyadirClientes> {
  late final _formKey;

  late TextEditingController _nombreController;
  late TextEditingController _dniController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _emailController;

  String _tipoDocumentoSeleccionado = "DNI";
  String telefonoCompleto = "";

  // Variable para la foto del cliente (opcional)
  String? rutaFoto;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _dniController = TextEditingController();
    _telefonoController = TextEditingController();
    _direccionController = TextEditingController();
    _emailController = TextEditingController();

    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Metodo para elegir la foto (galería)
  Future<void> _ventanaAnyadirFoto() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? imagen = await imagePicker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      setState(() {
        rutaFoto = imagen.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Añade un nuevo Cliente"),
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
                          await _guardarCliente();
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
                // Para añadir una foto del cliente (Opcional)
                GestureDetector(
                  onTap: () => _ventanaAnyadirFoto(),
                  child: Container(
                    width: 150,
                    height: 150,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
                    ),
                    // si no ha elegido, le permitimos hacerlo
                    child: rutaFoto == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.black),
                              SizedBox(height: 10),
                              Text("Foto (Opcional)", style: TextStyle(fontSize: 12, color: Colors.black)),
                            ],
                          )
                        // si ya la ha elegido, mostramos la foto
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(File(rutaFoto!), fit: BoxFit.cover),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // introducir nombre
                TextFormField(
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: "Nombre",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  // Validación de nombre
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor, escribe un nombre";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Selector del tipo de documento
                DropdownMenuFormField<String>(
                  width: double.infinity,
                  initialSelection: _tipoDocumentoSeleccionado,
                  leadingIcon: const Icon(Icons.description),
                  label: const Text("Tipo de documento"),
                  dropdownMenuEntries: ["DNI", "NIE", "Pasaporte"].map((tipo) {
                    return DropdownMenuEntry(
                      value: tipo,
                      label: tipo,
                      labelWidget: Text(tipo, style: const TextStyle(color: Color(0xFFC8A97E))),
                    );
                  }).toList(),
                  onSelected: (nuevoValor) {
                    setState(() {
                      _tipoDocumentoSeleccionado = nuevoValor!;
                      _dniController.clear();
                    });
                  },
                ),

                const SizedBox(height: 30),

                // introducir DNI / NIE / Pasaporte
                TextFormField(
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  controller: _dniController,
                  decoration: InputDecoration(
                    labelText: "Introduce tu $_tipoDocumentoSeleccionado",
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  // Validación según el tipo de docuemnto elegido
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "El documento es obligatorio";
                    }

                    if (_tipoDocumentoSeleccionado == "DNI") {
                      // Patrón: 8 números y 1 letra
                      final regExp = RegExp(r'^\d{8}[A-Z]$');
                      if (!regExp.hasMatch(value.toUpperCase())) {
                        return "Formato incorrecto (Ej: 12345678Z)";
                      }
                    } else if (_tipoDocumentoSeleccionado == "NIE") {
                      // Patrón: 1 letra (XYZ), 7 números y 1 letra
                      final regExp = RegExp(r'^[XYZ]\d{7}[A-Z]$');
                      if (!regExp.hasMatch(value.toUpperCase())) {
                        return "Formato incorrecto (Ej: X1234567L)";
                      }
                    } else if (_tipoDocumentoSeleccionado == "Pasaporte") {
                      // Validación para pasaportes
                      if (value.length < 6) {
                        return "El pasaporte debe ser más largo";
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // introducir teléfono
                IntlPhoneField(
                  controller: _telefonoController,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  initialCountryCode: 'ES',
                  onChanged: (phone) {
                    telefonoCompleto = phone.completeNumber;
                  },
                  validator: (phone) {
                    if (phone == null || phone.number.isEmpty) {
                      return "El teléfono es obligatorio";
                    }
                    if (phone.number.length < 6) {
                      return "Número inválido";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // introducir direccion
                TextFormField(
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  controller: _direccionController,
                  decoration: InputDecoration(
                    labelText: "Dirección",
                    prefixIcon: const Icon(Icons.home),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  // Validación de dirección
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "La dirección es obligatoria";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Correo electrónico (opcional)",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),

                  // Validación opcional
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!EmailValidator.validate(value)) {
                        return "El correo electrónico no es válido";
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 100),

                // botón de añadir cliente
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                        await _guardarCliente();
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("GUARDAR CLIENTE"),
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

  Future<void> _guardarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    final cliente = Cliente(
      nombre: _nombreController.text,
      tipoDocumento: _tipoDocumentoSeleccionado,
      documentoOficial: _dniController.text.toUpperCase(),
      telefono: telefonoCompleto,
      direccion: _direccionController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      rutaFoto: rutaFoto,
    );

    await DatabaseHelper.instance.insertarCliente(cliente);

    _limpiarCampos();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cliente guardado correctamente")),
    );

    Navigator.pop(context);
  }

  void _limpiarCampos() {
    _nombreController.clear();
    _dniController.clear();
    _telefonoController.clear();
    _direccionController.clear();
    _emailController.clear();
  }
}
