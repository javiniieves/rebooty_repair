import 'package:flutter/material.dart';
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

  Future<void> actualizarCliente(int idCliente, Map<String, dynamic> valores) async {
    final db = await DatabaseHelper.proyectodb();

    await db.update("clientes", valores, where: "id = ?", whereArgs: [idCliente]);
    cargarDatosCliente(idCliente);
  }

  @override
  Widget build(BuildContext context) {
    if (cliente == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Detalles del Cliente"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Avatar
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                radius: 35,
                child: Text(
                  cliente!['nombre'].substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Color(0xFF2F3136)),
                ),
              ),

              const SizedBox(height: 15),

              // Nombre
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cliente!['nombre'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _ventanaCambio(cliente!["id"], "nombre", _nombreControler),
                      );
                    },
                    icon: Icon(Icons.edit),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Card con información
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 180),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _infoRow(
                                Icons.badge,
                                cliente!['tipo_documento'] ?? "Documento",
                                cliente!['documento_oficial'],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => _ventanaCambioDocumento(cliente!["id"]),
                                );
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(),
                        _filaEditable(Icons.phone, "Telefono", cliente!['telefono'], _telefonoControler, "telefono"),
                        const Divider(),
                        _filaEditable(Icons.location_on, "Direccion", cliente!['direccion'], _direccionControler, "direccion",),
                        const Divider(),
                        _filaEditable(Icons.email, "Email", cliente!['email'] ?? "Sin correo", _correoControler, "email",),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaEditable(IconData icono, String titulo, String valor, TextEditingController controller, String campo) {
    return Row(
      children: [
        Expanded(child: _infoRow(icono, titulo, valor)),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            showDialog(context: context, builder: (_) => _ventanaCambio(cliente!["id"], campo, controller));
          },
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String titulo, String valor) {
    return Row(
      children: [
        Icon(icon),
        SizedBox(width: 15),
        Expanded(child: Text("$titulo: $valor", style: TextStyle(fontSize: 17))),
      ],
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
          // elegir tipo de documento
          DropdownButtonFormField<String>(
            value: _tipoDocumento,
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            items: ["DNI", "NIE", "Pasaporte"]
                .map(
                  (tipoDocumentoActual) =>
                      DropdownMenuItem(value: tipoDocumentoActual, child: Text(tipoDocumentoActual)),
                )
                .toList(),

            onChanged: (nuevoTipoDocumento) {
              setState(() {
                _tipoDocumento = nuevoTipoDocumento!;
                _documentoController.clear(); // al cambiar el tipo de docuemnto borramos lo escrito
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

          // botón para guardar los campos
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // al pulsarlo validamos si está cumple el tipo de documento
              // su patrón y si es así lo guardamos en la base de datos
              onPressed: () async {
                String valor = _documentoController.text.toUpperCase();

                // Comprobamos que no esté vacío
                if (valor.isEmpty) {
                  mostrarMensaje("¡No puedes dejar el documento vacío!");
                  return;
                }

                // Comprobamos que cumple el patrón según el tipo de docuemnto elegido
                if (_tipoDocumento == "DNI") {
                  // 8 números y 1 letra
                  if (!RegExp(r'^\d{8}[A-Z]$').hasMatch(valor)) {
                    mostrarMensaje("Formato DNI incorrecto (Ej: 12345678Z)");
                    return;
                  }
                } else if (_tipoDocumento == "NIE") {
                  // Letra inicial (XYZ), 7 números y letra final
                  if (!RegExp(r'^[XYZ]\d{7}[A-Z]$').hasMatch(valor)) {
                    mostrarMensaje("Formato NIE incorrecto (Ej: X1234567L)");
                    return;
                  }
                } else if (_tipoDocumento == "Pasaporte") {
                  // Para pasaportes, al menos que tenga una longitud razonable (ej: 6-9 caracteres)
                  if (valor.length < 6) {
                    mostrarMensaje("El pasaporte debe tener al menos 6 caracteres");
                    return;
                  }
                }

                confirmar = await confirmacion();
                if (!confirmar) return Navigator.pop(context);

                // Si ha pasado los filtros, guardamos
                final baseDatos = await DatabaseHelper.proyectodb();
                await baseDatos.update(
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

  Widget _ventanaCambio(int idCliente, String campoACambiar, TextEditingController controllerCampoACambiar) {
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text("Actualizar $campoACambiar"),

      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Introduce el nuevo valor para el campo:"),

            const SizedBox(height: 15),

            TextFormField(
              controller: controllerCampoACambiar,
              style: const TextStyle(color: Color(0xFFC8A97E)),

              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: "Escribe aquí...",
              ),

              validator: (value) {
                // Si es email permitimos vacío
                if (campoACambiar == "email") {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return "Email no válido";
                    }
                  }
                  return null;
                }
                if (campoACambiar == "telefono") {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return "Solo números";
                    }
                  }
                }
                // Para el resto de campos no permitimos vacío
                if (value == null || value.trim().isEmpty) {
                  return "Este campo no puede estar vacío";
                }
                return null;
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),

                onPressed: () async {

                  confirmar = await confirmacion();
                  if (!confirmar) return Navigator.pop(context);

                  // Validar formulario
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  await actualizarCliente(idCliente, {campoACambiar: controllerCampoACambiar.text});
                  controllerCampoACambiar.clear();
                  cargarDatosCliente(idCliente);
                  Navigator.pop(context);
                },
                child: const Text("GUARDAR CAMBIOS"),
              ),
            ),
          ],
        ),
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
                TextButton(
                  child: const Text("Cancelar"),
                  onPressed: () {Navigator.pop(context, false);},
                ),
                ElevatedButton(
                  child: const Text("Confirmar"),
                  onPressed: () {Navigator.pop(context, true);},
                ),
              ],
            );
          },
        ) ?? false;
    return confirmar;
  }
}
