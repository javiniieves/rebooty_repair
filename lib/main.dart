import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rebooty_repair/screens/Principal.dart';
import 'package:rebooty_repair/screens/anyadir/anyadir_alquiler.dart';
import 'package:rebooty_repair/screens/anyadir/anyadir_clientes.dart';
import 'package:rebooty_repair/screens/anyadir/anyadir_vehiculos.dart';
import 'package:rebooty_repair/screens/buscar/busquedaAlquiler.dart';
import 'package:rebooty_repair/screens/buscar/busquedaCliente.dart';
import 'package:rebooty_repair/screens/buscar/busquedaVehiculo.dart';
import 'package:rebooty_repair/screens/detalles/detalles_alquiler.dart';
import 'package:rebooty_repair/screens/detalles/detalles_vehiculo.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(AppAlquilerCoches());
}

class AppAlquilerCoches extends StatelessWidget {
  const AppAlquilerCoches({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Principal(),

      routes: {

        "añadir_cliente" : (context) => PantallaAnyadirClientes(),
        "añadir_vehiculo" : (context) => PantallaAnyadirVehiculos(),
        "añadir_alquiler" : (context) => PantallaAnyadirAlquiler(),
        "buscar_cliente" : (context) => PantallaBusquedaCliente(),
        "buscar_vehiculo" : (context) => PantallaBusquedaVehiculo(),
        "buscar_alquiler" : (context) => PantallaBusquedaAlquiler(),

        "detalles_cliente" : (context) => DetallesClienteScreen(),
        "detalles_vehiculo" : (context) => DetallesVehiculoScreen(),
        "detalles_alquiler" : (context) => DetallesAlquilerScreen(),
      },
    );
  }
}
