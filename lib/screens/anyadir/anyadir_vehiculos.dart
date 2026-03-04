import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rebooty_repair/database.dart';

class PantallaAnyadirVehiculos extends StatefulWidget {
  const PantallaAnyadirVehiculos({super.key});

  @override
  State<PantallaAnyadirVehiculos> createState() =>
      _PantallaAnyadirVehiculosState();
}

class _PantallaAnyadirVehiculosState extends State<PantallaAnyadirVehiculos> {
  late final _formKey;

  late TextEditingController _matriculaController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;

  // estado por defecto al añadir un coche
  String estadoActual = "Disponible";

  @override
  void initState() {
    super.initState();
    _matriculaController = TextEditingController();
    _marcaController = TextEditingController();
    _modeloController = TextEditingController();

    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _matriculaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Añade un nuevo vehículo"),
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // introducir matricula
                TextField(
                  controller: _matriculaController,
                  decoration: InputDecoration(
                    labelText: "Matricula",
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 30),

                // introducir marca
                TextField(
                  controller: _marcaController,
                  decoration: InputDecoration(
                    labelText: "Marca",
                    prefixIcon: const Icon(Icons.directions_car),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 30),

                // introducir modelo
                TextField(
                  controller: _modeloController,
                  decoration: InputDecoration(
                    labelText: "Modelo",
                    prefixIcon: const Icon(Icons.model_training),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 30),

                // elegir estado del coche
                DropdownButtonFormField(
                  // el valor será la variable que indica el estado actual del coche
                  value: estadoActual,

                  decoration: InputDecoration(
                    labelText: "Estado",
                    prefixIcon: const Icon(Icons.info_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),

                  // el desplegable tiene 3 estado a elegir
                  // cada uno de esos estados lo mapeamos para crearlo como DropdownMenuItem
                  // su valor y es el mismo que su texto (ej: "Alquilado", "Taller"...)
                  items: ["Disponible", "Alquilado", "Taller"].map((
                      estadoActual,
                      ) {
                    return DropdownMenuItem(
                      value: estadoActual,
                      child: Text(estadoActual),
                    );
                  }).toList(),
                  // convertimos a lista porque items nos pide la lista con los valores del DropdownButtonFormField

                  // al pulsar en uno de los desplegables del menú, actualizamos la variable con
                  // el estado actual del coche para que sea ahora el valor del desplegable pulsado
                  onChanged: (nuevoEstado) {
                    setState(() {
                      estadoActual = nuevoEstado!;
                    });
                  },
                ),

                const SizedBox(height: 60),

                // TODO: validaciones campos
                // botón de añadir coche
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // guardamos la base de datos
                      final baseDatos = await DatabaseHelper.proyectodb();

                      // insertamos en la tabal "vehiculos" el coche con los datos que hemos cogido
                      await baseDatos.insert("vehiculos", {
                        "matricula": _matriculaController.text,
                        "marca": _marcaController.text,
                        "modelo": _modeloController.text,
                        "estado": estadoActual,
                      });

                      _matriculaController.clear();
                      _marcaController.clear();
                      _modeloController.clear();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Vehículo guardado correctamente")),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("GUARDAR"),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}