import 'package:flutter/material.dart';

final ThemeData lighttheme = ThemeData(
  primarySwatch: Colors.deepPurple,
  scaffoldBackgroundColor: const Color.fromARGB(255, 242, 242, 242),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 237, 237, 237),
    foregroundColor: Color.fromARGB(255, 11, 3, 80),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 242, 242, 242),
      foregroundColor: Color.fromARGB(255, 11, 3, 80),
    ),
  ),
  cardTheme: CardTheme(color: Color.fromARGB(255, 242, 242, 242)),
  dialogTheme: DialogTheme(backgroundColor: Color.fromARGB(255, 242, 242, 242)),

  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
    floatingLabelStyle: TextStyle(
      color: Color.fromARGB(255, 11, 3, 80),
      fontSize: 24,
      fontWeight: FontWeight.w900,
    ),
    hintStyle: TextStyle(color: Colors.grey),

    filled: true,
    fillColor: Color.fromRGBO(228, 228, 228, 0.5),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Color.fromARGB(255, 11, 3, 80), // Cor da borda ao focar
        width: 2.0,
      ),
    ),
  ),
);

final ThemeData darktheme = ThemeData(
  primarySwatch: Colors.deepPurple,
  scaffoldBackgroundColor: const Color.fromARGB(255, 46, 46, 46),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 37, 37, 37),
    foregroundColor: Color.fromARGB(255, 243, 160, 34),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 46, 46, 46),
      foregroundColor: Color.fromARGB(255, 243, 160, 34),
    ),
  ),
  cardTheme: CardTheme(color: Color.fromARGB(255, 46, 46, 46)),
  dialogTheme: DialogTheme(backgroundColor: Color.fromARGB(255, 46, 46, 46)),

  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Color.fromARGB(255, 242, 242, 242),
    displayColor: Color.fromARGB(255, 242, 242, 242),
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(
      color: Color.fromARGB(255, 242, 242, 242),
      fontSize: 24,
      fontWeight: FontWeight.w900,
    ),
    floatingLabelStyle: TextStyle(
      color: Color.fromARGB(255, 243, 160, 34),
      fontSize: 24,
      fontWeight: FontWeight.w900,
    ),
    hintStyle: TextStyle(color: Colors.grey),

    filled: true,
    fillColor: Color.fromRGBO(60, 60, 60, 0.5),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromARGB(255, 238, 223, 201), // cor fixa
        width: 2.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Color.fromARGB(255, 243, 160, 34), // Cor da borda ao focar
        width: 2.0,
      ),
    ),
  ),
);
