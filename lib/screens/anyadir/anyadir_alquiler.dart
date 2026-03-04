import 'package:flutter/material.dart';
import 'package:rebooty_repair/database.dart';

class PantallaAnyadirAlquiler extends StatefulWidget {
  const PantallaAnyadirAlquiler({super.key});

  @override
  State<PantallaAnyadirAlquiler> createState() =>
      _PantallaAnyadirAlquilerState();
}

class _PantallaAnyadirAlquilerState extends State<PantallaAnyadirAlquiler> {
  late String _idClienteSeleccionado;
  late String _idVehiculoSeleccionado;
  final _precioController = TextEditingController();
  List<String> listaIdsClientes = [];

  Future<void> cargarDnis() async {
    final baseDatos = await DatabaseHelper.proyectodb();

    final List<Map<String, dynamic>> clientes = await baseDatos.query(
      "clientes",
    );

    // convertimos cada cliente a un String con su dni
    // una vez todos convertidos, actualizamos la lista con los id de los clientes
    setState(() {
      listaIdsClientes = clientes
          .map((clienteActual) => clienteActual["id"].toString())
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    cargarDnis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Añade un nuevo alquiler"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.chevron_left_outlined),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            DropdownButtonFormField(
              value: _idClienteSeleccionado,
              decoration: InputDecoration(labelText: "Id de los clientes"),
              items: listaIdsClientes,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }
}
