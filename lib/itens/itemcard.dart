import 'dart:developer';

import 'package:flutter/material.dart';

class ItemCard extends StatefulWidget {
  final int id;
  final String type;
  final ValueNotifier<String> titleNtf;
  final ValueNotifier<String> subtitleNtf;
  final ValueNotifier<String>? descNtf;
  final ValueNotifier<Color>? colorNtf;
  final VoidCallback? onPressedDel;
  final VoidCallback? onPressedEdit;
  final VoidCallback? onPressedCard;
  final Widget? doAnythingDown;
  final Widget? doAnythingUp;
  final ValueNotifier<List<Widget>>? widgetDesc;
  final bool? isExpanded;
  final Function(List<int>)? ordemWidgets;

  const ItemCard({
    super.key,
    required this.id,
    required this.type,
    required this.titleNtf,
    required this.subtitleNtf,
    this.descNtf,
    this.colorNtf,
    this.onPressedDel,
    this.onPressedEdit,
    this.onPressedCard,
    this.doAnythingDown,
    this.doAnythingUp,
    this.widgetDesc,
    this.isExpanded,
    this.ordemWidgets,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  late ValueNotifier<bool> isExpandedNotifier;

  @override
  void initState() {
    super.initState();
    isExpandedNotifier = ValueNotifier<bool>(widget.isExpanded ?? false);
  }

  void _toggleValue() {
    isExpandedNotifier.value = !isExpandedNotifier.value;
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

  Widget descExpand() {
    return widget.widgetDesc != null
        ? ValueListenableBuilder<List<Widget>>(
          valueListenable: widget.widgetDesc!,
          builder: (context, list, _) {
            return ReorderableListView(
              shrinkWrap: true,
              onReorder: (oldIndex, newIndex) {
                final newList = List<Widget>.from(list);
                if (newIndex > oldIndex) newIndex -= 1;
                final item = newList.removeAt(oldIndex);
                newList.insert(newIndex, item);
                widget.widgetDesc!.value = newList;

                log(saveNewOrder(newList).length.toString());
                widget.ordemWidgets!(saveNewOrder(newList));
              },
              children: list,
            );
          },
        )
        : Text(widget.descNtf?.value ?? '', textAlign: TextAlign.start);
  }

  List<int> saveNewOrder(List<Widget> newList) {
    return newList
        .map((widget) {
          final key = widget.key;
          if (key is ValueKey) {
            final value = key.value;
            if (value is String) {
              return int.tryParse(value.split('_')[0]);
            }
          }
          return null;
        })
        .whereType<int>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable:
          widget.colorNtf ??
          ValueNotifier<Color>(
            Theme.of(context).cardTheme.color ?? Colors.white,
          ),
      builder: (context, color, _) {
        return InkWell(
          onTap: () {
            widget.onPressedCard?.call();
            if (widget.type != 'repo') {
              _toggleValue();
            }
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: color,
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
                            ValueListenableBuilder<String>(
                              valueListenable: widget.titleNtf,
                              builder: (context, value, _) {
                                return Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            ValueListenableBuilder<String>(
                              valueListenable: widget.subtitleNtf,
                              builder: (context, value, _) {
                                return Text(
                                  value,
                                  style:
                                      widget.type == 'cont'
                                          ? TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          )
                                          : const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      widget.doAnythingUp ?? const SizedBox.shrink(),
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
                                    (widget.descNtf != null ||
                                        widget.onPressedDel != null ||
                                        widget.onPressedEdit != null) &&
                                    widget.type != 'repo'
                                ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 0.0,
                                    vertical: 10.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      widget.descNtf != null
                                          ? descExpand()
                                          : const SizedBox.shrink(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          widget.doAnythingDown ??
                                              const SizedBox.shrink(),
                                          Row(
                                            children: [
                                              widget.onPressedEdit != null
                                                  ? editButton()
                                                  : const SizedBox.shrink(),
                                              const SizedBox(width: 4),
                                              widget.onPressedDel != null
                                                  ? deleteButton()
                                                  : const SizedBox.shrink(),
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
      },
    );
  }
}
