import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:image_picker/image_picker.dart';
import '../../database.dart';

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

  Map<String, dynamic>? cliente;

  // Variable para controlar el tipo de documento en la edición
  String _tipoDocumento = "DNI";
  String telefonoCompleto = "";

  late int idCliente;
  late bool confirmar;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    idCliente = ModalRoute.of(context)!.settings.arguments as int;
    cargarDatosCliente(idCliente);
  }

  // metodo encargado de rellenar la variable vehiculo con
  // los datos del coche con el id recibido por parametro
  Future<void> cargarDatosCliente(int idCliente) async {
    final clienteConIdRecibido = await DatabaseHelper.obtenerClientesPorId(idCliente);

    setState(() {
      cliente = clienteConIdRecibido.first;
      // Sincronizamos el tipo de documento actual
      _tipoDocumento = cliente!['tipo_documento'] ?? "DNI";
    });
  }

  Future<void> actualizarCliente(String campo, dynamic valor) async {
    final db = await DatabaseHelper.proyectodb();

    await db.update("clientes", {campo: valor}, where: "id = ?", whereArgs: [idCliente]);
    cargarDatosCliente(idCliente);
  }

  // Función para cambiar la foto del cliente
  Future<void> cambiarFoto() async {
    final picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      await actualizarCliente("ruta_foto", imagen.path);
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
                child: cliente!["ruta_foto"] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(File(cliente!["ruta_foto"]), fit: BoxFit.cover),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cliente!['nombre'].substring(0, 1).toUpperCase(),
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
                        cliente!["nombre"],
                        () => mostrarDialogoTexto("nombre", _nombreControler),
                      ),
                      const Divider(),
                      filaEditable(
                        Icons.badge,
                        cliente!['tipo_documento'] ?? "Documento",
                        cliente!['documento_oficial'],
                        () => showDialog(context: context, builder: (context) => _ventanaCambioDocumento(idCliente)),
                      ),
                      const Divider(),
                      filaEditable(
                        Icons.phone,
                        "Teléfono",
                        cliente!['telefono'],
                        () => mostrarDialogoTexto("telefono", _telefonoControler, esTelefono: true),
                      ),
                      const Divider(),
                      filaEditable(
                        Icons.location_on,
                        "Dirección",
                        cliente!['direccion'],
                        () => mostrarDialogoTexto("direccion", _direccionControler),
                      ),
                      const Divider(),
                      filaEditable(
                        Icons.email,
                        "Email",
                        cliente!['email'] ?? "Sin correo",
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

                  if (formKey.currentState!.validate()) {
                    String valorFinal = esTelefono ? telefonoCompleto : controller.text;
                    await actualizarCliente(campo, valorFinal);
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
          DropdownMenu<String>(
            width: double.infinity,
            initialSelection: _tipoDocumento,
            dropdownMenuEntries: ["DNI", "NIE", "Pasaporte"].map((tipo) {
              return DropdownMenuEntry(
                value: tipo,
                label: tipo,
                labelWidget: Text(tipo, style: const TextStyle(color: Color(0xFFC8A97E))),
              );
            }).toList(),
            onSelected: (nuevoTipoDocumento) {
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

                final db = await DatabaseHelper.proyectodb();
                await db.update(
                  "clientes",
                  {"tipo_documento": _tipoDocumento, "documento_oficial": valor},
                  where: "id = ?",
                  whereArgs: [idCliente],
                );

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
