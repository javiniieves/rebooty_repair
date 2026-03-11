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
                        backgroundColor: Colors.black,
                        title: Text(
                          "¿Estás seguro de que quiere borrar TODOS los registros de la base de datos?",
                          style: TextStyle(color: Colors.white),
                        ),

                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.red,

                                      title: Text(
                                        "Está apunto de ELIMINAR para SIEMPRE la base de datos ¿Está seguro de que quiere eliminarla?)",
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                      ),

                                      content: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              await DatabaseHelper.limpiarRegistrosBaseDatos();

                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("Registros de la base de datos borrados con éxito"),
                                                ),
                                              );

                                              Navigator.pop(context);
                                            },
                                            label: Row(
                                              children: [
                                                Icon(Icons.delete_forever, color: Colors.white),
                                                Text(
                                                  "Si, eliminar para siempre",
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),

                                          SizedBox(width: 40,),

                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            label: Row(
                                              children: [
                                                Icon(Icons.back_hand, color: Colors.white),
                                                Text("No borrar y volver atrás", style: TextStyle(color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              label: Row(
                                children: [
                                  Icon(Icons.check, color: Colors.red),
                                  Text("Confirmar", style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),

                            SizedBox(width: 50),

                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              label: Row(
                                children: [
                                  Icon(Icons.cancel_outlined, color: Colors.white),
                                  Text("Cancelar", style: TextStyle(color: Colors.white)),
                                ],
                              ),
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
