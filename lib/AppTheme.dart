import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData tema = ThemeData(
    primaryColor: const Color(0xFF2F3136),
    useMaterial3: true,

    // gris oscuro de la pared
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2F3136),
      primary: const Color(0xFF2F3136),
      secondary: const Color(0xFF3A7D44), // verde plantas
      tertiary: const Color(0xFFC8A97E),
    ),

    scaffoldBackgroundColor: Colors.grey.shade600,

    // gris claro de muebles
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2F3136),
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFC8A97E)),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16, color: Color(0xFFC8A97E)),
      titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFC8A97E)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Color(0xFFC8A97E),
        backgroundColor: Color(0xFF2F3136),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    cardTheme: CardThemeData(
      color: Color(0xFF2F3136),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    iconTheme: const IconThemeData(color: Color(0xFF3A7D44)),

    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFF2F3136),
      indicatorColor: Color(0xFF3A7D44),
      iconTheme: WidgetStatePropertyAll(IconThemeData(color: Color(0xFFC8A97E))),
      labelTextStyle: WidgetStatePropertyAll(TextStyle(color: Color(0xFFC8A97E))),
    ),

    dropdownMenuTheme: const DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          Color(0xFF2F3136), // fondo del menú
        ),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
        elevation: WidgetStatePropertyAll(4),
      ),
    ),

    listTileTheme: const ListTileThemeData(
      tileColor: Color(0xFF2F3136), // fondo de cada item
      textColor: Color(0xFFC8A97E), // color de texto
      iconColor: Color(0xFF3A7D44), // color de íconos
      selectedColor: Color(0xFF3A7D44), // color al seleccionar
      //contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: Color(0xFFC8A97E),
      filled: true,
      fillColor: Color(0xFF2F3136),

      labelStyle: TextStyle(color: Color(0xFFC8A97E)),

      hintStyle: TextStyle(color: Colors.grey),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFFC8A97E), width: 1.5),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          color: Color(0xFF3A7D44), // verde cuando se selecciona
          width: 2,
        ),
      ),

      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),

      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
