import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rebooty_repair/database.dart';
import 'package:image_picker/image_picker.dart';

class DetallesAlquilerScreen extends StatefulWidget {
  const DetallesAlquilerScreen({super.key});

  @override
  State<DetallesAlquilerScreen> createState() => _DetallesAlquilerScreenState();
}

class _DetallesAlquilerScreenState extends State<DetallesAlquilerScreen> {
  Map<String, dynamic> alquiler = {};
  Map<String, dynamic> coche = {};
  Map<String, dynamic> cliente = {};

  List<Map<String, dynamic>> fotos = [];
  List<Map<String, dynamic>> multas = [];

  late bool confirmar;

  TextEditingController _fechaInicioControler = TextEditingController();
  TextEditingController _fechaLimiteControler = TextEditingController();
  TextEditingController _fechaDevoControler = TextEditingController();
  TextEditingController _precioController = TextEditingController();
  TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _clienteNombreController = TextEditingController();
  final TextEditingController _cocheMatriculaController = TextEditingController();
  String _estadoActual = "";

  Future<void> cargarAlquiler(int idAlquiler) async {
    // guardamos el alquiler con el id recibido
    final alquileresConIdRecibido = await DatabaseHelper.obtenerAlquilerPorId(idAlquiler);

    alquiler = alquileresConIdRecibido.first;

    setState(() {
      _fechaInicioControler = TextEditingController(text: alquiler['fecha_inicio']);
      _fechaLimiteControler = TextEditingController(text: alquiler['fecha_fin']);
      _fechaDevoControler = TextEditingController(text: alquiler['fecha_devolucion'] ?? "");
      _precioController = TextEditingController(text: alquiler['precio'].toString());
      _observacionesController = TextEditingController(text: alquiler['observaciones']);
      _estadoActual = alquiler['estado'];
    });

    await cargarCocheYCliente(alquiler['id_coche'], alquiler['id_cliente']);
  }

  Future<void> cargarCocheYCliente(int idCoche, int idCliente) async {
    final cochesConId = await DatabaseHelper.obtenerVehiculoPorId(idCoche);
    final clienteConId = await DatabaseHelper.obtenerClientesPorId(idCliente);

    setState(() {
      coche = cochesConId.first;
      cliente = clienteConId.first;

      _clienteNombreController.text = cliente['nombre'] ?? "";
      _cocheMatriculaController.text = coche['matricula'] ?? "";
    });
  }

  // metodo para rellenar la variable fotos con los datos de la base de datos asociados al alquiler con el id recibido
  Future<void> cargarFotos(int idAlquiler) async {
    final fotosDelAlquiler = await DatabaseHelper.obtenerFotosPorIdAlquiler(idAlquiler);

    setState(() {
      fotos = fotosDelAlquiler;
    });
  }

  // metodo para rellenar la variable multas con los datos de la base de datos asociados al alquiler con el id recibido
  Future<void> cargarMultas(int idAlquiler) async {
    final multasDelAlquiler = await DatabaseHelper.obtenerMultasPorIdAlquiler(idAlquiler);

    setState(() {
      multas = multasDelAlquiler;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    int idAlquiler = ModalRoute.of(context)?.settings.arguments as int;

    cargarAlquiler(idAlquiler);
    cargarFotos(idAlquiler);
    cargarMultas(idAlquiler);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Detalles del Alquiler"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              // Card con información de los campos del alquiler
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
                        // fecha inicio
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.person, "Cliente", _clienteNombreController)),
                            IconButton(
                              onPressed: () async {
                                await Navigator.pushNamed(context, "detalles_cliente", arguments: cliente["id"]);
                              },
                              icon: const Icon(Icons.arrow_forward_ios),
                            ),
                          ],
                        ),
                        const Divider(height: 40),
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.directions_car, "Coche", _cocheMatriculaController)),
                            IconButton(
                              onPressed: () async {
                                await Navigator.pushNamed(context, "detalles_vehiculo", arguments: coche["id"]);
                              },
                              icon: const Icon(Icons.arrow_forward_ios),
                            ),
                          ],
                        ),
                        const Divider(height: 40),
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.calendar_today, "Fecha de inicio", _fechaInicioControler)),
                            IconButton(
                              onPressed: () {
                                _ventanaCambioFecha("fecha_inicio", _fechaInicioControler);
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(height: 40),
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.event_busy, "Fecha limite", _fechaLimiteControler)),
                            IconButton(
                              onPressed: () {
                                _ventanaCambioFecha("fecha_fin", _fechaLimiteControler);
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(height: 40),
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.euro, "Precio", _precioController)),
                            IconButton(
                              onPressed: () {
                                _ventanaCambioPrecio();
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(height: 40),
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.search, "Observaciones", _observacionesController)),
                            IconButton(
                              onPressed: () {
                                _ventanaCambioObservaciones();
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: mostrarObservaciones,
                              icon: const Icon(Icons.visibility),
                            ),
                          ],
                        ),
                        const Divider(height: 40),
                        Row(
                          children: [
                            Expanded(child: _infoRow(Icons.event_available, "Fecha entrega", _fechaDevoControler)),
                            IconButton(
                              onPressed: () {
                                _ventanaCambioFecha("fecha_devolucion", _fechaDevoControler);
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                        const Divider(height: 40),
                        // estado de la devolución
                        Row(
                          children: [
                            Expanded(
                              child: _infoRowEstado(Icons.info_outline, "Estado de la devolucion", _estadoActual),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => _ventanaCambioEstado("estado", _estadoActual),
                                );
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

              const SizedBox(height: 50),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 180.0),
                child: Row(
                  children: [
                    const Icon(Icons.camera_alt, size: 24),
                    const SizedBox(width: 10),
                    const Text("Imágenes del vehículo", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // lista de fotos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 170.0),
                child: SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    // longitud lista de fotos más 1 para que el último elemento sea el botón de añadir
                    itemCount: fotos.length + 1,
                    itemBuilder: (context, index) {
                      // Si es el último índice, mostramos el botón de añadir
                      if (index == fotos.length) {
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
                      // Imagen actual de la lista de fotos
                      return GestureDetector(
                        // al pulsar mostramos la imagen en grande y la opción de borrar
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                contentPadding: const EdgeInsets.all(15),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // envolvemos la imagen en ClipRRect para redondear sus bordes
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image(
                                        image: FileImage(File(fotos[index]["ruta"])),
                                        height: 450,
                                        fit: BoxFit.contain,
                                      ),
                                    ),

                                    const SizedBox(height: 25),

                                    // boton borrar foto
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Theme.of(context).colorScheme.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () async {
                                        final baseDatos = await DatabaseHelper.proyectodb();
                                        // borramos la foto con el id de la foto actual
                                        await baseDatos.delete(
                                          "fotos",
                                          where: "id = ?",
                                          whereArgs: [fotos[index]["id"]],
                                        );
                                        cargarFotos(alquiler["id"]);
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(Icons.delete_forever),
                                      label: Text("Eliminar Imagen", style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },

                        child: Container(
                          width: 200,
                          margin: EdgeInsets.only(right: 20, bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 10)),
                            ],
                            image: DecorationImage(image: FileImage(File(fotos[index]["ruta"])), fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 60),

              // Título sección Multas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 180.0),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 24),
                    const SizedBox(width: 10),
                    const Text("Multas asociadas", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Lista de multas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 170.0),
                child: SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: multas.length + 1,
                    itemBuilder: (context, index) {
                      // Botón para añadir nueva multa
                      if (index == multas.length) {
                        return GestureDetector(
                          onTap: () async {
                            // Navegamos a la pantalla de añadir multa pasando el id del alquiler
                            await Navigator.pushNamed(context, "añadir_multa", arguments: alquiler["id"]);
                            cargarMultas(
                              alquiler["id"],
                            ); // Recargamos las multas al volver por si se ha añdadido nuevas
                          },
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
                                Icon(Icons.add_circle_outline, size: 50),
                                SizedBox(height: 10),
                                Text("Añadir Multa", style: TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        );
                      }

                      // Información de la multa actual
                      final multaActual = multas[index];
                      return GestureDetector(
                        onTap: () async {
                          // Navegamos a detalles de la multa
                          await Navigator.pushNamed(context, "detalles_multa", arguments: multaActual["id"]);
                          cargarMultas(alquiler["id"]); // Recargamos al volver por si se han modificado sus datos
                        },
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 20, bottom: 10),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: multaActual["pagada"] == 1 ? Colors.green : Colors.red,
                                size: 40,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                multaActual["descripcion"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${multaActual["precio"]} €",
                                style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 60),
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

  Future<void> _ventanaCambioFecha(String nombreCampo, TextEditingController controllerFecha) async {
    DateTime fechaHoy = DateTime.now();

    // dejamos que el usuario elija la fecha y la guardamos esa fecha
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      // el día en el que se abrirá el calendario
      // si no ha escogido fecha de inicio es el dia de hoy
      // si ya la ha elegido (es porque va a rellenar la fecha de fin)
      // por lo que mostramos es calendario a partir de la fecha de inicio
      initialDate: fechaHoy,
      firstDate: DateTime(2024),
      // limite es dentro de 5 años
      lastDate: fechaHoy.add(const Duration(days: 365 * 5)),
    );
    if (fechaElegida != null) {
      // Guardamos la fecha y la formateamos para el texto (Año-Mes-Día)
      String fechaFormateada =
          "${fechaElegida.year}-${fechaElegida.month.toString().padLeft(2, '0')}-${fechaElegida.day.toString().padLeft(2, '0')}";

      final baseDatos = await DatabaseHelper.proyectodb();
      await baseDatos.update(
        "alquileres",
        {nombreCampo: fechaFormateada, "estado": "Terminado"},
        where: "id = ?",
        whereArgs: [alquiler["id"]],
      );

      await baseDatos.update("vehiculos", {"estado": "Disponible"}, where: "id = ?", whereArgs: [alquiler["id_coche"]]);

      setState(() {
        _estadoActual = "Terminado";
      });

      cargarAlquiler(alquiler["id"]);

      // Actualizamos los datos tras el cambio
      cargarAlquiler(alquiler["id"]);
    }
  }

  Future<void> _ventanaCambioPrecio() async {
    TextEditingController nuevoPrecio = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

          title: const Text("Actualizar precio"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nuevoPrecio,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Nuevo precio",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text("Guardar cambios"),

                  onPressed: () async {
                    confirmar = await confirmacion();
                    if (!confirmar) return Navigator.pop(context);

                    final db = await DatabaseHelper.proyectodb();
                    await db.update(
                      "alquileres",
                      {"precio": double.parse(nuevoPrecio.text)},
                      where: "id = ?",
                      whereArgs: [alquiler["id"]],
                    );

                    Navigator.pop(context);

                    cargarAlquiler(alquiler["id"]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ventanaCambioEstado(String campoACambiar, String estadoActual) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text("Actualizar $campoACambiar"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Introduce el nuevo valor para el campo:"),
          const SizedBox(height: 15),
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
            // su valor y es el mismo que su texto (ej: "Pendiente", "Terminado"...)
            items: ["Pendiente", "En proceso", "Terminado"].map((estadoActual) {
              return DropdownMenuItem(value: estadoActual, child: Text(estadoActual));
            }).toList(),
            // convertimos a lista porque items nos pide la lista con los valores del DropdownButtonFormField

            // al pulsar en uno de los desplegables del menú, actualizamos la variable con
            // el estado actual del coche para que sea ahora el valor del desplegable pulsado
            onChanged: (nuevoEstado) async {
              confirmar = await confirmacion();
              if (!confirmar) return Navigator.pop(context);

              final baseDatos = await DatabaseHelper.proyectodb();
              await baseDatos.update(
                "alquileres",
                {"estado": nuevoEstado},
                where: "id = ?",
                whereArgs: [alquiler["id"]],
              );

              setState(() {
                estadoActual = nuevoEstado!;
                Navigator.pop(context);
                cargarAlquiler(alquiler["id"]);
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _ventanaAnyadirFoto() async {
    final ImagePicker imagePicker = ImagePicker();

    final XFile? imagen = await imagePicker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      final baseDatos = await DatabaseHelper.proyectodb();

      await baseDatos.insert("fotos", {"id_alquiler": alquiler["id"], "ruta": imagen.path});

      cargarFotos(alquiler["id"]);
    }
  }

  Future<void> _ventanaCambioObservaciones() async {
    TextEditingController nuevasObservaciones =
    TextEditingController(text: _observacionesController.text);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),

          title: const Text("Editar observaciones"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: nuevasObservaciones,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Observaciones",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text("Guardar cambios"),

                  onPressed: () async {
                    bool confirmar = await confirmacion();
                    if (!confirmar) return Navigator.pop(context);

                    final db = await DatabaseHelper.proyectodb();

                    await db.update(
                      "alquileres",
                      {"observaciones": nuevasObservaciones.text},
                      where: "id = ?",
                      whereArgs: [alquiler["id"]],
                    );

                    Navigator.pop(context);

                    cargarAlquiler(alquiler["id"]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void mostrarObservaciones() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),

          title: const Text("Observaciones"),

          content: SingleChildScrollView(
            child: Text(
              _observacionesController.text.isEmpty
                  ? "No hay observaciones"
                  : _observacionesController.text,
              style: const TextStyle(fontSize: 18),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            )
          ],
        );
      },
    );
  }

  Future<bool> confirmacion() async {
    confirmar =
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Confirmar cambio"),
              content: const Text("¿Seguro que quieres actualizar los datos?"),
              actions: [
                TextButton(
                  child: const Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
                ElevatedButton(
                  child: const Text("Confirmar"),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
    return confirmar;
  }
}
