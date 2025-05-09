import 'package:flutter/material.dart';

class TextAreaList extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int minLines;
  final int maxLines;
  final VoidCallback? onPressedX;
  final ValueChanged<String> onTextChanged;

  const TextAreaList({
    super.key,
    required this.controller,
    this.label = 'Digite algo...',
    this.minLines = 2,
    this.maxLines = 5,
    this.onPressedX,
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
            child: TextField(
              controller: controller,
              minLines: minLines,
              maxLines: maxLines,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: (text) {
                onTextChanged(text);
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
            onPressed: onPressedX,
            child: const Icon(Icons.close, size: 20),
          ),
        ),
      ],
    );
  }
}
