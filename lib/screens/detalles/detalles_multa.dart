import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rebooty_repair/database.dart';

class DetallesMultaScreen extends StatefulWidget {
  const DetallesMultaScreen({super.key});

  @override
  State<DetallesMultaScreen> createState() => _DetallesMultaScreenState();
}

class _DetallesMultaScreenState extends State<DetallesMultaScreen> {
  Map<String, dynamic> multa = {};

  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _fechaLimiteController = TextEditingController();
  int _pagadaStatus = 0; // 0 o 1
  late bool confirmar;

  Future<void> cargarMulta(int idMulta) async {
    final baseDatos = await DatabaseHelper.proyectodb();
    final List<Map<String, dynamic>> resultado = await baseDatos.query("multas", where: "id = ?", whereArgs: [idMulta]);

    if (resultado.isNotEmpty) {
      setState(() {
        multa = resultado.first;
        _descripcionController.text = multa['descripcion'] ?? "";
        _precioController.text = multa['precio'].toString();
        _fechaController.text = multa['fecha'] ?? "";
        _fechaLimiteController.text = multa['fecha_limite'] ?? "";
        _pagadaStatus = multa['pagada'] ?? 0;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recibimos el ID de la multa por los argumentos de la ruta
    int idMulta = ModalRoute.of(context)?.settings.arguments as int;
    cargarMulta(idMulta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
        title: const Text("Detalles de la Multa"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Card con información de los campos de la multa
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 180),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    child: Column(
                      children: [
                        // Descripción
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.description, "Descripción", _descripcionController)),
                            IconButton(
                              onPressed: () =>
                                  _ventanaCambioTexto("descripcion", "Descripción", _descripcionController),
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(height: 40),

                        // Precio / Importe
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.monetization_on, "Importe (€)", _precioController)),
                            IconButton(
                              onPressed: () =>
                                  _ventanaCambioTexto("precio", "Importe", _precioController, esNumero: true),
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(height: 40),

                        // Fecha de la multa
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.calendar_today, "Fecha de la multa", _fechaController)),
                            IconButton(
                              onPressed: () => _ventanaCambioFecha("fecha", _fechaController),
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(height: 40),

                        // Fecha límite
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.event_busy, "Fecha límite de pago", _fechaLimiteController)),
                            IconButton(
                              onPressed: () => _ventanaCambioFecha("fecha_limite", _fechaLimiteController),
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(height: 40),

                        // Estado del pago
                        Row(
                          children: [
                            Expanded(
                              child: _infoRowEstado(
                                Icons.payment,
                                "Estado del pago",
                                _pagadaStatus == 1 ? "Sí, pagada" : "No pagada",
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(context: context, builder: (context) => _ventanaCambioPago());
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Botón para eliminar la multa
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("¿Estás seguro de que quieres borrar esta multa?"),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                final baseDatos = await DatabaseHelper.proyectodb();
                                await baseDatos.delete("multas", where: "id = ?", whereArgs: [multa["id"]]);

                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(const SnackBar(content: Text("Multa eliminada con éxito")));

                                Navigator.pop(context); // Cierra el dialogo
                                Navigator.pop(context); // Vuelve a la pantalla anterior
                              },
                              label: const Row(children: [Icon(Icons.check), Text("Confirmar")]),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              label: const Row(children: [Icon(Icons.cancel_outlined), Text("Cancelar")]),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.delete_forever),
                label: const Text("Eliminar Multa", style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              Text(
                controller.text.isEmpty ? "Sin registrar" : controller.text,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRowEstado(IconData icon, String titulo, String estado) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              Text(estado, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _ventanaCambioTexto(
    String nombreCampo,
    String etiqueta,
    TextEditingController controller, {
    bool esNumero = false,
  }) async {
    TextEditingController tempController = TextEditingController(text: controller.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cambiar $etiqueta"),
        content: TextField(
          controller: tempController,
          keyboardType: esNumero ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(labelText: etiqueta),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          TextButton(
            onPressed: () async {
              confirmar = await confirmacion();
              if (!confirmar) return Navigator.pop(context);

              final baseDatos = await DatabaseHelper.proyectodb();
              dynamic nuevoValor = tempController.text;

              if (esNumero) {
                nuevoValor = double.tryParse(tempController.text) ?? 0.0;
              }

              await baseDatos.update("multas", {nombreCampo: nuevoValor}, where: "id = ?", whereArgs: [multa["id"]]);
              Navigator.pop(context);
              cargarMulta(multa["id"]);
            },
            child: const Text("GUARDAR"),
          ),
        ],
      ),
    );
  }

  Future<void> _ventanaCambioFecha(String nombreCampo, TextEditingController controllerFecha) async {
    DateTime fechaHoy = DateTime.now();

    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: fechaHoy,
      firstDate: DateTime(2024),
      lastDate: fechaHoy.add(const Duration(days: 365 * 5)),
    );

    if (fechaElegida != null) {
      String fechaFormateada =
          "${fechaElegida.year}-${fechaElegida.month.toString().padLeft(2, '0')}-${fechaElegida.day.toString().padLeft(2, '0')}";

      final baseDatos = await DatabaseHelper.proyectodb();

      await baseDatos.update("multas", {nombreCampo: fechaFormateada}, where: "id = ?", whereArgs: [multa["id"]]);

      cargarMulta(multa["id"]);
    }
  }

  Widget _ventanaCambioPago() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text("Actualizar Pago"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("¿Se ha realizado el pago de esta multa?"),
          SizedBox(height: 15),
          DropdownButtonFormField<int>(
            value: _pagadaStatus,
            decoration: InputDecoration(
              labelText: "Estado",
              prefixIcon: Icon(Icons.info_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: [
              DropdownMenuItem(value: 0, child: Text("No pagada")),
              DropdownMenuItem(value: 1, child: Text("Sí, pagada")),
            ],
            onChanged: (nuevoValor) async {
              confirmar = await confirmacion();
              if (!confirmar) return Navigator.pop(context);

              final baseDatos = await DatabaseHelper.proyectodb();
              await baseDatos.update("multas", {"pagada": nuevoValor}, where: "id = ?", whereArgs: [multa["id"]]);

              setState(() {
                _pagadaStatus = nuevoValor!;
                Navigator.pop(context);
                cargarMulta(multa["id"]);
              });
            },
          ),
        ],
      ),
    );
  }

  Future<bool> confirmacion() async {
    confirmar =
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Confirmar cambio"),
              content: const Text("¿Seguro que quieres actualizar estos datos?"),
              actions: [
                TextButton(
                  child: const Text("Cancelar"),
                  onPressed: () {Navigator.pop(context, false);},
                ),
                ElevatedButton(
                  child: const Text("Confirmar"),
                  onPressed: () {Navigator.pop(context, true);},
                ),
              ],
            );
          },
        ) ?? false;
    return confirmar;
  }
}
