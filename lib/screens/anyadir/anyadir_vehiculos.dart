import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rebooty_repair/database.dart';
import 'package:validators/validators.dart';

class PantallaAnyadirVehiculos extends StatefulWidget {
  const PantallaAnyadirVehiculos({super.key});

  @override
  State<PantallaAnyadirVehiculos> createState() => _PantallaAnyadirVehiculosState();
}

class _PantallaAnyadirVehiculosState extends State<PantallaAnyadirVehiculos> {
  late final _formKey;

  late TextEditingController _matriculaController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _kilometrajeController;
  late TextEditingController _anyoController;
  late TextEditingController _observacionesController;
  late TextEditingController _fechaController;

  // estado por defecto al añadir un coche
  String estadoActual = "Disponible";

  int colorDelVehiculo = Colors.white.value;

  String combustible = "Gasoil";

  DateTime? fechaVencimientoSeguro;

  @override
  void initState() {
    super.initState();
    _matriculaController = TextEditingController();
    _marcaController = TextEditingController();
    _modeloController = TextEditingController();
    _kilometrajeController = TextEditingController();
    _anyoController = TextEditingController();
    _observacionesController = TextEditingController();
    _fechaController = TextEditingController();

    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _matriculaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _kilometrajeController.dispose();
    _anyoController.dispose();
    _observacionesController.dispose();
    _fechaController.dispose();

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
                // introducir matricula
                TextFormField(
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  controller: _matriculaController,
                  decoration: InputDecoration(
                    labelText: "Matricula",
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  // Validación de matrícula
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Escribe la matrícula";
                    }
                    if (value.length < 4) {
                      return "Matrícula demasiado corta";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // introducir marca
                TextFormField(
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  controller: _marcaController,
                  decoration: InputDecoration(
                    labelText: "Marca",
                    prefixIcon: const Icon(Icons.directions_car),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  // Validación de marca
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Escribe la marca";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // introducir modelo
                TextFormField(
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  controller: _modeloController,
                  decoration: InputDecoration(
                    labelText: "Modelo",
                    prefixIcon: const Icon(Icons.model_training),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  // Validación de modelo
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Escribe el modelo";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // Elegir el tipo de combustible
                DropdownButtonFormField(
                  value: combustible,

                  decoration: InputDecoration(
                    labelText: "Combustible",
                    prefixIcon: Icon(Icons.local_gas_station_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),

                  dropdownColor: Theme.of(context).colorScheme.primary,

                  items: ["Diesel", "Gasoil", "Eléctrico", "Biocombustibles etanol y biodiésel", "Híbrido"].map((
                    combustibleActual,
                  ) {
                    return DropdownMenuItem(
                      value: combustibleActual,
                      child: Text(combustibleActual, style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
                    );
                  }).toList(),
                  onChanged: (combustibleElegido) {
                    setState(() {
                      combustible = combustibleElegido!;
                    });
                  },
                ),

                SizedBox(height: 20),

                // introducir año
                TextFormField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  controller: _anyoController,
                  decoration: InputDecoration(
                    labelText: "Año",
                    prefixIcon: const Icon(Icons.calendar_month),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  // Validación del año
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Introduce un año";
                    }
                    if (!isNumeric(value)) {
                      return "El año debe ser un valor numérico";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // introducir kilometraje
                TextFormField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  controller: _kilometrajeController,
                  decoration: InputDecoration(
                    labelText: "Kilometraje",
                    prefixIcon: Icon(Icons.receipt_long),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  // Validación del año
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Introduce un kilometraje";
                    }
                    if (!isNumeric(value)) {
                      return "El kilometraje debe ser un valor numérico";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // elegir fecha de vencimiento del seguro
                TextFormField(
                  controller: _fechaController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Fecha vencimiento seguro",
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onTap: () => seleccionarFecha(),
                  // Validación de fecha obligatoria
                  validator: (value) => (value == null || value.isEmpty) ? "Selecciona la fecha de inicio" : null,
                ),

                SizedBox(height: 20),

                // elegir estado del coche
                DropdownButtonFormField(
                  // el valor será la variable que indica el estado actual del coche
                  value: estadoActual,

                  decoration: InputDecoration(
                    labelText: "Estado",
                    prefixIcon: Icon(Icons.info_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  dropdownColor: Theme.of(context).colorScheme.primary,
                  // el desplegable tiene 3 estado a elegir
                  // cada uno de esos estados lo mapeamos para crearlo como DropdownMenuItem
                  // su valor y es el mismo que su texto (ej: "Alquilado", "Taller"...)
                  items: ["Disponible", "Alquilado", "Taller"].map((estadoActual) {
                    return DropdownMenuItem(
                      value: estadoActual,
                      child: Text(estadoActual, style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
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

                SizedBox(height: 20),

                // elegir color del vehiculo
                TextFormField(
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Color del vehiculo",
                    prefixIcon: const Icon(Icons.palette),
                    filled: true,
                    fillColor: Color(colorDelVehiculo),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onTap: () {
                    // colores a elegir
                    List<Color> coloresDisponibles = [
                      Colors.white,
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.yellow,
                      Colors.pink,
                      Colors.black,
                      Colors.grey,
                    ];
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Elige un color para el coche"),

                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                spacing: 10,
                                // con .map() recorremos la lista de colores y convetirmos (mapeamos)
                                // cada elemento (color) a un CircleAvatar con su respectivo color
                                children: coloresDisponibles.map((colorActual) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        colorDelVehiculo = colorActual.value;
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: CircleAvatar(backgroundColor: colorActual, radius: 10),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  validator: (value) => null,
                ),

                SizedBox(height: 20),

                // introducir observaciones
                TextFormField(
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  controller: _observacionesController,
                  decoration: InputDecoration(
                    labelText: "Observaciones",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 50),

                // botón de añadir coche
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Validamos el formulario antes de guardar
                      if (_formKey.currentState!.validate()) {
                        // guardamos la base de datos
                        final baseDatos = await DatabaseHelper.proyectodb();

                        // insertamos en la tabal "vehiculos" el coche con los datos que hemos cogido
                        await baseDatos.insert("vehiculos", {
                          "matricula": _matriculaController.text,
                          "marca": _marcaController.text,
                          "modelo": _modeloController.text,
                          "estado": estadoActual,
                          "color": colorDelVehiculo,
                          "kilometraje": _kilometrajeController.text,
                          "anyo": _anyoController.text,
                          "combustible": combustible,
                          "observaciones": _observacionesController.text,
                          "fecha_vencimiento_seguro": _fechaController.text,
                        });

                        _matriculaController.clear();
                        _marcaController.clear();
                        _modeloController.clear();
                        _observacionesController.clear();
                        _kilometrajeController.clear();
                        _anyoController.clear();

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text("Vehículo guardado correctamente")));
                        // Volvemos atrás tras el éxito
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("GUARDAR"),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  /// metodo para elegir una fecha
  Future<void> seleccionarFecha() async {
    DateTime fechaHoy = DateTime.now();

    // dejamos que el usuario elija la fecha y la guardamos esa fecha
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      // el día en el que se abrirá el calendario
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      // limite es dentro de 5 años
      lastDate: fechaHoy.add(const Duration(days: 365 * 5)),
    );

    if (fechaElegida != null) {
      setState(() {
        String fechaFormateada =
            "${fechaElegida.year}-${fechaElegida.month.toString().padLeft(2, '0')}-${fechaElegida.day.toString().padLeft(2, '0')}";
        _fechaController.text = fechaFormateada;
      });
    }
  }
}
