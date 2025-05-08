import 'package:flutter/material.dart';

Future<void> showCustomPopup(
  BuildContext context,
  String label,
  List<String> fieldLabels,
  void Function(List<String> values) onConfirm,
) {
  final List<TextEditingController> controllers = List.generate(
    fieldLabels.length,
    (_) => TextEditingController(),
  );

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(
          child: Text(label), // Centraliza o título
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(fieldLabels.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: controllers[index],
                  decoration: InputDecoration(labelText: fieldLabels[index]),
                ),
              );
            }),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final values =
                  controllers.map((controller) => controller.text).toList();
              if (values.isEmpty) {
                values.add('true');
              }
              onConfirm(values);
              Navigator.of(context).pop();
            },
            child: const Text('Confirmar'),
          ),
        ],
      );
    },
  );
}
