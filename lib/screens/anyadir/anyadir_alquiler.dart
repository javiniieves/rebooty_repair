import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/Alquiler.dart';
import '../../DataBaseHelper.dart';
import '../../models/Cliente.dart';
import '../../models/Foto.dart';
import '../../models/Vehiculo.dart';

class PantallaAnyadirAlquiler extends StatefulWidget {
  const PantallaAnyadirAlquiler({super.key});

  @override
  State<PantallaAnyadirAlquiler> createState() => _PantallaAnyadirAlquilerState();
}

class _PantallaAnyadirAlquilerState extends State<PantallaAnyadirAlquiler> {
  final _formKey = GlobalKey<FormState>();

  String? _idClienteSeleccionado;
  String? _idVehiculoSeleccionado;

  List<Cliente> listaClientes = [];
  List<Vehiculo> listaVehiculos = [];

  // Lista para almacenar las rutas de las fotos antes de guardar
  List<String> fotosTemporales = [];

  final _precioController = TextEditingController();
  final _fianzaController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();
  late TextEditingController _observacionesController;

  DateTime? fechaInicio;
  DateTime? fechaFin;
  String estadoActual = "Pendiente";
  String formaPagoActual = "Efectivo";

  // Variable para controlar si se debe devolver la fianza
  bool devolverFianza = false;

  Future<void> cargarIdsClientes() async {
    final clientes = await DatabaseHelper.instance.obtenerClientes();
    setState(() {
      listaClientes = clientes;
    });
  }

  // CORRECCIÓN AQUÍ: Cargamos todos los vehículos para poder alquilarlos en distintos periodos
  Future<void> cargarIdsVehiculos() async {
    final vehiculos = await DatabaseHelper.instance.obtenerVehiculos();

    setState(() {
      listaVehiculos = vehiculos.where((v) => v.estado != "Taller").toList();
    });
  }

  @override
  void initState() {
    super.initState();
    cargarIdsClientes();
    cargarIdsVehiculos();
    _observacionesController = TextEditingController();
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    _precioController.dispose();
    _fianzaController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Añade un nuevo alquiler"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
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
                          await _guardarAlquiler();
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
          icon: const Icon(Icons.chevron_left_outlined),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // DNI Cliente y Matrícula
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Autocomplete<Cliente>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return listaClientes;
                        }

                        return listaClientes.where((cliente) {
                          return cliente.documentoOficial.toLowerCase().contains(textEditingValue.text.toLowerCase());
                        });
                      },

                      displayStringForOption: (cliente) => "${cliente.documentoOficial} - ${cliente.nombre}",

                      onSelected: (clienteSeleccionado) {
                        setState(() {
                          _idClienteSeleccionado = clienteSeleccionado.id.toString();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Autocomplete<Vehiculo>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return listaVehiculos;
                        }

                        return listaVehiculos.where((vehiculo) {
                          return vehiculo.matricula.toLowerCase().contains(textEditingValue.text.toLowerCase());
                        });
                      },

                      displayStringForOption: (vehiculo) => "${vehiculo.matricula} - ${vehiculo.modelo}",

                      onSelected: (vehiculoSeleccionado) {
                        setState(() {
                          _idVehiculoSeleccionado = vehiculoSeleccionado.id.toString();
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Fecha Inicio y Fecha Fin
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                      controller: _fechaInicioController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Fecha inicio",
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onTap: () => seleccionarFecha(true),
                      validator: (value) => (value == null || value.isEmpty) ? "Selecciona inicio" : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                      controller: _fechaFinController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Fecha fin",
                        prefixIcon: const Icon(Icons.event_available),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onTap: () => seleccionarFecha(false),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Selecciona fin";
                        if (fechaInicio != null && fechaFin != null) {
                          if (fechaFin!.isBefore(fechaInicio!)) {
                            return "Error en fechas";
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Precio y Fianza
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                      controller: _precioController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Precio",
                        prefixIcon: const Icon(Icons.price_check_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Introduce precio";
                        final numero = double.tryParse(value);
                        if (numero == null) return "No válido";
                        if (numero < 0) return "Debe ser positivo";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                      controller: _fianzaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Fianza",
                        prefixIcon: const Icon(Icons.security_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) {
                        // MODIFICACIÓN: Ya no es obligatorio introducir fianza.
                        if (value != null && value.isNotEmpty) {
                          final numero = double.tryParse(value);
                          if (numero == null) return "No válida";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Forma de Pago y Estado
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      value: formaPagoActual,
                      decoration: InputDecoration(
                        labelText: "Forma de pago",
                        prefixIcon: const Icon(Icons.payment_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      dropdownColor: Theme.of(context).colorScheme.primary,
                      items: ["Efectivo", "Tarjeta", "Transferencia"].map((forma) {
                        return DropdownMenuItem(
                          value: forma,
                          child: Text(
                            forma,
                            style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (nuevaForma) {
                        setState(() {
                          formaPagoActual = nuevaForma!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: estadoActual,
                      decoration: InputDecoration(
                        labelText: "Estado",
                        prefixIcon: const Icon(Icons.info_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      dropdownColor: Theme.of(context).colorScheme.primary,
                      items: ["Pendiente", "En proceso", "Terminado"].map((estado) {
                        return DropdownMenuItem(
                          value: estado,
                          child: Text(
                            estado,
                            style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (nuevoEstado) {
                        setState(() {
                          estadoActual = nuevoEstado!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Notas y Devolver fianza (Mitad y mitad, mismo estilo)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                      controller: _observacionesController,
                      decoration: InputDecoration(
                        labelText: "Notas",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "¿Devolver fianza?",
                        prefixIcon: const Icon(Icons.assignment_return_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Switch(
                          value: devolverFianza,
                          onChanged: (bool nuevoValor) {
                            setState(() {
                              devolverFianza = nuevoValor;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  const Icon(Icons.camera_alt, size: 24),
                  const SizedBox(width: 10),
                  const Text("Imágenes del vehículo", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 10),

              // lista de fotos
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fotosTemporales.length + 1,
                  itemBuilder: (context, index) {
                    if (index == fotosTemporales.length) {
                      return GestureDetector(
                        onTap: () => _ventanaAnyadirFoto(),
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.deepPurple.withOpacity(0.3), width: 2),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 50),
                              SizedBox(height: 10),
                              Text("Añadir Foto", style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          fotosTemporales.removeAt(index);
                        });
                      },
                      child: Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 20, bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 10)),
                          ],
                          image: DecorationImage(image: FileImage(File(fotosTemporales[index])), fit: BoxFit.cover),
                        ),
                        child: const Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 15,
                              child: Icon(Icons.delete, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 50),

              // botón de añadir alquiler
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _guardarAlquiler,
                  icon: const Icon(Icons.save),
                  label: const Text("GUARDAR ALQUILER"),
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

  Future<void> _ventanaAnyadirFoto() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? imagen = await imagePicker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() {
        fotosTemporales.add(imagen.path);
      });
    }
  }

  Future<void> seleccionarFecha(bool esInicio) async {
    DateTime fechaHoy = DateTime.now();
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: esInicio ? (fechaInicio ?? fechaHoy) : (fechaFin ?? fechaInicio ?? fechaHoy),
      firstDate: DateTime(2024),
      lastDate: fechaHoy.add(const Duration(days: 365 * 5)),
    );

    if (fechaElegida != null) {
      setState(() {
        String fechaFormateada =
            "${fechaElegida.year}-${fechaElegida.month.toString().padLeft(2, '0')}-${fechaElegida.day.toString().padLeft(2, '0')}";

        if (esInicio) {
          fechaInicio = fechaElegida;
          _fechaInicioController.text = fechaFormateada;
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

  Future<void> _guardarAlquiler() async {
    if (!_formKey.currentState!.validate()) return;

    if (_idClienteSeleccionado == null || _idVehiculoSeleccionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecciona cliente y vehículo"), backgroundColor: Colors.red));
      return;
    }

    bool estaLibre = await DatabaseHelper.instance.cocheEstaDisponible(
      int.parse(_idVehiculoSeleccionado!),
      _fechaInicioController.text,
      _fechaFinController.text,
    );

    if (!estaLibre) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("El coche ya está ocupado en esa fecha"), backgroundColor: Colors.red));
      return;
    }

    final alquiler = Alquiler(
      idCoche: int.parse(_idVehiculoSeleccionado!),
      idCliente: int.parse(_idClienteSeleccionado!),
      fechaInicio: _fechaInicioController.text,
      fechaFin: _fechaFinController.text,
      precio: double.parse(_precioController.text),
      fianza: double.tryParse(_fianzaController.text) ?? 0.0,
      estado: estadoActual,
      observaciones: _observacionesController.text,
      formaPago: formaPagoActual,
      devolverFianza: devolverFianza ? 1 : 0,
    );

    final db = await DatabaseHelper.instance.database;
    int idNuevoAlquiler = await db.insert("alquileres", alquiler.toMap());

    for (String ruta in fotosTemporales) {
      final foto = Foto(idAlquiler: idNuevoAlquiler, ruta: ruta);
      await db.insert("fotos", foto.toMap());
    }

    await db.update("vehiculos", {"estado": "Alquilado"}, where: "id = ?", whereArgs: [_idVehiculoSeleccionado]);

    _limpiarFormulario();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alquiler guardado correctamente")));

    Navigator.pop(context);
  }

  void _limpiarFormulario() {
    _precioController.clear();
    _fianzaController.clear();
    _fechaInicioController.clear();
    _fechaFinController.clear();
    _observacionesController.clear();
    fotosTemporales.clear();
  }
}
