import 'package:flutter/material.dart';
import '../../database.dart';

class PantallaAnyadirClientes extends StatefulWidget {
  const PantallaAnyadirClientes({super.key});

  @override
  State<PantallaAnyadirClientes> createState() =>
      _PantallaAnyadirClientesState();
}

class _PantallaAnyadirClientesState extends State<PantallaAnyadirClientes> {

  late final _formKey;

  late TextEditingController _nombreController;
  late TextEditingController _dniController;
  late TextEditingController _telefonoController;

  // estado por defecto al añadir un coche
  String estadoActual = "Disponible";

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _dniController = TextEditingController();
    _telefonoController = TextEditingController();

    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Añade un nuevo Cliente"),
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

                // introducir nombre
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: "Nombre",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 30),

                // introducir DNI
                TextField(
                  controller: _dniController,
                  decoration: InputDecoration(
                    labelText: "DNI",
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 30),

                // introducir teléfono
                TextField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone, // Abre el teclado numérico en móviles
                  decoration: InputDecoration(
                    labelText: "Teléfono",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 100), // Reducido para que no quede tan lejos en pantallas pequeñas

                // TODO: validaciones campos
                // botón de añadir cliente
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // guardamos la base de datos
                      final baseDatos = await DatabaseHelper.proyectodb();

                      // insertamos en la tabal "clientes" los datos que hemos cogido
                      await baseDatos.insert("clientes", {
                        "nombre": _nombreController.text,
                        "dni": _dniController.text,
                        "telefono": _telefonoController.text,
                      });

                      _nombreController.clear();
                      _dniController.clear();
                      _telefonoController.clear();

                      // Aviso de éxito
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cliente guardado correctamente")),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("GUARDAR CLIENTE"),
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