import 'package:flutter/material.dart';

class PantallaAnyadir extends StatefulWidget {
  const PantallaAnyadir({super.key});

  @override
  State<PantallaAnyadir> createState() => _PantallaAnyadirState();
}

class _PantallaAnyadirState extends State<PantallaAnyadir> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Elige qué quieres añadir", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        ),

        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),

                  // Botón añadir cliente
                  Boton(icono: Icons.person, titulo: "Nuevo Cliente", ruta: "añadir_cliente"),

                  SizedBox(height: 60),

                  // Botón añadir vehículo
                  Boton(icono: Icons.directions_car_filled, titulo: "Nuevo vehiculo", ruta: "añadir_vehiculo"),

                  SizedBox(height: 60),

                  // Botón añadir alquiler
                  Boton(icono: Icons.assignment_turned_in, titulo: "Nuevo alquiler", ruta: "añadir_alquiler"),
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
