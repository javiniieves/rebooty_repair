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

                  // Botón añadir cliente
                  SizedBox(
                    height: 100,
                    width: 500,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, "buscar_cliente");
                      },
                      icon: Icon(Icons.person, size: 40),
                      label: Text("Cliente"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        elevation: 2,
                        textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 60),

                  // Botón añadir vehículo
                  SizedBox(
                    height: 100,
                    width: 500,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, "buscar_vehiculo");
                      },
                      icon: Icon(Icons.directions_car_filled, size: 40),
                      label: Text("Vehículo"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        elevation: 2,
                        textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 60),

                  // Botón añadir alquiler
                  SizedBox(
                    height: 100,
                    width: 500,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, "buscar_alquiler");
                      },
                      icon: Icon(Icons.assignment_turned_in, size: 40),
                      label: Text("Alquiler"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        elevation: 2,
                        textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
