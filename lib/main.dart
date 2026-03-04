import 'package:flutter/material.dart';
import 'package:rebooty_repair/screens/Principal.dart';

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
    );
  }
}
