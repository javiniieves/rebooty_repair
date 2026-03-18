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
      appBar: AppBar(title: const Text("Configuración y Base de Datos"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón de Importar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  side: const BorderSide(color: Colors.blue, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  bool importado = await DatabaseHelper.importarBD();
                  if (importado) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Base de datos importada. Reinicia la app para ver los cambios."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text("No se seleccionó ningún archivo o hubo un error")));
                    }
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upload_file, size: 35),
                    SizedBox(width: 20),
                    Text("Importar base de datos", style: TextStyle(fontSize: 24)),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // Botón de Exportar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  bool exportado = await DatabaseHelper.exportarBD();

                  if (exportado) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("Base de datos exportada con éxito")));
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud, size: 35),
                    SizedBox(width: 20),
                    Text("Exportar base de datos", style: TextStyle(fontSize: 24)),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // Botón de Borrado
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  side: const BorderSide(color: Colors.red, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () => _mostrarDialogoConfirmacion(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete, size: 35),
                    SizedBox(width: 20),
                    Text("Borrar todos los registros", style: TextStyle(fontSize: 24)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoConfirmacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "¿Estás seguro de que quiere borrar TODOS los registros de la base de datos?",
            style: TextStyle(color: Colors.white),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton.icon(
              onPressed: () => _mostrarDialogoFinal(context),
              icon: const Icon(Icons.check, color: Colors.red),
              label: const Text("Confirmar", style: TextStyle(color: Colors.red)),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.cancel_outlined, color: Colors.white),
              label: const Text("Cancelar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoFinal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.red,
          title: const Text(
            "Está apunto de ELIMINAR para SIEMPRE la base de datos ¿Está seguro de que quiere eliminarla?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () async {
                await DatabaseHelper.limpiarRegistrosBaseDatos();
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Registros borrados con éxito")));
                  Navigator.pop(context); // Cierra este diálogo
                  Navigator.pop(context); // Cierra el anterior
                }
              },
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              label: const Text("Si, eliminar para siempre", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.back_hand),
              label: const Text("No borrar y volver atrás"),
            ),
          ],
        );
      },
    );
  }
}
