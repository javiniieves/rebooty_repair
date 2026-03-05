import 'package:flutter/material.dart';

class DetallesClienteScreen extends StatefulWidget {
  const DetallesClienteScreen({super.key});

  @override
  State<DetallesClienteScreen> createState() => _DetallesClienteScreenState();
}

class _DetallesClienteScreenState extends State<DetallesClienteScreen> {
  @override
  Widget build(BuildContext context) {
    final cliente = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text("", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.only(top: 20),

                ),
              ),

              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                child: Text(
                  cliente['nombre'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),

              SizedBox(height: 20),
              Column(
                children: [
                  Center(
                    child: Text(
                      'DNI: ${cliente['dni']}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Telefono: ${cliente['telefono']}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
