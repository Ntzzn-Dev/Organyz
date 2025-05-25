import 'package:flutter/material.dart';

class TextAreaList extends StatelessWidget {
  final TextEditingController controller;
  final ValueNotifier<String> labelNtf;
  final int minLines;
  final int maxLines;
  final VoidCallback? onPressedDel;
  final VoidCallback? onPressedEdit;
  final ValueChanged<String> onTextChanged;

  const TextAreaList({
    super.key,
    required this.controller,
    required this.labelNtf,
    this.minLines = 2,
    this.maxLines = 15,
    this.onPressedDel,
    this.onPressedEdit,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ValueListenableBuilder<String>(
              valueListenable: labelNtf,
              builder: (context, value, _) {
                return TextField(
                  controller: controller,
                  minLines: minLines,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    labelText: value,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  onChanged: (text) {
                    onTextChanged(text);
                  },
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(10),
            ),
            onPressed: onPressedDel,
            child: const Icon(Icons.close, size: 20),
          ),
        ),
        Positioned(
          top: 8,
          right: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(10),
            ),
            onPressed: onPressedEdit,
            child: const Icon(Icons.edit, size: 20),
          ),
        ),
      ],
    );
  }
}
