import 'package:flutter/material.dart';

class Pantallabuscar extends StatefulWidget {
  const Pantallabuscar({super.key});

  @override
  State<Pantallabuscar> createState() => _PantallabuscarState();
}

class _PantallabuscarState extends State<Pantallabuscar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Elige qué quieres buscar",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
        ),

        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView( // Añadido por si la pantalla es pequeña
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),

                  // Botón buscar cliente
                  Boton(icono: Icons.person, titulo: "Lista de clientes", ruta: "buscar_cliente"),

                  SizedBox(height: 60),

                  // Botón buscar vehículo
                  Boton(icono: Icons.directions_car_filled, titulo: "Lista de vehiculos", ruta: "buscar_vehiculo"),

                  SizedBox(height: 60),

                  // Botón buscar alquiler
                  Boton(icono: Icons.assignment_turned_in, titulo: "Lista de alquileres", ruta: "buscar_alquiler"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Boton extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String ruta;

  const Boton({super.key, required this.icono, required this.titulo, required this.ruta});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 500,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, ruta);
        },
        icon: Icon(icono, size: 40),
        label: Text(titulo),
        style: ElevatedButton.styleFrom(
          elevation: 2,
          textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(width: 2)),
        ),
      ),
    );
  }
}
