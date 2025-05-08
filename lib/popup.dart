import 'package:flutter/material.dart';

Future<void> showCustomPopup(
  BuildContext context,
  String label,
  String titulo,
  String subtitulo,
  void Function(String title, String subtitle) onConfirm,
) {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController subtitleController = TextEditingController();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: titulo),
            ),
            const SizedBox(height: 10),
            subtitulo == ''
                ? SizedBox.shrink()
                : TextField(
                  controller: subtitleController,
                  decoration: InputDecoration(labelText: subtitulo),
                ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              subtitulo == ''
                  ? onConfirm(titleController.text, '')
                  : onConfirm(titleController.text, subtitleController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Confirmar'),
          ),
        ],
      );
    },
  );
}
