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
          title: Text(
            "Elige qué quieres añadir",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
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
                  SizedBox(
                    height: 100,
                    width: 500,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, "añadir_cliente");
                      },
                      icon: Icon(Icons.person, size: 40),
                      label: Text("Nuevo Cliente"),
                      style: ElevatedButton.styleFrom(
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
                        Navigator.pushNamed(context, "añadir_vehiculo");
                      },
                      icon: Icon(Icons.directions_car_filled, size: 40),
                      label: Text("Nuevo Vehículo"),
                      style: ElevatedButton.styleFrom(
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
                        Navigator.pushNamed(context, "añadir_alquiler");
                      },
                      icon: Icon(Icons.assignment_turned_in, size: 40),
                      label: Text("Nuevo Alquiler"),
                      style: ElevatedButton.styleFrom(
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