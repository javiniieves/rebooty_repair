import 'package:flutter/material.dart';
import '../../database.dart';
import 'package:email_validator/email_validator.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Añade un nuevo Cliente"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
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
                DropdownButtonFormField<String>(
                  value: _tipoDocumentoSeleccionado,
                  decoration: InputDecoration(
                    labelText: "Tipo de documento",
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: ["DNI", "NIE", "Pasaporte"].map((String tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (nuevoValor) {
                    setState(() {
                      _tipoDocumentoSeleccionado = nuevoValor!;
                      _dniController.clear(); // Limpiamos al cambiar de tipo de documento
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
                TextFormField(
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Teléfono",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  // Validación de teléfono
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "El teléfono es obligatorio";
                    }
                    if (value.length < 9) {
                      return "Introduce un número válido";
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
                      // Comprobamos si las validaciones del formulario son correctas
                      if (_formKey.currentState!.validate()) {
                        // guardamos la base de datos
                        final baseDatos = await DatabaseHelper.proyectodb();

                        // insertamos en la tabla "clientes" los datos que hemos cogido
                        await baseDatos.insert("clientes", {
                          "nombre": _nombreController.text,
                          "tipo_documento": _tipoDocumentoSeleccionado,
                          "documento_oficial": _dniController.text.toUpperCase(),
                          "telefono": _telefonoController.text,
                          "direccion": _direccionController.text,
                          "email": _emailController.text.isEmpty ? null : _emailController.text,
                        });

                        _nombreController.clear();
                        _dniController.clear();
                        _telefonoController.clear();
                        _direccionController.clear();
                        _emailController.clear();

                        // Aviso de éxito
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text("Cliente guardado correctamente")));

                        // Cerramos la pantalla al terminar
                        Navigator.pop(context);
                      }
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
}