import 'package:flutter/material.dart';
import 'package:rebooty_repair/screens/Cliente.dart';
import 'package:rebooty_repair/screens/Vehiculos.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  List<Widget> listaPantallas = [PantallaClientes(), PantallaVehiculos()];
  int indicePantallaActual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: listaPantallas[indicePantallaActual],

      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(icon: Icon(Icons.man), label: "Clientes"),
          NavigationDestination(icon: Icon(Icons.car_rental_sharp), label: "Vehiculos"),
        ],

        selectedIndex: indicePantallaActual,
        onDestinationSelected: (nuevoIndicePantalla) {
          setState(() {
            indicePantallaActual = nuevoIndicePantalla;
          });
        }
      ),
    );
  }
}
