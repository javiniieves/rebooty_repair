import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rebooty_repair/models/Cliente.dart';
import '../../DataBaseHelper.dart';

class DetallesClienteScreen extends StatefulWidget {
  const DetallesClienteScreen({super.key});

  @override
  State<DetallesClienteScreen> createState() => _DetallesClienteScreenState();
}

class _DetallesClienteScreenState extends State<DetallesClienteScreen> {
  final _nombreControler = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoControler = TextEditingController();
  final _direccionControler = TextEditingController();
  final _correoControler = TextEditingController();

  late Cliente cliente;

  // Variable para controlar el tipo de documento en la edición
  String _tipoDocumento = "DNI";
  late String telefonoCompleto = cliente.telefono ?? "";

  late int idCliente;
  late bool confirmar;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cliente = ModalRoute.of(context)!.settings.arguments as Cliente;
    idCliente = cliente.id!;
    cargarDatosCliente(idCliente);
  }

  Future<void> cargarDatosCliente(int idCliente) async {
    setState(() {
      _tipoDocumento = cliente.tipoDocumento;
    });
  }

  // Función para cambiar la foto del cliente
  Future<void> cambiarFoto() async {
    final picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      await actualizarCampo("ruta_foto", imagen.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cliente == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del Cliente"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Mostramos la imagen del cliente arriba (estilo vehículo)
            GestureDetector(
              onTap: cambiarFoto, // Al pulsar, dejamos editar imagen
              child: Container(
                width: 180,
                height: 180,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 10)),
                  ],
                ),
                child: cliente.rutaFoto != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(File(cliente.rutaFoto!), fit: BoxFit.cover),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cliente.nombre.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                            ),
                            const Text("Añadir Foto", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 10),

            // Bloque de información en una sola columna
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      filaEditable(
                        Icons.person,
                        "Nombre",
                        cliente.nombre,
                        () => mostrarDialogoTexto("nombre", _nombreControler),
                      ),
                      const Divider(),
                      filaEditable(
                        Icons.badge,
                        cliente.tipoDocumento ?? "Documento",
                        cliente.documentoOficial,
                        () => showDialog(context: context, builder: (context) => _ventanaCambioDocumento(idCliente)),
                      ),
                      const Divider(),
                      filaEditable(
                        Icons.phone,
                        "Teléfono",
                        cliente.telefono!,
                        () => mostrarDialogoTexto("telefono", _telefonoControler, esTelefono: true),
                      ),
                      const Divider(),
                      filaEditable(
                        Icons.location_on,
                        "Dirección",
                        cliente.direccion!,
                        () => mostrarDialogoTexto("direccion", _direccionControler),
                      ),
                      const Divider(),
                      filaEditable(
                        Icons.email,
                        "Email",
                        cliente.email ?? "Sin correo",
                        () => mostrarDialogoTexto("email", _correoControler, esEmail: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget para las filas con el botón de editar (estilo vehículo)
  Widget filaEditable(IconData icono, String titulo, String valor, VoidCallback onEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icono, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(
                  valor,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
        ],
      ),
    );
  }

  // Ventana genérica para editar campos
  void mostrarDialogoTexto(
    String campo,
    TextEditingController controller, {
    bool esTelefono = false,
    bool esEmail = false,
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
              esTelefono
                  ? IntlPhoneField(
                      controller: controller,
                      initialCountryCode: 'ES',
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        labelText: "Teléfono",
                      ),
                      onChanged: (phone) => telefonoCompleto = phone.completeNumber,
                      validator: (phone) {
                        if (phone == null || phone.number.isEmpty) return "Campo obligatorio";
                        return null;
                      },
                    )
                  : TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        hintText: "Escribe aquí...",
                      ),
                      validator: (value) {
                        if (esEmail && value != null && value.isNotEmpty) {
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Email no válido";
                        }
                        if (!esEmail && (value == null || value.trim().isEmpty)) return "Campo obligatorio";
                        return null;
                      },
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  confirmar = await confirmacion();
                  if (!confirmar) return Navigator.pop(context);
                  if (esTelefono) {
                    if (telefonoCompleto.isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text("El teléfono es obligatorio")));
                      return;
                    }
                  }
                  if (formKey.currentState!.validate()) {
                    String valorFinal = esTelefono ? telefonoCompleto : controller.text;
                    await actualizarCampo(campo, valorFinal);
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

  // Ventana específica para cambiar Tipo y Número de documento
  Widget _ventanaCambioDocumento(int idCliente) {
    void mostrarMensaje(String mensaje) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text("Actualizar Documento"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _tipoDocumento,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.description),
            ),
            items: ["DNI", "NIE", "Pasaporte"].map((tipo) {
              return DropdownMenuItem(
                value: tipo,
                child: Text(tipo, style: const TextStyle(color: Color(0xFFC8A97E))),
              );
            }).toList(),
            onChanged: (nuevoTipoDocumento) {
              setState(() {
                _tipoDocumento = nuevoTipoDocumento!;
                _documentoController.clear();
              });
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            style: const TextStyle(color: Color(0xFFC8A97E)),
            controller: _documentoController,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: "Escribe el nuevo $_tipoDocumento",
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                String valor = _documentoController.text.toUpperCase();
                if (valor.isEmpty) {
                  mostrarMensaje("¡No puedes dejar el documento vacío!");
                  return;
                }
                if (_tipoDocumento == "DNI" && !RegExp(r'^\d{8}[A-Z]$').hasMatch(valor)) {
                  mostrarMensaje("Formato DNI incorrecto");
                  return;
                } else if (_tipoDocumento == "NIE" && !RegExp(r'^[XYZ]\d{7}[A-Z]$').hasMatch(valor)) {
                  mostrarMensaje("Formato NIE incorrecto");
                  return;
                } else if (_tipoDocumento == "Pasaporte" && valor.length < 6) {
                  mostrarMensaje("Pasaporte demasiado corto");
                  return;
                }

                confirmar = await confirmacion();
                if (!confirmar) return Navigator.pop(context);

                actualizarCampo('tipo_documento', _tipoDocumento);
                actualizarCampo('documento_oficial', _documentoController.text);

                _documentoController.clear();
                cargarDatosCliente(idCliente);
                Navigator.pop(context);
              },
              child: const Text("GUARDAR CAMBIOS"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> actualizarCampo(String campo, String valor) async {
    final dbHelper = DatabaseHelper.instance;
    switch (campo) {
      case "nombre":
        cliente.nombre = valor;
        break;
      case "telefono":
        cliente.telefono = valor;
        break;
      case "direccion":
        cliente.direccion = valor;
        break;
      case "email":
        cliente.email = valor;
        break;
      case "ruta_foto":
        cliente.rutaFoto = valor;
        break;
      case "tipo_documento":
        cliente.tipoDocumento = valor;
        break;
      case "documento_oficial":
        cliente.documentoOficial = valor;
        break;
    }
    await dbHelper.actualizarCliente(cliente);
    setState(() {});
  }

  Future<bool> confirmacion() async {
    confirmar =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirmar cambio"),
            content: const Text("¿Seguro que quieres actualizar los datos?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirmar")),
            ],
          ),
        ) ??
        false;
    return confirmar;
  }
}
