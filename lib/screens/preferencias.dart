import 'package:flutter/material.dart';
import 'package:rebooty_repair/DataBaseHelper.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class PantallaPreferencias extends StatefulWidget {
  const PantallaPreferencias({super.key});

  @override
  State<PantallaPreferencias> createState() => _PantallaPreferenciasState();
}

class _PantallaPreferenciasState extends State<PantallaPreferencias> {
  // Controladores para las fechas de contabilidad
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();

  // Mapa para guardar los resultados de la consulta
  Map<String, double> ganancias = {"Efectivo": 0.0, "Tarjeta": 0.0, "Transferencia": 0.0};

  // Metodo para calcular ingresos
  Future<void> _consultarIngresos() async {
    if (_fechaInicioController.text.isEmpty || _fechaFinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecciona ambas fechas para filtrar")));
      return;
    }

    final resultados = await DatabaseHelper.obtenerContabilidadPorFechas(
      _fechaInicioController.text,
      _fechaFinController.text,
    );

    setState(() {
      ganancias = resultados;
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalGeneral = ganancias.values.fold(0, (sum, item) => sum + item);

    return Scaffold(
      appBar: AppBar(title: const Text("Configuración y Base de Datos"), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0), // Ajustado padding lateral
          child: Column(
            children: [
              // --- SECCIÓN DE CONTABILIDAD ---
              const Row(
                children: [
                  Icon(Icons.analytics_outlined, size: 30),
                  SizedBox(width: 15),
                  Text("Contabilidad", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _campoFecha(_fechaInicioController, "Desde")),
                  const SizedBox(width: 10),
                  Expanded(child: _campoFecha(_fechaFinController, "Hasta")),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), // Reducido para móvil
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _consultarIngresos,
                    child: const Icon(Icons.search, size: 25),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Tarjetas de ingresos
              _cardIngreso("Efectivo", ganancias["Efectivo"]!, Colors.green, Icons.money),
              const SizedBox(height: 12),
              _cardIngreso("Tarjeta", ganancias["Tarjeta"]!, Colors.blue, Icons.credit_card),
              const SizedBox(height: 12),
              _cardIngreso(
                "Transferencia",
                ganancias["Transferencia"]!,
                Colors.orange,
                Icons.account_balance,
              ),
              const SizedBox(height: 12),
              _cardIngreso("TOTAL GENERAL", totalGeneral, Colors.deepPurple, Icons.summarize),

              const SizedBox(height: 40),
              const Divider(thickness: 2),
              const SizedBox(height: 40),

              // --- BOTONES BASE DE DATOS ---
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botón de Importar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        side: const BorderSide(color: Colors.blue, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () async {
                        bool importado = await DatabaseHelper.importarBD();
                        if (importado) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Base de datos importada. La app se cerrará para aplicar los cambios."),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.green,
                            ),
                          );

                          await Future.delayed(const Duration(seconds: 2));

                          if (Platform.isAndroid || Platform.isIOS) {
                            SystemNavigator.pop();
                          } else {
                            exit(0);
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("No se seleccionó ningún archivo o hubo un error")),
                            );
                          }
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Centrado para estética
                        children: [
                          Icon(Icons.upload_file, size: 30),
                          SizedBox(width: 15),
                          Flexible(child: Text("Importar base de datos", style: TextStyle(fontSize: 18))), // Flexible añadido
                        ],
                      ),
                    ),

                    const SizedBox(height: 30), // Espaciado ajustado

                    // Botón de Exportar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud, size: 30),
                          SizedBox(width: 15),
                          Flexible(child: Text("Exportar base de datos", style: TextStyle(fontSize: 18))), // Flexible añadido
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Botón de Borrado
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () => _mostrarDialogoConfirmacion(context),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, size: 30),
                          SizedBox(width: 15),
                          Flexible(child: Text("Borrar todos los registros", style: TextStyle(fontSize: 18))), // Flexible añadido
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widgets auxiliares para las fechas y tarjetas
  Widget _campoFecha(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: const TextStyle(fontSize: 14), // Texto más pequeño para que quepa la fecha
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        prefixIcon: const Icon(Icons.calendar_month, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() {
            controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          });
        }
      },
    );
  }

  Widget _cardIngreso(String titulo, double valor, Color color, IconData icono) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( // Para que el texto no empuje el valor fuera de la pantalla
            child: Row(
              children: [
                Icon(icono, color: color, size: 24),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    titulo,
                    style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${valor.toStringAsFixed(2)} €",
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Los métodos de diálogo permanecen igual, no afectan al layout principal
  void _mostrarDialogoConfirmacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "¿Estás seguro de que quiere borrar TODOS los registros de la base de datos?",
            style: TextStyle(color: Colors.white, fontSize: 18),
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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
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
                  Navigator.pop(context);
                  Navigator.pop(context);
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