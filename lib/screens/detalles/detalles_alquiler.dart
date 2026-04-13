import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rebooty_repair/models/Alquiler.dart';
import 'package:rebooty_repair/models/Cliente.dart';
import 'package:rebooty_repair/models/Foto.dart';
import 'package:rebooty_repair/models/Multa.dart';
import 'package:rebooty_repair/models/Vehiculo.dart';
import '../../DataBaseHelper.dart';
import 'package:image_picker/image_picker.dart';

class DetallesAlquilerScreen extends StatefulWidget {
  const DetallesAlquilerScreen({super.key});

  @override
  State<DetallesAlquilerScreen> createState() => _DetallesAlquilerScreenState();
}

class _DetallesAlquilerScreenState extends State<DetallesAlquilerScreen> {
  late Alquiler alquiler;
  late Vehiculo coche;
  late Cliente cliente;

  List<Foto> fotos = [];
  List<Multa> multas = [];

  late bool confirmar;

  TextEditingController _fechaInicioControler = TextEditingController();
  TextEditingController _fechaLimiteControler = TextEditingController();
  TextEditingController _fechaDevoControler = TextEditingController();
  TextEditingController _precioController = TextEditingController();
  TextEditingController _fianzaController = TextEditingController();
  TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _clienteNombreController = TextEditingController();
  final TextEditingController _cocheMatriculaController = TextEditingController();
  String _estadoActual = "";
  String _formaPagoActual = "";
  bool _devolverFianza = false;

  // Lista de precios para el cálculo automático (se cargará del vehículo)
  List<double> preciosCocheSeleccionado = [];

  Future<void> cargarAlquiler(int idAlquiler) async {
    // guardamos el alquiler con el id recibido
    alquiler = (await DatabaseHelper.instance.obtenerAlquilerPorId(idAlquiler))!;
    // Cargamos los precios del coche asociado para recalcular si es necesario
    final v = await DatabaseHelper.instance.obtenerVehiculoPorId(alquiler.idCoche);
    if (v != null) {
      preciosCocheSeleccionado = (v.precios ?? "0,0,0,0,0,0,0")
          .split(',')
          .map((p) => double.tryParse(p) ?? 0.0)
          .toList();
    }
  }

  Future<void> cargarCocheYCliente(int idCoche, int idCliente) async {
    coche = (await DatabaseHelper.instance.obtenerVehiculoPorId(alquiler.idCoche))!;
    cliente = (await DatabaseHelper.instance.obtenerClientePorId(alquiler.idCliente))!;

    setState(() {
      _clienteNombreController.text = cliente.nombre;
      _cocheMatriculaController.text = coche.matricula;
    });
  }

  // metodo para rellenar la variable fotos con los datos de la base de datos asociados al alquiler con el id recibido
  Future<void> cargarFotos(int idAlquiler) async {
    final fotosDelAlquiler = await DatabaseHelper.instance.obtenerFotosPorAlquiler(idAlquiler);
    setState(() {
      fotos = fotosDelAlquiler;
    });
  }

  // metodo para rellenar la variable multas con los datos de la base de datos asociados al alquiler con el id recibido
  Future<void> cargarMultas(int idAlquiler) async {
    final multasDelAlquiler = await DatabaseHelper.instance.obtenerMultasPorAlquiler(idAlquiler);
    setState(() {
      multas = multasDelAlquiler;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    int idAlquiler = ModalRoute.of(context)?.settings.arguments as int;

    _cargarTodo(idAlquiler);
  }

  Future<void> _cargarTodo(int idAlquiler) async {
    alquiler = (await DatabaseHelper.instance.obtenerAlquilerPorId(idAlquiler))!;
    coche = (await DatabaseHelper.instance.obtenerVehiculoPorId(alquiler.idCoche))!;
    cliente = (await DatabaseHelper.instance.obtenerClientePorId(alquiler.idCliente))!;
    fotos = await DatabaseHelper.instance.obtenerFotosPorAlquiler(idAlquiler);
    multas = await DatabaseHelper.instance.obtenerMultasPorAlquiler(idAlquiler);

    // Cargamos precios del coche para recalcular precios si se cambian fechas
    preciosCocheSeleccionado = (coche.precios ?? "0,0,0,0,0,0,0")
        .split(',')
        .map((p) => double.tryParse(p) ?? 0.0)
        .toList();

    // Actualiza los controladores
    _clienteNombreController.text = cliente.nombre;
    _cocheMatriculaController.text = coche.matricula;
    _fechaInicioControler.text = alquiler.fechaInicio;
    _fechaLimiteControler.text = alquiler.fechaFin;
    _fechaDevoControler.text = alquiler.fechaDevolucion ?? "";
    _precioController.text = alquiler.precio.toString();
    _fianzaController.text = alquiler.fianza.toString();
    _observacionesController.text = alquiler.observaciones ?? "";
    _formaPagoActual = alquiler.formaPago ?? "Efectivo";
    _estadoActual = alquiler.estado;
    _devolverFianza = alquiler.devolverFianza == 1;

    setState(() {});
  }

  Future<void> actualizarAlquiler(String campo, dynamic valor) async {
    await DatabaseHelper.instance.actualizarCampoAlquiler(alquiler.id!, campo, valor);
    await cargarAlquiler(alquiler.id!);
  }

  Future<void> actualizarVehiculo(String campo, dynamic valor) async {
    await DatabaseHelper.instance.actualizarCampoVehiculo(coche.id!, campo, valor);
    await cargarCocheYCliente(alquiler.idCoche, alquiler.idCliente);
  }

  void _recalcularPrecioAutomatico({String? nuevaFechaIni, String? nuevaFechaFin}) {
    // 1. Obtención de fechas (parámetro o controlador)
    String sIni = nuevaFechaIni ?? _fechaInicioControler.text;
    String sFin = nuevaFechaFin ?? _fechaLimiteControler.text;

    DateTime? fIni = DateTime.tryParse(sIni);
    DateTime? fFin = DateTime.tryParse(sFin);

    if (fIni != null && fFin != null) {
      // 2. Cálculo de días mediante horas para evitar truncado de Dart
      final diferenciaHoras = fFin.difference(fIni).inHours;
      int diasTotales = (diferenciaHoras / 24).round();

      // Mínimo de 1 día si hay diferencia real
      if (diasTotales == 0 && fFin.isAfter(fIni)) diasTotales = 1;

      double total = 0.0;

      // --- LÓGICA DE PRECIOS POR TRAMOS (ESTILO MRDARKWING) ---

      if (diasTotales <= 0) {
        total = 0.0;
      }
      // TRAMO 1: Menos de una semana (1-6 días)
      else if (diasTotales < 7) {
        if (preciosCocheSeleccionado.isNotEmpty) {
          total = preciosCocheSeleccionado[diasTotales - 1];
        } else {
          total = 0.0;
        }
      }
      // TRAMO 2: De 7 a 29 días (Prorrateo sobre la semana)
      else if (diasTotales >= 7 && diasTotales < 30) {
        if (preciosCocheSeleccionado.length >= 7) {
          double precioSemana = preciosCocheSeleccionado[6];
          double precioDiaExtra = precioSemana / 7;
          total = precioSemana + (precioDiaExtra * (diasTotales - 7));
        }
      }
      // TRAMO 3: Bloques mensuales (30 días exactos o múltiplos)
      else if (diasTotales % 30 == 0) {
        int mesesCompletos = diasTotales ~/ 30;
        total = mesesCompletos * 700.0;
      }
      // TRAMO 4: Larga duración con días sueltos (ej: 122 días)
      else {
        int mesesCompletos = diasTotales ~/ 30;
        int diasSueltos = diasTotales % 30;
        double precioPorMes = 700.0;
        double precioDiaProrrateado = precioPorMes / 30;

        total = (mesesCompletos * precioPorMes) + (diasSueltos * precioDiaProrrateado);
      }

      // --- FINALIZACIÓN Y REDONDEO ---

      // Forzamos 2 decimales matemáticamente para la base de datos
      double precioFinalLimpio = double.parse(total.toStringAsFixed(2));

      // Guardamos en BD el valor redondeado
      actualizarAlquiler("precio", precioFinalLimpio);

      // Actualizamos la UI con formato de moneda (2 decimales fijos)
      setState(() {
        _precioController.text = precioFinalLimpio.toStringAsFixed(2);
      });

      print("--- CÁLCULO COMPLETADO ---");
      print("Días: $diasTotales | Total: $precioFinalLimpio€");
    }
  }

  // Metodo para finalizar el alquiler
  Future<void> _finalizarAlquiler() async {
    TextEditingController kilometrosController = TextEditingController(text: coche.kilometraje.toString());
    TextEditingController cantidadCombustibleController = TextEditingController(
      text: coche.cantidadCombustible.toString(),
    );
    bool necesitaLimpieza = false;
    bool quedarseFianza = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text("Finalizar Alquiler", style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Actualiza los datos del vehículo al recibirlo:", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 15),
                TextField(
                  controller: kilometrosController,
                  keyboardType: TextInputType.number,
                  // Texto que escribe el usuario en blanco
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: "Kilómetros actuales",
                    // Texto de la etiqueta en blanco
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: cantidadCombustibleController,
                  keyboardType: TextInputType.number,
                  // Texto que escribe el usuario en blanco
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: "Nivel de combustible",
                    // Texto de la etiqueta en blanco
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Switch necesita limpieza
                Row(
                  children: [
                    const Icon(Icons.cleaning_services_outlined, color: Colors.white70),
                    const SizedBox(width: 10),
                    const Text("¿Necesita limpieza?", style: TextStyle(color: Colors.white70)),
                    const Spacer(),
                    Switch(value: necesitaLimpieza, onChanged: (val) => setStateDialog(() => necesitaLimpieza = val)),
                  ],
                ),
                // Switch quedarse fianza
                Row(
                  children: [
                    const Icon(Icons.security_rounded, color: Colors.white70),
                    const SizedBox(width: 10),
                    const Text("¿Quedarse la fianza?", style: TextStyle(color: Colors.white70)),
                    const Spacer(),
                    Switch(value: quedarseFianza, onChanged: (val) => setStateDialog(() => quedarseFianza = val)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CANCELAR", style: TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  // Validaciones de números y valores negativos
                  double? kms = double.tryParse(kilometrosController.text);
                  int? combustible = int.tryParse(cantidadCombustibleController.text);

                  if (kms == null || combustible == null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("Error: Debes introducir números válidos.")));
                    return;
                  }

                  if (kms < 0 || combustible < 0) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("Error: Los valores no pueden ser menores a 0.")));
                    return;
                  }

                  DateTime hoy = DateTime.now();
                  String fechaHoy =
                      "${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}";

                  actualizarAlquiler("estado", "Terminado");
                  actualizarAlquiler("fecha_devolucion", fechaHoy);
                  actualizarAlquiler("devolver_fianza", quedarseFianza ? 0 : 1);
                  actualizarVehiculo("estado", "Disponible");
                  actualizarVehiculo("kilometraje", kms);
                  actualizarVehiculo("cantidad_combustible", combustible);
                  actualizarVehiculo("necesita_limpieza", necesitaLimpieza ? 1 : 0);

                  Navigator.pop(context);
                  cargarAlquiler(alquiler.id!);

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Alquiler finalizado y vehículo actualizado")));
                },
                child: const Text("CONFIRMAR", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
        title: const Text("Detalles del Alquiler"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Cards adaptativas: dos columnas en pantalla ancha, una columna en móvil
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool esPantallaAncha = constraints.maxWidth > 600;

                    final cardIzquierda = Card(
                      elevation: 8,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: esPantallaAncha ? 25 : 15, // padding adaptativo
                          vertical: 30,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _infoRow(Icons.person, "Cliente", _clienteNombreController)),
                                IconButton(
                                  onPressed: () async =>
                                  await Navigator.pushNamed(context, "detalles_cliente", arguments: cliente),
                                  icon: const Icon(Icons.arrow_forward_ios),
                                ),
                              ],
                            ),
                            const Divider(height: 40),
                            Row(
                              children: [
                                Expanded(
                                  child: _infoRow(Icons.calendar_today, "Fecha de inicio", _fechaInicioControler),
                                ),
                                IconButton(
                                  onPressed: () => _ventanaCambioFecha("fecha_inicio", _fechaInicioControler),
                                  icon: const Icon(Icons.edit),
                                ),
                              ],
                            ),
                            const Divider(height: 40),
                            Row(
                              children: [
                                Expanded(
                                  child: _infoRow(Icons.event_busy, "Fecha limite", _fechaLimiteControler),
                                ),
                                IconButton(
                                  onPressed: () => _ventanaCambioFecha("fecha_fin", _fechaLimiteControler),
                                  icon: const Icon(Icons.edit),
                                ),
                              ],
                            ),
                            const Divider(height: 40),
                            Row(
                              children: [
                                Expanded(child: _infoRow(Icons.euro, "Precio", _precioController)),
                                IconButton(onPressed: () => _ventanaCambioPrecio(), icon: const Icon(Icons.edit)),
                              ],
                            ),
                            const Divider(height: 40),
                            // MOSTRAR FIANZA
                            Row(
                              children: [
                                Expanded(child: _infoRow(Icons.security_rounded, "Fianza", _fianzaController)),
                                IconButton(onPressed: () => _ventanaCambioFianza(), icon: const Icon(Icons.edit)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );

                    final cardDerecha = Card(
                      elevation: 8,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: esPantallaAncha ? 25 : 15, // padding adaptativo
                          vertical: 30,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _infoRow(Icons.directions_car, "Coche", _cocheMatriculaController),
                                ),
                                IconButton(
                                  onPressed: () async =>
                                  await Navigator.pushNamed(context, "detalles_vehiculo", arguments: coche),
                                  icon: const Icon(Icons.arrow_forward_ios),
                                ),
                              ],
                            ),
                            const Divider(height: 40),
                            // MOSTRAR FORMA DE PAGO
                            Row(
                              children: [
                                Expanded(
                                  child: _infoRowEstado(Icons.payment_rounded, "Forma de Pago", _formaPagoActual),
                                ),
                                IconButton(
                                  onPressed: () => _ventanaCambioFormaPago(),
                                  icon: const Icon(Icons.edit),
                                ),
                              ],
                            ),
                            const Divider(height: 40),
                            Row(
                              children: [
                                Expanded(
                                  child: _infoRow(Icons.search, "Observaciones", _observacionesController),
                                ),
                                IconButton(
                                  onPressed: () => _ventanaCambioObservaciones(),
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(onPressed: mostrarObservaciones, icon: const Icon(Icons.visibility)),
                              ],
                            ),
                            const Divider(height: 40),
                            Row(
                              children: [
                                Expanded(
                                  child: _infoRow(Icons.event_available, "Fecha entrega", _fechaDevoControler),
                                ),
                                IconButton(
                                  onPressed: () => _ventanaCambioFecha("fecha_devolucion", _fechaDevoControler),
                                  icon: const Icon(Icons.edit),
                                ),
                              ],
                            ),
                            const Divider(height: 40),
                            Row(
                              children: [
                                Expanded(
                                  child: _infoRowEstado(
                                    Icons.info_outline,
                                    "Estado de la devolucion",
                                    _estadoActual,
                                  ),
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
                    );

                    return Column(
                      children: [
                        // En pantalla ancha: las dos cards en fila (comportamiento original Windows)
                        // En móvil: apiladas en columna
                        if (esPantallaAncha)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: cardIzquierda),
                              const SizedBox(width: 10),
                              Expanded(child: cardDerecha),
                            ],
                          )
                        else
                          Column(
                            children: [
                              cardIzquierda,
                              const SizedBox(height: 10),
                              cardDerecha,
                            ],
                          ),

                        // MOSTRAR DEVOLVER FIANZA - card ancha ocupando ambas columnas
                        const SizedBox(height: 10),
                        Card(
                          elevation: 8,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.assignment_return_outlined),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("¿Devolver fianza?", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                      Text(
                                        _devolverFianza ? "Sí" : "No",
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                    onPressed: () => _ventanaCambioDevolverFianza(), icon: const Icon(Icons.edit)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 50),

              // Botón Finalizar Alquiler (Solo si no está terminado)
              if (_estadoActual != "Terminado")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: _finalizarAlquiler,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text(
                            "FINALIZAR ALQUILER Y LIBERAR COCHE",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: fotos.length + 1,
                    itemBuilder: (context, index) {
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
                      return GestureDetector(
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
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image(
                                        image: FileImage(File(fotos[index].ruta)),
                                        height: 450,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () async {
                                        await DatabaseHelper.instance.borrarFoto(fotos[index]);
                                        cargarFotos(alquiler.id!);
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.delete_forever),
                                      label: const Text("Eliminar Imagen", style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 20, bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            image: DecorationImage(image: FileImage(File(fotos[index].ruta)), fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Título sección Multas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: multas.length + 1,
                    itemBuilder: (context, index) {
                      if (index == multas.length) {
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(context, "añadir_multa", arguments: alquiler.id);
                            cargarMultas(alquiler.id!);
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

                      final multaActual = multas[index];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(context, "detalles_multa", arguments: multaActual.id);
                          cargarMultas(alquiler.id!);
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
                                color: multaActual.pagada == 1 ? Colors.green : Colors.red,
                                size: 40,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                multaActual.descripcion,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text("${multaActual.precio} €", style: const TextStyle(fontSize: 18)),
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
          decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
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

    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controllerFecha.text) ?? fechaHoy,
      firstDate: DateTime(2024),
      lastDate: fechaHoy.add(const Duration(days: 365 * 2)),
    );

    if (fechaElegida != null) {
      String fechaFormateada =
          "${fechaElegida.year}-${fechaElegida.month.toString().padLeft(2, '0')}-${fechaElegida.day.toString().padLeft(2, '0')}";

      // 1. ACTUALIZAR EN BASE DE DATOS PRIMERO
      await actualizarAlquiler(nombreCampo, fechaFormateada);

      // 2. FORZAR ACTUALIZACIÓN DEL CONTROLADOR VISUAL INMEDIATAMENTE
      setState(() {
        controllerFecha.text = fechaFormateada;
      });

      // 3. RECALCULAR USANDO LOS DATOS FRESCOS
      // Si hemos cambiado la fecha de inicio, la pasamos explícitamente. Si no, pasamos la de fin.
      if (nombreCampo == "fecha_inicio") {
        _recalcularPrecioAutomatico(nuevaFechaIni: fechaFormateada);
      } else {
        _recalcularPrecioAutomatico(nuevaFechaFin: fechaFormateada);
      }

      // 4. RECARGA TOTAL PARA ASEGURAR SINCRONÍA
      await _cargarTodo(alquiler.id!);
    }
  }

  void _errorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  // Función auxiliar para no repetir código de errores
  void _errorFecha(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: Colors.red));
  }

  Future<void> _ventanaCambioPrecio() async {
    TextEditingController nuevoPrecio = TextEditingController(text: _precioController.text);
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
                    if (await confirmacion()) {
                      actualizarAlquiler("precio", double.tryParse(nuevoPrecio.text) ?? 0.0);
                      Navigator.pop(context);
                      cargarAlquiler(alquiler.id!);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // VENTANA PARA CAMBIAR FIANZA
  Future<void> _ventanaCambioFianza() async {
    TextEditingController nuevaFianza = TextEditingController(text: _fianzaController.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Actualizar fianza"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nuevaFianza,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Nueva fianza",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text("Guardar cambios"),
                  onPressed: () async {
                    if (await confirmacion()) {
                      actualizarAlquiler("fianza", double.tryParse(nuevaFianza.text) ?? 0.0);
                      Navigator.pop(context);
                      cargarAlquiler(alquiler.id!);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // VENTANA PARA CAMBIAR FORMA DE PAGO
  Future<void> _ventanaCambioFormaPago() async {
    String? temporalForma = ["Efectivo", "Tarjeta", "Transferencia"].contains(_formaPagoActual)
        ? _formaPagoActual
        : "Efectivo";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Actualizar forma de pago"),
        content: DropdownButtonFormField<String>(
          value: temporalForma,
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          items: ["Efectivo", "Tarjeta", "Transferencia"].map((forma) {
            return DropdownMenuItem(value: forma, child: Text(forma));
          }).toList(),
          onChanged: (val) => temporalForma = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: () async {
              if (await confirmacion()) {
                actualizarAlquiler("forma_pago", temporalForma);
                Navigator.pop(context);
                cargarAlquiler(alquiler.id!);
              }
            },
            child: const Text("GUARDAR"),
          ),
        ],
      ),
    );
  }

  // VENTANA PARA CAMBIAR DEVOLVER FIANZA
  Future<void> _ventanaCambioDevolverFianza() async {
    bool temporalDevolver = _devolverFianza;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Devolución de fianza"),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.assignment_return_outlined),
              const SizedBox(width: 10),
              const Text("¿Devolver fianza?"),
              const Spacer(),
              Switch(
                value: temporalDevolver,
                onChanged: (nuevoValor) {
                  setStateDialog(() {
                    temporalDevolver = nuevoValor;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
            ElevatedButton(
              onPressed: () async {
                actualizarAlquiler("devolver_fianza", temporalDevolver ? 1 : 0);
                Navigator.pop(context);
                cargarAlquiler(alquiler.id!);
              },
              child: const Text("GUARDAR"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _ventanaCambioObservaciones() async {
    TextEditingController nuevasObs = TextEditingController(text: _observacionesController.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Observaciones"),
          content: TextField(
            controller: nuevasObs,
            maxLines: 5,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                actualizarAlquiler("observaciones", nuevasObs.text);
                Navigator.pop(context);
                cargarAlquiler(alquiler.id!);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void mostrarObservaciones() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(title: const Text("Observaciones"), content: Text(_observacionesController.text)),
    );
  }

  Widget _ventanaCambioEstado(String campoACambiar, String estadoActual) {
    String? estadoSeleccionado = ["Pendiente", "En proceso", "Terminado"].contains(estadoActual) ? estadoActual : null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text("Actualizar $campoACambiar"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Introduce el nuevo valor para el campo:"),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: estadoSeleccionado,
            decoration: InputDecoration(
              labelText: "Estado",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: [
              "Pendiente",
              "En proceso",
              "Terminado",
            ].map((estado) => DropdownMenuItem(value: estado, child: Text(estado))).toList(),
            onChanged: (nuevoEstado) async {
              if (nuevoEstado != null && await confirmacion()) {
                actualizarAlquiler("estado", nuevoEstado);
                Navigator.pop(context);
                cargarAlquiler(alquiler.id!);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<bool> confirmacion() async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Confirmar cambio?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () {
              result = true;
              Navigator.pop(context);
            },
            child: const Text("Sí"),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _ventanaAnyadirFoto() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? imagen = await imagePicker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      await DatabaseHelper.instance.insertarFoto(alquiler.id!, imagen.path);
      cargarFotos(alquiler.id!);
    }
  }
}