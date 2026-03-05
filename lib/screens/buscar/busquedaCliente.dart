import 'package:flutter/material.dart';

import '../../database.dart';

class PantallaBusquedaCliente extends StatefulWidget {
  const PantallaBusquedaCliente({super.key});

  @override
  State<PantallaBusquedaCliente> createState() =>
      _PantallaBusquedaClienteState();
}

class _PantallaBusquedaClienteState extends State<PantallaBusquedaCliente> {
  late TextEditingController _dniController;

  Future<List<Map<String, dynamic>>> cargarClientes() async {
    final baseDatos = await DatabaseHelper.proyectodb();

    final List<Map<String, dynamic>> clientes = await baseDatos.query(
      "clientes",
    );
    return clientes;
  }

  @override
  void initState() {
    super.initState();
    _dniController = TextEditingController();
  }

  @override
  void dispose() {
    _dniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de clientes"),
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
        child: Column(
          children: [
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dniController,
                    decoration: InputDecoration(
                      labelText: "DNI",
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Buscar'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: cargarClientes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No hay clientes"));
                  }

                  // Filtrado por DNI según lo escrito en el TextField
                  final filtro = _dniController.text.toLowerCase();
                  final clientesFiltrados = snapshot.data!.where((cliente) {
                    final dni = cliente['dni']?.toString().toLowerCase() ?? '';
                    return dni.startsWith(filtro);
                  }).toList();

                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: clientesFiltrados.length,
                    itemBuilder: (context, index) {
                      final cliente = clientesFiltrados[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(cliente['nombre'] ?? 'Sin nombre'),
                        subtitle: Text(cliente['dni'] ?? 'Sin DNI'),
                        onTap: (){
                          Navigator.pushNamed(context, "detalles_cliente", arguments: cliente);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
