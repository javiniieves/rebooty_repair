import 'package:flutter/material.dart';

import '../../database.dart';

class DetallesClienteScreen extends StatefulWidget {
  const DetallesClienteScreen({super.key});

  @override
  State<DetallesClienteScreen> createState() => _DetallesClienteScreenState();
}

class _DetallesClienteScreenState extends State<DetallesClienteScreen> {
  final _nombreControler = TextEditingController();
  final _dniControler = TextEditingController();
  final _telefonoControler = TextEditingController();
  final _direccionControler = TextEditingController();
  final _correoControler = TextEditingController();

  Map<String, dynamic>? cliente;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    int idCliente = ModalRoute.of(context)?.settings.arguments as int;

    cargarDatosCliente(idCliente);
  }

  // metodo encargado de rellenar la variable vehiculo con
  // los datos del coche con el id recibido por parametro
  Future<void> cargarDatosCliente(int idCliente) async {
    final clienteConIdRecibido = await DatabaseHelper.obtenerClientesPorId(idCliente);

    setState(() {
      cliente = clienteConIdRecibido.first;
    });
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
                  cliente!['nombre'][0],
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
                            Expanded(child: _infoRow(Icons.badge, "DNI", cliente!['dni'])),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => _ventanaCambio(cliente!["id"], "dni", _dniControler),
                                );
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.phone, "Telefono", cliente!['telefono'])),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => _ventanaCambio(cliente!["id"], "telefono", _telefonoControler),
                                );
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.location_on, "Direccion", cliente!['direccion'])),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      _ventanaCambio(cliente!["id"], "direccion", _direccionControler),
                                );
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.email, "Email", cliente!['email'])),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      _ventanaCambio(cliente!["id"], "email", _correoControler),
                                );
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),
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

  Widget _infoRow(IconData icon, String titulo, String valor) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 15),
        Expanded(child: Text("$titulo: $valor", style: const TextStyle(fontSize: 17))),
      ],
    );
  }

  Widget _ventanaCambio(int idCliente, String campoACambiar, TextEditingController controllerCampoACambiar) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text("Actualizar $campoACambiar"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Introduce el nuevo valor para el campo:"),
          const SizedBox(height: 15),
          TextFormField(
            style: const TextStyle(color: Color(0xFFC8A97E)),
            controller: controllerCampoACambiar,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: "Escribe aquí...",
            ),
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
                final baseDatos = await DatabaseHelper.proyectodb();

                await baseDatos.update(
                  "clientes",
                  {campoACambiar: controllerCampoACambiar.text},
                  where: "id = ?",
                  whereArgs: [idCliente],
                );

                controllerCampoACambiar.clear();

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
}
