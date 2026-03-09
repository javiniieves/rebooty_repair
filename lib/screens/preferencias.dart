import 'package:flutter/material.dart';
import 'package:rebooty_repair/database.dart';

class PantallaPreferencias extends StatefulWidget {
  const PantallaPreferencias({super.key});

  @override
  State<PantallaPreferencias> createState() => _PantallaPreferenciasState();
}

class _PantallaPreferenciasState extends State<PantallaPreferencias> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await DatabaseHelper.exportarBD();

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Base de datos exportada con éxito")));
                },
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud, size: 30),
                    SizedBox(width: 20),
                    Text("Exportar base de datos", style: TextStyle(fontSize: 30)),
                  ],
                ),
              ),

              SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("¿Estás seguro de que quiere borrar TODOS los registros de la base de datos?"),

                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                await DatabaseHelper.limpiarRegistrosBaseDatos();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Registros de la base de datos borrados con éxito")),
                                );

                                Navigator.pop(context);
                              },
                              label: Row(children: [Icon(Icons.check), Text("Confirmar")]),
                            ),

                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              label: Row(children: [Icon(Icons.cancel_outlined), Text("Cancelar")]),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete, size: 30),
                    SizedBox(width: 20),
                    Text("Borrar todos los registro de la base de datos", style: TextStyle(fontSize: 30)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
