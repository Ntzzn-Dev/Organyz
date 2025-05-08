import 'package:flutter/material.dart';

Future<bool> showCustomPopup(
  BuildContext context,
  String label,
  List<String> fieldLabels, {
  void Function(List<String> values)? onConfirm,
}) async {
  final List<TextEditingController> controllers = List.generate(
    fieldLabels.length,
    (_) => TextEditingController(),
  );

  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: Text(label)),
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
            onPressed: () => Navigator.of(context).pop(false),
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final values =
                  controllers.map((controller) => controller.text).toList();

              if (onConfirm != null) {
                onConfirm(values);
              }

              Navigator.of(context).pop(true);
            },
            child: const Text('Confirmar'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
