import 'package:flutter/material.dart';

class ItemExpand extends StatefulWidget {
  final int id;
  final String title;
  final String subtitle;
  final String? desc;
  final int? estadoAtual;
  final VoidCallback? onPressedX;
  final VoidCallback? onPressedOpen;
  final VoidCallback? onPressedCard;
  final int? expandItem;

  const ItemExpand({
    super.key,
    required this.id,
    required this.title,
    required this.subtitle,
    this.desc,
    this.estadoAtual,
    this.onPressedX,
    this.onPressedOpen,
    this.onPressedCard,
    this.expandItem,
  });

  @override
  State<ItemExpand> createState() => _ItemExpandState();
}

class _ItemExpandState extends State<ItemExpand> {
  ValueNotifier<bool> isExpandedNotifier = ValueNotifier<bool>(false);

  void _toggleValue() {
    isExpandedNotifier.value = !isExpandedNotifier.value;
  }

  Color get corState {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (widget.estadoAtual) {
      case 0:
        return isDark
            ? const Color.fromARGB(255, 165, 139, 101)
            : const Color.fromARGB(255, 75, 76, 83);
      case 1:
        return isDark
            ? const Color.fromARGB(255, 150, 106, 40)
            : const Color.fromARGB(255, 99, 99, 136);
      case 2:
        return isDark
            ? const Color.fromARGB(255, 255, 153, 0)
            : const Color.fromARGB(255, 4, 0, 219);
      default:
        return const Color.fromARGB(255, 128, 128, 128);
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
      onTap: widget.expandItem == 1 ? _toggleValue : widget.onPressedCard,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  widget.onPressedOpen == null
                      ? const SizedBox.shrink()
                      : ElevatedButton(
                        onPressed:
                            widget.expandItem == 2
                                ? _toggleValue
                                : widget.onPressedOpen,
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
                  widget.onPressedX == null
                      ? const SizedBox.shrink()
                      : ElevatedButton(
                        onPressed:
                            widget.expandItem == 2
                                ? _toggleValue
                                : widget.onPressedX,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(1),
                        ),
                        child: const Text('X'),
                      ),
                ],
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isExpandedNotifier,
                builder: (context, isExpanded, child) {
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topRight,
                    child:
                        isExpanded && widget.desc != null
                            ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0.0,
                                vertical: 10.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.desc!,
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                            )
                            : const SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
