import 'package:flutter/material.dart';
import 'package:rebooty_repair/screens/Principal.dart';
import 'package:rebooty_repair/screens/anyadir/anyadir_alquiler.dart';
import 'package:rebooty_repair/screens/anyadir/anyadir_clientes.dart';
import 'package:rebooty_repair/screens/anyadir/anyadir_vehiculos.dart';

void main() {
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
      },
    );
  }
}
