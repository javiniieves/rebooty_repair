import 'package:flutter/material.dart';

class DetallesAlquilerScreen extends StatefulWidget {
  const DetallesAlquilerScreen({super.key});

  @override
  State<DetallesAlquilerScreen> createState() => _DetallesAlquilerScreenState();
}

class _DetallesAlquilerScreenState extends State<DetallesAlquilerScreen> {
  late TextEditingController fechaIniControler;
  late TextEditingController fechaLimitControler;
  late TextEditingController fechaDevControler;
  late TextEditingController estadoControler;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final alquiler =
    ModalRoute
        .of(context)
        ?.settings
        .arguments as Map<String, dynamic>;

    fechaIniControler = TextEditingController(text: alquiler['fecha_inicio']);
    fechaLimitControler = TextEditingController(text: alquiler['fecha_fin']);
    fechaDevControler = TextEditingController(text: alquiler['fecha_devolucion'] ?? 'no devuelto');
    estadoControler = TextEditingController(text: alquiler['estado']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          "Detalles del Alquiler",
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),

              // Card con información
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 180),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 25),
                    child: Column(
                      children: [
                        _infoRow(Icons.date_range, "Fecha de inicio", fechaIniControler),
                        const Divider(),
                        _infoRow(Icons.date_range_outlined, "Fecha limite", fechaLimitControler),
                        const Divider(),
                        _infoRow(Icons.calendar_today, "Fecha de devolucion", fechaDevControler),
                        const Divider(),
                        _infoRow(Icons.directions_car, "Estado de la devolucion", estadoControler),
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

  Widget _infoRow(IconData icon, String titulo, TextEditingController controller) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            "$titulo: ${controller.text}",
            style: const TextStyle(fontSize: 17),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            _editarCampo(titulo, controller);
          },
        )
      ],
    );
  }

  void _editarCampo(String titulo, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar $titulo"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: titulo,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Guardar"),
              onPressed: () {
                setState(() {});
                //_guardarEnBaseDeDatos();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}

