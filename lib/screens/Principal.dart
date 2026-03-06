import 'package:flutter/material.dart';
import 'package:rebooty_repair/screens/anyadir/pantalla_anyadir.dart';
import 'package:rebooty_repair/screens/buscar/pantalla_buscar.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  List<Widget> listaPantallas = [PantallaAnyadir(), Pantallabuscar()];
  int indicePantallaActual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: listaPantallas[indicePantallaActual],

      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,

        destinations: [
          NavigationDestination(icon: Icon(Icons.add), label: "Añadir"),
          NavigationDestination(icon: Icon(Icons.search), label: "Buscar"),
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
