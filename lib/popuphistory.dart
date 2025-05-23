import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organyz/database_helper.dart';
import 'package:intl/intl.dart';

Future<bool> showPopupHistory(
  BuildContext context,
  String label,
  List<Map<String, dynamic>> fieldLabels,
) async {
  Widget createOrdem(List<Map<String, dynamic>> dados) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: const [
            Expanded(flex: 1, child: Center(child: Text('Cont'))),
            Expanded(flex: 2, child: Center(child: Text('Tipo'))),
            Expanded(flex: 3, child: Center(child: Text('Tempo'))),
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
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(item['contAtual'].toString()),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(child: Text(item['direcao'])),
                          ),
                          Expanded(
                            flex: 3,
                            child: Center(child: Text(item['datadacontagem'])),
                          ),
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
            content: createOrdem(fieldLabels),
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
