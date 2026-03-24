import 'package:flutter/material.dart';
import 'package:rebooty_repair/models/Multa.dart';
import '../../DataBaseHelper.dart';

class PantallaAnyadirMulta extends StatefulWidget {
  final int idAlquiler; // Recibe el id del alquiler por parámetro

  const PantallaAnyadirMulta({super.key, required this.idAlquiler});

  @override
  State<PantallaAnyadirMulta> createState() => _PantallaAnyadirMultaState();
}

class _PantallaAnyadirMultaState extends State<PantallaAnyadirMulta> {
  final _formKey = GlobalKey<FormState>();

  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _fechaController = TextEditingController();
  final _fechaLimiteController = TextEditingController();

  DateTime? fechaMulta;
  DateTime? fechaLimite;

  // 0 para no pagada, 1 para si pagada
  int pagada = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Añadir Multa al Alquiler #${widget.idAlquiler}"),
        centerTitle: true,
        leading: IconButton(onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("¿Desea guardar los datos que ha introducido?"),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _guardarMulta();
                      },
                      label: const Row(children: [Icon(Icons.check), Text("Confirmar")]),
                    ),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
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
            icon: const Icon(Icons.chevron_left_outlined)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Descripción de la multa
              TextFormField(
                style: TextStyle(color: Theme
                    .of(context)
                    .colorScheme
                    .tertiary),
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: "Descripción de la multa",
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => (value == null || value.isEmpty) ? "Introduce una descripción" : null,
              ),

              const SizedBox(height: 25),

              // Introducir precio/importe
              TextFormField(
                style: TextStyle(color: Theme
                    .of(context)
                    .colorScheme
                    .tertiary),
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Importe de la multa",
                  prefixIcon: const Icon(Icons.monetization_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Introduce el importe";
                  if (double.tryParse(value) == null) return "Introduce un número válido";
                  return null;
                },
              ),

              const SizedBox(height: 25),

              // Elegir fecha de la multa
              TextFormField(
                style: TextStyle(color: Theme
                    .of(context)
                    .colorScheme
                    .tertiary),
                controller: _fechaController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Fecha de la multa",
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onTap: () => seleccionarFecha(true),
                validator: (value) => (value == null || value.isEmpty) ? "Selecciona la fecha" : null,
              ),

              const SizedBox(height: 25),

              // Elegir fecha límite de pago
              TextFormField(
                style: TextStyle(color: Theme
                    .of(context)
                    .colorScheme
                    .tertiary),
                controller: _fechaLimiteController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Fecha límite de pago",
                  prefixIcon: const Icon(Icons.event_busy),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onTap: () => seleccionarFecha(false),
                validator: (value) => (value == null || value.isEmpty) ? "Selecciona la fecha límite" : null,
              ),

              const SizedBox(height: 25),

              // Dropdown para indicar si está pagada
              DropdownButtonFormField<int>(
                value: pagada,
                decoration: InputDecoration(
                  labelText: "¿Está pagada?",
                  prefixIcon: Icon(Icons.payment),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                dropdownColor: Theme
                    .of(context)
                    .colorScheme
                    .primary,
                items: [
                  DropdownMenuItem(value: 0, child: Text("No pagada")),
                  DropdownMenuItem(value: 1, child: Text("Sí, pagada")),
                ],
                onChanged: (nuevoValor) {
                  setState(() {
                    pagada = nuevoValor!;
                  });
                },
              ),

              const SizedBox(height: 50),

              // Botón de guardar multa
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _guardarMulta();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("GUARDAR MULTA"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardarMulta() async {
    if (!_formKey.currentState!.validate()) return;

    final multa = Multa(idAlquiler: widget.idAlquiler,
        descripcion: _descripcionController.text,
        fecha: _fechaController.text,
        fechaLimite: _fechaLimiteController.text,
        precio: double.parse(_precioController.text),
        pagada: pagada);

    await DatabaseHelper.instance.insertarMulta(multa);

    /*await baseDatos.insert("multas", {
      "id_alquiler": widget.idAlquiler,
      "descripcion": _descripcionController.text,
      "fecha": _fechaController.text,
      "fecha_limite": _fechaLimiteController.text,
      "precio": double.parse(_precioController.text),
      "pagada": pagada,
    });*/

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Multa añadida correctamente")));
    Navigator.pop(context);
  }

  Future<void> seleccionarFecha(bool esFechaMulta) async {
    DateTime fechaHoy = DateTime.now();

    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: fechaHoy,
      firstDate: DateTime(2024),
      lastDate: fechaHoy.add(const Duration(days: 365 * 2)),
    );

    if (fechaElegida != null) {
      setState(() {
        String fechaFormateada =
            "${fechaElegida.year}-${fechaElegida.month.toString().padLeft(2, '0')}-${fechaElegida.day
            .toString()
            .padLeft(2, '0')}";

        if (esFechaMulta) {
          fechaMulta = fechaElegida;
          _fechaController.text = fechaFormateada;
        } else {
          fechaLimite = fechaElegida;
          _fechaLimiteController.text = fechaFormateada;
        }
      });
    }
  }
}
