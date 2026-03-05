import 'package:flutter/material.dart';

class DetallesClienteScreen extends StatefulWidget {
  const DetallesClienteScreen({super.key});

  @override
  State<DetallesClienteScreen> createState() => _DetallesClienteScreenState();
}

class _DetallesClienteScreenState extends State<DetallesClienteScreen> {
  @override
  Widget build(BuildContext context) {
    final cliente =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

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
          "Detalles del Cliente",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Avatar
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.deepPurple,
                child: Text(
                  cliente['nombre'][0],
                  style: const TextStyle(
                    fontSize: 35,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Nombre
              Text(
                cliente['nombre'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

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
                        _infoRow(Icons.badge, "DNI", cliente['dni']),
                        const Divider(),
                        _infoRow(Icons.phone, "Teléfono", cliente['telefono']),
                        const Divider(),
                        _infoRow(Icons.location_on, "Dirección",
                            cliente['direccion']),
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