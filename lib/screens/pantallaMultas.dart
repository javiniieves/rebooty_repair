import 'package:flutter/material.dart';

import '../../database.dart';

class PantallaMultas extends StatefulWidget {
  const PantallaMultas({super.key});

  @override
  State<PantallaMultas> createState() => _PantallaMultasState();
}

class _PantallaMultasState extends State<PantallaMultas> {
  late TextEditingController _idController;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  Future<List<Map<String, dynamic>>> cargarAlquileres() async {
    final baseDatos = await DatabaseHelper.proyectodb();

    String query = '''
    SELECT alquileres.*, vehiculos.matricula
    FROM alquileres
    INNER JOIN vehiculos
    ON alquileres.id_coche = vehiculos.id
  ''';

    List<dynamic> args = [];

    // Filtrar por rango de fecha de inicio
    if (_fechaInicio != null && _fechaFin != null) {
      query += ' WHERE fecha_inicio AND fecha_fin BETWEEN ? AND ?';
      args.add(_fechaInicio!.toIso8601String().split('T')[0]);
      args.add(_fechaFin!.toIso8601String().split('T')[0]);
    }

    final alquileres = await baseDatos.rawQuery(query, args);
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
                  child: TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _fechaInicio ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _fechaInicio = picked;
                          });
                        }
                      },
                    child: Text(_fechaInicio == null
                        ? 'Fecha inicio'
                        : _fechaInicio!.toLocal().toString().split(' ')[0]),
                  )
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _fechaFin ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _fechaFin = picked;
                        });
                      }
                    },
                    child: Text(_fechaFin == null
                        ? 'Fecha fin'
                        : _fechaFin!.toLocal().toString().split(' ')[0]),
                  ),
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

                  final alquileresFiltrados = snapshot.data!;

                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: alquileresFiltrados.length,
                    itemBuilder: (context, index) {
                      final alquiler = alquileresFiltrados[index];
                      return ListTile(
                        leading: const Icon(Icons.directions_car_filled),
                        title: Text(alquiler['matricula'] ?? 'Sin coche'),
                        subtitle: Text(alquiler['estado'] ?? 'Sin estado'),
                        onTap: () async {
                          await Navigator.pushNamed(context, "detalles_alquiler", arguments: alquiler["id"]);

                          setState(() {});
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
