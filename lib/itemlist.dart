import 'package:flutter/material.dart';

class ItemExpand extends StatefulWidget {
  final String title;
  final int id;
  final String subtitle;
  final VoidCallback onPressedX;
  final VoidCallback? onPressedOpen;
  final VoidCallback? onPressedCard;

  const ItemExpand({
    super.key,
    required this.title,
    required this.id,
    required this.subtitle,
    required this.onPressedX,
    this.onPressedOpen,
    this.onPressedCard,
  });

  @override
  State<ItemExpand> createState() => _ItemExpandState();
}

class _ItemExpandState extends State<ItemExpand> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressedCard,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  widget.onPressedOpen == null
                      ? const SizedBox.shrink()
                      : ElevatedButton(
                        onPressed: widget.onPressedOpen, // Ação opcional
                        child: const Text('▼'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(1),
                        ),
                      ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: widget.onPressedX,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(1),
                    ),
                    child: const Text('X'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
