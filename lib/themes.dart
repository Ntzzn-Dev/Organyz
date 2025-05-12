import 'package:flutter/material.dart';

Color hsvToRgb(Color color, double s, double v) {
  final hsl = HSLColor.fromColor(color);

  double c = v * s;
  double x = c * (1 - ((hsl.hue / 60) % 2 - 1).abs());
  double m = v - c;

  double r_, g_, b_;

  if (hsl.hue < 60) {
    r_ = c;
    g_ = x;
    b_ = 0;
  } else if (hsl.hue < 120) {
    r_ = x;
    g_ = c;
    b_ = 0;
  } else if (hsl.hue < 180) {
    r_ = 0;
    g_ = c;
    b_ = x;
  } else if (hsl.hue < 240) {
    r_ = 0;
    g_ = x;
    b_ = c;
  } else if (hsl.hue < 300) {
    r_ = x;
    g_ = 0;
    b_ = c;
  } else {
    r_ = c;
    g_ = 0;
    b_ = x;
  }

  int r = ((r_ + m) * 255).round();
  int g = ((g_ + m) * 255).round();
  int b = ((b_ + m) * 255).round();

  return Color.fromARGB(255, r, g, b);
}

Map<String, Color> gerarTons(Color base) {
  return {
    'iniciado': hsvToRgb(base, 0.2, 0.3),
    'emAndamento': hsvToRgb(base, 0.4, 0.6),
    'concluido': base,
  };
}

ThemeData lighttheme(Color corPrimaria) {
  final tons = gerarTons(corPrimaria);
  return ThemeData(
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: Color.fromARGB(255, 242, 242, 242),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 237, 237, 237),
      foregroundColor: corPrimaria,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 242, 242, 242),
        foregroundColor: corPrimaria,
      ),
    ),
    cardTheme: CardTheme(color: Color.fromARGB(255, 242, 242, 242)),
    dialogTheme: DialogTheme(
      backgroundColor: Color.fromARGB(255, 242, 242, 242),
    ),

    /*textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Color.fromARGB(255, 11, 3, 80),
    displayColor: Color.fromARGB(255, 11, 3, 80),
  ),*/
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      floatingLabelStyle: TextStyle(
        color: corPrimaria,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
      hintStyle: TextStyle(color: Colors.grey),

      filled: true,
      fillColor: Color.fromRGBO(228, 228, 228, 0.5),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: corPrimaria, width: 2.0),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: corPrimaria.withAlpha(60),
      cursorColor: Color.fromARGB(255, 0, 0, 0),
      selectionHandleColor: corPrimaria,
    ),
    extensions: <ThemeExtension<dynamic>>[
      CustomColors(
        iniciado: tons['iniciado'] ?? Color.fromARGB(255, 165, 139, 101),
        emAndamento: tons['emAndamento'] ?? Color.fromARGB(255, 150, 106, 40),
        concluido: tons['concluido'] ?? Color.fromARGB(255, 255, 153, 0),
        eventoSelecionado: Color.fromARGB(255, 73, 62, 45),
        eventoAtual: Color.fromARGB(255, 82, 69, 50),
        justSelecionado: Color.fromARGB(255, 105, 89, 64),
        justAtual: Color.fromARGB(255, 191, 191, 211),
        days: Color.fromARGB(255, 0, 0, 0),
        months: Color.fromARGB(255, 190, 144, 84),
        weekends: Color.fromARGB(255, 139, 120, 85),
      ),
    ],
  );
}

ThemeData darkTheme(Color corPrimaria) {
  final tons = gerarTons(corPrimaria);
  return ThemeData(
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: Color.fromARGB(255, 64, 64, 64),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 37, 37, 37),
      foregroundColor: corPrimaria,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 64, 64, 64),
        foregroundColor: corPrimaria,
      ),
    ),
    cardTheme: CardTheme(color: Color.fromARGB(255, 64, 64, 64)),
    dialogTheme: DialogTheme(backgroundColor: Color.fromARGB(255, 64, 64, 64)),

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
        color: corPrimaria,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
      hintStyle: TextStyle(color: Colors.grey),

      filled: true,
      fillColor: Color.fromRGBO(60, 60, 60, 0.5),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: corPrimaria, width: 2.0),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: corPrimaria.withAlpha(60),
      cursorColor: Color.fromARGB(255, 0, 0, 0),
      selectionHandleColor: corPrimaria,
    ),
    extensions: <ThemeExtension<dynamic>>[
      CustomColors(
        iniciado: tons['iniciado'] ?? Color.fromARGB(255, 165, 139, 101),
        emAndamento: tons['emAndamento'] ?? Color.fromARGB(255, 150, 106, 40),
        concluido: tons['concluido'] ?? Color.fromARGB(255, 255, 153, 0),
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
}

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
    Color? iniciadoDefault,
    Color? emAndamento,
    Color? emAndamentoDefault,
    Color? concluido,
    Color? concluidoDefault,
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
