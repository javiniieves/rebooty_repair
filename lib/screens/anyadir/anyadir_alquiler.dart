import 'package:flutter/material.dart';
import 'package:rebooty_repair/database.dart';

class PantallaAnyadirAlquiler extends StatefulWidget {
  const PantallaAnyadirAlquiler({super.key});

  @override
  State<PantallaAnyadirAlquiler> createState() =>
      _PantallaAnyadirAlquilerState();
}

class _PantallaAnyadirAlquilerState extends State<PantallaAnyadirAlquiler> {
  final _formKey = GlobalKey<FormState>();

  String? _idClienteSeleccionado;
  String? idVehiculoSeleccionado;

  List<String> listaIdsClientes = [];
  List<String> listaIdsVehiculos = [];

  final _precioController = TextEditingController();

  DateTime? fechaInicio;
  DateTime? fechaFin;
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();

  bool esInicio = true;

  Future<void> cargarIdsClientes() async {
    final baseDatos = await DatabaseHelper.proyectodb();

    final List<Map<String, dynamic>> clientes = await baseDatos.query(
      "clientes",
    );

    // convertimos cada cliente a un String con su dni
    // una vez todos convertidos, actualizamos la lista con los id de los clientes
    setState(() {
      listaIdsClientes = clientes
          .map((clienteActual) => clienteActual["id"].toString())
          .toList();
    });
  }

  Future<void> cargarIdsVehiculos() async {
    final baseDatos = await DatabaseHelper.proyectodb();

    // vehículos disponibles
    final List<Map<String, dynamic>> vehiculos = await baseDatos.query(
      "vehiculos",
      where: "estado = ?",
      whereArgs: ["Disponible"],
    );

    Future<void> seleccionarFecha() async {
      final DateTime? fechaElegida = await showDatePicker(
        context: context,
        firstDate: DateTime(2026),
        lastDate: DateTime(2027),
      );

      if (fechaElegida != null) {
        setState(() {
          // Guardamos la fecha y la formateamos para el texto (Año-Mes-Día)
          String fechaFormateada =
              "${fechaElegida.year}-${fechaElegida.month}-${fechaElegida.day}";

          if (esInicio) {
            fechaInicio = fechaElegida;
            _fechaInicioController.text = fechaFormateada;
          } else {
            fechaFin = fechaElegida;
            _fechaFinController.text = fechaFormateada;
          }
        });
      }
    }

    // convertimos cada cliente a un String con su dni
    // una vez todos convertidos, actualizamos la lista con los id de los clientes
    setState(() {
      listaIdsVehiculos = vehiculos
          .map((vehiculoActual) => vehiculoActual["id"].toString())
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    cargarIdsClientes();
    cargarIdsClientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Añade un nuevo alquiler"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.chevron_left_outlined),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // menú con los ids de los cliente disponibles
              DropdownButtonFormField(
                value: _idClienteSeleccionado,
                decoration: InputDecoration(labelText: "Id del cliente"),
                items: listaIdsClientes.map((idActual) {
                  return DropdownMenuItem(
                    value: idActual,
                    child: Text(idActual),
                  );
                }).toList(),
                onChanged: (nuevoId) {
                  setState(() {
                    _idClienteSeleccionado = nuevoId;
                  });
                },
              ),

              SizedBox(height: 50),

              // menú con los ids de los vehiculos disponibles
              DropdownButtonFormField(
                value: idVehiculoSeleccionado,
                decoration: InputDecoration(labelText: "Id del vehículo"),
                items: listaIdsVehiculos.map((idActual) {
                  return DropdownMenuItem(
                    value: idActual,
                    child: Text(idActual),
                  );
                }).toList(),
                onChanged: (nuevoId) {
                  setState(() {
                    idVehiculoSeleccionado = nuevoId;
                  });
                },
              ),

              SizedBox(height: 60),

              // introducir precio
              TextFormField(
                controller: _precioController,
                decoration: InputDecoration(
                  labelText: "Precio",
                  prefixIcon: const Icon(Icons.price_check_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                validator: (value) {
                  // Comprobamos si está vacío
                  if (value == null || value.isEmpty) {
                    return "Por favor, introduce un precio";
                  }

                  // Intentamos convertirlo a número
                  final numero = double.tryParse(value);

                  // Si el resultado es null, es que no es un número válido
                  if (numero == null) {
                    return "Introduce un número válido (ej: 10.50)";
                  }

                  // Si está bien, devolvemos null
                  return null;
                },
              ),

              // botón de añadir alquiler
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // guardamos la base de datos
                      final baseDatos = await DatabaseHelper.proyectodb();

                      // insertamos en la tabal "clientes" los datos que hemos cogido
                      await baseDatos.insert("alquileres", {
                        "id_coche": idVehiculoSeleccionado,
                        "id_cliente": _idClienteSeleccionado,
                        "precio": _precioController.text,
                        "fecha_inicio": _fechaInicioController.text,
                        "fecha_fin": _fechaFinController.text,
                      });
                      _precioController.clear();

                      // Aviso de éxito
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Alquiler guardado correctamente"),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("GUARDAR ALQUILER"),
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
    );
  }
}
