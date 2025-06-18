import 'dart:developer';

import 'package:flutter/material.dart';

Future<bool> showPopupList(
  BuildContext context,
  String label,
  List<Map<String, dynamic>> values,
  List<Map<String, dynamic>> fieldLabels,
) async {
  Widget createOrdem(List<Map<String, dynamic>> dados) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (int i = 0; i < fieldLabels.length; i++) ...[
              Expanded(
                flex: fieldLabels[i]['flex'],
                child: Center(child: Text(fieldLabels[i]['name'])),
              ),
            ],
          ],
        ),

        const Divider(),

        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children:
                  dados.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          for (int i = 0; i < item.length; i++) ...[
                            Expanded(
                              flex: fieldLabels[i]['flex'],
                              child:
                                  fieldLabels[i]['centralize']
                                      ? Center(
                                        child: Text(
                                          item['valor${i + 1}'].toString(),
                                        ),
                                      )
                                      : Text(item['valor${i + 1}'].toString()),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Center(child: Text(label)),
            content: createOrdem(values),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Sair'),
              ),
            ],
          );
        },
      );
    },
  );

  return result ?? false;
}
