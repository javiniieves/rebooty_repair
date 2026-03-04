import 'package:flutter/material.dart';
import 'package:rebooty_repair/database.dart';

class PantallaVehiculos extends StatefulWidget {
  const PantallaVehiculos({super.key});

  @override
  State<PantallaVehiculos> createState() => _PantallaVehiculosState();
}

class _PantallaVehiculosState extends State<PantallaVehiculos> {
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
      appBar: AppBar(title: Text("Añade un nuevo vehículo"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),

              // introducir matricula
              TextField(
                controller: _matriculaController,
                decoration: InputDecoration(labelText: "Matricula"),
              ),

              SizedBox(height: 20),

              // introducir marca
              TextField(
                controller: _marcaController,
                decoration: InputDecoration(labelText: "Marca"),
              ),

              SizedBox(height: 20),

              // introducir modelo
              TextField(
                controller: _modeloController,
                decoration: InputDecoration(labelText: "Modelo"),
              ),

              SizedBox(height: 20),

              // elegir estado del coche
              DropdownButtonFormField(
                // el valor será la variable que indica el estado actual del coche
                value: estadoActual,

                decoration: InputDecoration(labelText: "Estado"),

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

              SizedBox(height: 50),

              // TODO: validaciones campos
              // botón de añadir coche
              ElevatedButton.icon(
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
                },
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(Icons.save), SizedBox(width: 10,), Text("Guardar")],
                ),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 24, color: Colors.black),
                  iconSize: 24,
                  iconColor: Colors.black,

                  shape: RoundedRectangleBorder(side: BorderSide())
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
