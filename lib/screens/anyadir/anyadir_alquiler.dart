import 'package:flutter/material.dart';
import 'package:rebooty_repair/database.dart';

class PantallaAnyadirAlquiler extends StatefulWidget {
  const PantallaAnyadirAlquiler({super.key});

  @override
  State<PantallaAnyadirAlquiler> createState() => _PantallaAnyadirAlquilerState();
}

class _PantallaAnyadirAlquilerState extends State<PantallaAnyadirAlquiler> {
  final _formKey = GlobalKey<FormState>();

  String? _idClienteSeleccionado;
  String? _idVehiculoSeleccionado;

  List<String> listaIdsClientes = [];
  List<String> listaIdsVehiculos = [];

  final _precioController = TextEditingController();

  DateTime? fechaInicio;
  DateTime? fechaFin;
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();

  String estadoActual = "Pendiente";

  Future<void> cargarIdsClientes() async {
    final baseDatos = await DatabaseHelper.proyectodb();

    final List<Map<String, dynamic>> clientes = await baseDatos.query("clientes");

    // convertimos cada cliente a un String con su dni
    // una vez todos convertidos, actualizamos la lista con los id de los clientes
    setState(() {
      listaIdsClientes = clientes.map((clienteActual) => clienteActual["id"].toString()).toList();
    });
  }

  Future<void> cargarIdsVehiculos() async {
    // vehículos disponibles
    final List<Map<String, dynamic>> vehiculos = await DatabaseHelper.obtenerVehiculosDisponibles();

    // convertimos cada cliente a un String con su dni
    // una vez todos convertidos, actualizamos la lista con los id de los clientes
    setState(() {
      listaIdsVehiculos = vehiculos.map((vehiculoActual) => vehiculoActual["id"].toString()).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    cargarIdsClientes();
    cargarIdsVehiculos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Añade un nuevo alquiler"),
        centerTitle: true,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left_outlined)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // menú con los ids de los cliente disponibles
              DropdownButtonFormField(
                value: _idClienteSeleccionado,
                decoration: InputDecoration(
                  labelText: "Id del cliente",
                  prefixIcon: const Icon(Icons.person_search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                dropdownColor: Theme.of(context).colorScheme.primary,
                items: listaIdsClientes.map((idActual) {
                  return DropdownMenuItem(value: idActual, child: Text(idActual, style: TextStyle(color: Theme.of(context).colorScheme.tertiary)));
                }).toList(),
                onChanged: (nuevoId) {
                  setState(() {
                    _idClienteSeleccionado = nuevoId;
                  });
                },
                // Validación para asegurar que se elija un cliente
                validator: (value) => value == null ? "Selecciona un cliente" : null,
              ),

              const SizedBox(height: 25),

              // menú con los ids de los vehiculos disponibles
              DropdownButtonFormField(
                value: _idVehiculoSeleccionado,
                decoration: InputDecoration(
                  labelText: "Id del vehículo",
                  prefixIcon: const Icon(Icons.car_rental),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                dropdownColor: Theme.of(context).colorScheme.primary,
                items: listaIdsVehiculos.map((idActual) {
                  return DropdownMenuItem(value: idActual, child: Text(idActual, style: TextStyle(color: Theme.of(context).colorScheme.tertiary)));
                }).toList(),
                onChanged: (nuevoId) {
                  setState(() {
                    _idVehiculoSeleccionado = nuevoId;
                  });
                },
                // Validación para asegurar que se elija un vehículo
                validator: (value) => value == null ? "Selecciona un vehículo" : null,
              ),

              const SizedBox(height: 25),

              // elegir fecha inicio
              TextFormField(
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                controller: _fechaInicioController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Fecha inicio",
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onTap: () => seleccionarFecha(true),
                // Validación de fecha obligatoria
                validator: (value) => (value == null || value.isEmpty) ? "Selecciona la fecha de inicio" : null,
              ),

              const SizedBox(height: 25),

              // elegir fecha fin
              TextFormField(
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                controller: _fechaFinController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Fecha fin",
                  prefixIcon: const Icon(Icons.event_available),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onTap: () => seleccionarFecha(false),
                // Validación de fecha obligatoria y coherencia temporal
                validator: (value) {
                  if (value == null || value.isEmpty) return "Selecciona la fecha de fin";
                  if (fechaInicio != null && fechaFin != null) {
                    if (fechaFin!.isBefore(fechaInicio!)) {
                      return "La fecha de fin no puede ser anterior al inicio";
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              // introducir precio
              TextFormField(
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Precio",
                  prefixIcon: const Icon(Icons.price_check_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  // Comprobamos si el precio está vacío
                  if (value == null || value.isEmpty) {
                    return "Por favor, introduce un precio";
                  }

                  // Intentamos convertirlo a número
                  final numero = double.tryParse(value);

                  // Si el resultado es null, es que no es un número válido
                  if (numero == null) {
                    return "Introduce un número válido (ej: 10.50)";
                  }

                  // Validación extra: precio no negativo
                  if (numero < 0) {
                    return "El precio no puede ser negativo";
                  }

                  // Si está bien, devolvemos null
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // elegir estado del alquiler
              DropdownButtonFormField(
                // el valor será la variable que indica el estado actual del coche
                value: estadoActual,

                decoration: InputDecoration(
                  labelText: "Estado",
                  prefixIcon: const Icon(Icons.info_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                dropdownColor: Theme.of(context).colorScheme.primary,
                // el desplegable tiene 3 estado a elegir
                // cada uno de esos estados lo mapeamos para crearlo como DropdownMenuItem
                // su valor y es el mismo que su texto (ej: "Pendiente", "Terminado"...)
                items: ["Pendiente", "En proceso", "Terminado"].map((estadoActual) {
                  return DropdownMenuItem(
                    value: estadoActual,
                    child: Text(estadoActual, style: TextStyle(color: Theme.of(context).colorScheme.tertiary),),
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

              const SizedBox(height: 50),

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
                        "id_coche": _idVehiculoSeleccionado,
                        "id_cliente": _idClienteSeleccionado,
                        "precio": double.parse(_precioController.text),
                        "fecha_inicio": _fechaInicioController.text,
                        "fecha_fin": _fechaFinController.text,
                        "estado": estadoActual,
                      });

                      // cambiar estado del coche a alquilado
                      await baseDatos.update(
                        "vehiculos",
                        {"estado": "Alquilado"},
                        where: "id = ?",
                        whereArgs: [_idVehiculoSeleccionado],
                      );

                      _precioController.clear();

                      // Aviso de éxito
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text("Alquiler guardado correctamente")));

                        // Volvemos atrás después de guardar
                        Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("GUARDAR ALQUILER"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  /// metodo para elegir una fecha
  Future<void> seleccionarFecha(bool esInicio) async {
    DateTime fechaHoy = DateTime.now();

    // dejamos que el usuario elija la fecha y la guardamos esa fecha
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      // el día en el que se abrirá el calendario
      // si no ha escogido fecha de inicio es el dia de hoy
      // si ya la ha elegido (es porque va a rellenar la fecha de fin)
      // por lo que mostramos es calendario a partir de la fecha de inicio
      initialDate: esInicio ? (fechaInicio ?? fechaHoy) : (fechaFin ?? fechaInicio ?? fechaHoy),
      firstDate: DateTime(2024),
      // limite es dentro de 5 años
      lastDate: fechaHoy.add(const Duration(days: 365 * 5)),
    );

    if (fechaElegida != null) {
      setState(() {
        // Guardamos la fecha y la formateamos para el texto (Año-Mes-Día)
        String fechaFormateada = "${fechaElegida.year}-${fechaElegida.month.toString().padLeft(2, '0')}-${fechaElegida.day.toString().padLeft(2, '0')}";

        if (esInicio) {
          fechaInicio = fechaElegida;
          _fechaInicioController.text = fechaFormateada;
          // Si la fecha de fin es anterior a la nueva fecha de inicio, la reseteamos
          if (fechaFin != null && fechaFin!.isBefore(fechaInicio!)) {
            fechaFin = null;
            _fechaFinController.clear();
          }
        } else {
          fechaFin = fechaElegida;
          _fechaFinController.text = fechaFormateada;
        }
      });
    }
  }
}