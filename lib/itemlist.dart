import 'package:flutter/material.dart';

class ItemExpand extends StatefulWidget {
  final String title;
  final int id;
  final String subtitle;
  final int? estadoAtual;
  final VoidCallback? onPressedX;
  final VoidCallback? onPressedOpen;
  final VoidCallback? onPressedCard;

  const ItemExpand({
    super.key,
    required this.title,
    required this.id,
    required this.subtitle,
    this.estadoAtual,
    this.onPressedX,
    this.onPressedOpen,
    this.onPressedCard,
  });

  @override
  State<ItemExpand> createState() => _ItemExpandState();
}

class _ItemExpandState extends State<ItemExpand> {
  Color get corState {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (widget.estadoAtual) {
      case 0:
        return isDark
            ? const Color.fromARGB(255, 165, 139, 101) // Tema escuro
            : const Color.fromARGB(255, 56, 61, 92); // Tema claro
      case 1:
        return isDark
            ? const Color.fromARGB(255, 150, 106, 40)
            : const Color.fromARGB(255, 30, 29, 114);
      case 2:
        return isDark
            ? const Color.fromARGB(255, 255, 153, 0)
            : const Color.fromARGB(255, 4, 0, 219);
      default:
        return const Color.fromARGB(255, 128, 128, 128); // Cinza padrão
    }
  }

  String get nomeState {
    switch (widget.estadoAtual) {
      case 0:
        return 'iniciado';
      case 1:
        return 'em andamento';
      case 2:
        return 'concluida';
      default:
        return 'error';
    }
  }

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
                        onPressed: widget.onPressedOpen,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(4),
                          fixedSize: Size(120, 48),
                          backgroundColor: corState,
                        ),
                        child: Text(
                          nomeState,
                          style: TextStyle(
                            color: Color.fromARGB(255, 242, 242, 242),
                          ),
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
