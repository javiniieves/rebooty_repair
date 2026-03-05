import 'package:flutter/material.dart';

class DetallesAlquilerScreen extends StatefulWidget {
  const DetallesAlquilerScreen({super.key});

  @override
  State<DetallesAlquilerScreen> createState() => _DetallesAlquilerScreenState();
}

class _DetallesAlquilerScreenState extends State<DetallesAlquilerScreen> {
  @override
  Widget build(BuildContext context) {
    final alquiler =
    ModalRoute
        .of(context)
        ?.settings
        .arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Detalles del Alquiler",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
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
                        _infoRow(Icons.date_range, "Fecha de inicio", alquiler['fecha_inicio']),
                        const Divider(),
                        _infoRow(Icons.date_range_outlined, "Fecha limite", alquiler['fecha_fin']),
                        const Divider(),
                        _infoRow(Icons.calendar_today, "Fecha de devolucion", alquiler['fecha_devolucion'] ?? 'no devuelto'),
                        const Divider(),
                        _infoRow(Icons.directions_car, "Estado de la devolucion", alquiler['estado']),
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
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            "$titulo: $valor",
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ],
    );
  }
}

