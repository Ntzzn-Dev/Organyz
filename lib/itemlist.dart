import 'package:flutter/material.dart';
import 'package:organyz/themes.dart';

class ItemExpand extends StatefulWidget {
  final int id;
  final String title;
  final String subtitle;
  final String? desc;
  final int? estadoAtual;
  final VoidCallback? onPressedDel;
  final VoidCallback? onPressedEdit;
  final VoidCallback? onPressedOpen;
  final VoidCallback? onPressedCard;
  final Widget? doAnything;
  final int? expandItem;

  const ItemExpand({
    super.key,
    required this.id,
    required this.title,
    required this.subtitle,
    this.desc,
    this.estadoAtual,
    this.onPressedDel,
    this.onPressedEdit,
    this.onPressedOpen,
    this.onPressedCard,
    this.doAnything,
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
    final customColors = Theme.of(context).extension<CustomColors>()!;

    switch (widget.estadoAtual) {
      case 0:
        return customColors.iniciado;
      case 1:
        return customColors.emAndamento;
      case 2:
        return customColors.concluido;
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

  ElevatedButton acceptButton() {
    final bool temEstado = widget.estadoAtual != null;

    return ElevatedButton(
      onPressed: widget.expandItem == 2 ? _toggleValue : widget.onPressedOpen,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(4),
        fixedSize: temEstado ? const Size(120, 48) : null,
        backgroundColor: temEstado ? corState : null,
      ),
      child:
          temEstado
              ? Text(
                nomeState,
                style: TextStyle(
                  color: temEstado ? Color.fromARGB(255, 242, 242, 242) : null,
                ),
              )
              : Icon(Icons.link_rounded),
    );
  }

  ElevatedButton deleteButton() {
    return ElevatedButton(
      onPressed: widget.onPressedDel,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Icon(Icons.delete),
    );
  }

  ElevatedButton editButton() {
    return ElevatedButton(
      onPressed: widget.onPressedEdit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Icon(Icons.edit),
    );
  }

  Text textDesc() {
    return Text(widget.desc!, textAlign: TextAlign.start);
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
                      : acceptButton(),
                  const SizedBox(width: 4),
                  widget.onPressedDel == null || widget.expandItem == 1
                      ? const SizedBox.shrink()
                      : deleteButton(),
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
                        isExpanded &&
                                (widget.desc != null || widget.expandItem == 1)
                            ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0.0,
                                vertical: 10.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  widget.desc != null
                                      ? textDesc()
                                      : const SizedBox.shrink(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      widget.doAnything ??
                                          const SizedBox.shrink(),
                                      Row(
                                        children: [
                                          editButton(),
                                          const SizedBox(width: 4),
                                          if (widget.expandItem == 1)
                                            deleteButton(),
                                        ],
                                      ),
                                    ],
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
