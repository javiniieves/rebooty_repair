import 'package:flutter/material.dart';

import '../../database.dart';

class PantallaBusquedaAlquiler extends StatefulWidget {
  const PantallaBusquedaAlquiler({super.key});

  @override
  State<PantallaBusquedaAlquiler> createState() =>
      _PantallaBusquedaAlquilerState();
}

class _PantallaBusquedaAlquilerState extends State<PantallaBusquedaAlquiler> {
  late TextEditingController _idController;

  Future<List<Map<String, dynamic>>> cargarAlquileres() async {
    final baseDatos = await DatabaseHelper.proyectodb();

    final alquileres = await baseDatos.rawQuery('''
    SELECT alquileres.*, vehiculos.matricula
    FROM alquileres
    INNER JOIN vehiculos
    ON alquileres.id_coche = vehiculos.id
    ''');
    return alquileres;
  }

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController();
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de Alquileres"),
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
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: "Matricula",
                      prefixIcon: const Icon(Icons.car_rental),
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
                future: cargarAlquileres(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No hay registros"));
                  }

                  // Filtrado por DNI según lo escrito en el TextField
                  final filtro = _idController.text.toLowerCase();
                  final alquileresFiltrados = snapshot.data!.where((alquiler) {
                    final id = alquiler['id']?.toString().toLowerCase() ?? '';
                    return id.startsWith(filtro);
                  }).toList();

                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: alquileresFiltrados.length,
                    itemBuilder: (context, index) {
                      final alquiler = alquileresFiltrados[index];
                      return ListTile(
                        leading: const Icon(Icons.directions_car_filled),
                        title: Text(alquiler['matricula'] ?? 'Sin coche'),
                        subtitle: Text(alquiler['estado'] ?? 'Sin estado'),
                        onTap: (){
                          Navigator.pushNamed(context, "routeName");
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
