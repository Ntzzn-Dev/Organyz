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

  /*textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Color.fromARGB(255, 11, 3, 80),
    displayColor: Color.fromARGB(255, 11, 3, 80),
  ),*/
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
    floatingLabelStyle: TextStyle(
      color: Color.fromARGB(255, 11, 3, 80),
      fontSize: 20,
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
  extensions: <ThemeExtension<dynamic>>[
    const CustomColors(
      iniciado: Color.fromARGB(255, 75, 76, 83),
      emAndamento: Color.fromARGB(255, 99, 99, 136),
      concluido: Color.fromARGB(255, 4, 0, 219),
      eventoSelecionado: Color.fromARGB(255, 27, 27, 44),
      eventoAtual: Color.fromARGB(255, 61, 60, 71),
      justSelecionado: Color.fromARGB(255, 41, 41, 56),
      justAtual: Color.fromARGB(255, 191, 191, 211),
      days: Color.fromARGB(255, 0, 0, 0),
      months: Color.fromARGB(255, 86, 86, 141),
      weekends: Color.fromARGB(255, 99, 99, 136),
    ),
  ],
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
      fontSize: 18,
      color: Color.fromARGB(255, 242, 242, 242),
      fontWeight: FontWeight.w900,
    ),
    floatingLabelStyle: TextStyle(
      color: Color.fromARGB(255, 243, 160, 34),
      fontSize: 20,
      fontWeight: FontWeight.w900,
    ),
    hintStyle: TextStyle(color: Colors.grey),

    filled: true,
    fillColor: Color.fromRGBO(60, 60, 60, 0.5),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Color.fromARGB(255, 243, 160, 34),
        width: 2.0,
      ),
    ),
  ),
  extensions: <ThemeExtension<dynamic>>[
    const CustomColors(
      iniciado: Color.fromARGB(255, 165, 139, 101),
      emAndamento: Color.fromARGB(255, 150, 106, 40),
      concluido: Color.fromARGB(255, 255, 153, 0),
      eventoSelecionado: Color.fromARGB(255, 73, 62, 45),
      eventoAtual: Color.fromARGB(255, 82, 69, 50),
      justSelecionado: Color.fromARGB(255, 105, 89, 64),
      justAtual: Color.fromARGB(255, 58, 58, 57),
      days: Color.fromARGB(255, 214, 214, 214),
      months: Color.fromARGB(255, 190, 144, 84),
      weekends: Color.fromARGB(255, 139, 120, 85),
    ),
  ],
);

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color iniciado;
  final Color emAndamento;
  final Color concluido;
  final Color eventoSelecionado;
  final Color eventoAtual;
  final Color justSelecionado;
  final Color justAtual;
  final Color days;
  final Color months;
  final Color weekends;

  const CustomColors({
    required this.iniciado,
    required this.emAndamento,
    required this.concluido,
    required this.eventoSelecionado,
    required this.eventoAtual,
    required this.justSelecionado,
    required this.justAtual,
    required this.days,
    required this.months,
    required this.weekends,
  });

  @override
  CustomColors copyWith({
    Color? iniciado,
    Color? emAndamento,
    Color? concluido,
    Color? eventoSelecionado,
    Color? eventoAtual,
    Color? justSelecionado,
    Color? justAtual,
    Color? days,
    Color? months,
    Color? weekends,
  }) {
    return CustomColors(
      iniciado: iniciado ?? this.iniciado,
      emAndamento: emAndamento ?? this.emAndamento,
      concluido: concluido ?? this.concluido,
      eventoSelecionado: eventoSelecionado ?? this.eventoSelecionado,
      eventoAtual: eventoAtual ?? this.eventoAtual,
      justSelecionado: justSelecionado ?? this.justSelecionado,
      justAtual: justAtual ?? this.justAtual,
      days: days ?? this.days,
      months: months ?? this.months,
      weekends: weekends ?? this.weekends,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      iniciado: Color.lerp(iniciado, other.iniciado, t)!,
      emAndamento: Color.lerp(emAndamento, other.emAndamento, t)!,
      concluido: Color.lerp(concluido, other.concluido, t)!,
      eventoSelecionado:
          Color.lerp(eventoSelecionado, other.eventoSelecionado, t)!,
      eventoAtual: Color.lerp(eventoAtual, other.eventoAtual, t)!,
      justSelecionado: Color.lerp(justSelecionado, other.justSelecionado, t)!,
      justAtual: Color.lerp(justAtual, other.justAtual, t)!,
      days: Color.lerp(days, other.days, t)!,
      months: Color.lerp(months, other.months, t)!,
      weekends: Color.lerp(weekends, other.weekends, t)!,
    );
  }
}
