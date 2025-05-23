import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organyz/database_helper.dart';
import 'package:intl/intl.dart';

Future<bool> showCustomPopup(
  BuildContext context,
  String label,
  List<Map<String, dynamic>> fieldLabels, {
  List<String>? fieldValues,
  void Function(List<String> values)? onConfirm,
}) async {
  final List<TextEditingController> controllers = List.generate(
    fieldLabels.length,
    (index) => TextEditingController(
      text:
          fieldValues != null &&
                  index < fieldValues.length &&
                  fieldValues[index] != '' &&
                  fieldLabels[index]['type'].toLowerCase().contains('hex')
              ? '#${fieldValues[index]}'
              : fieldValues != null &&
                  index < fieldValues.length &&
                  fieldValues[index] != ''
              ? fieldValues[index]
              : fieldLabels[index]['type'].toLowerCase().contains('data')
              ? '__/__/____'
              : fieldLabels[index]['type'].toLowerCase().contains('hex')
              ? '#______'
              : '',
    ),
  );

  final List<Color> hexColors = List.generate(fieldLabels.length, (index) {
    if (fieldLabels[index]['type'].toLowerCase().contains('hex') &&
        fieldValues != null &&
        index < fieldValues.length &&
        fieldValues[index] != '') {
      try {
        // Limpa o valor e transforma em cor
        String cleaned = fieldValues[index].replaceAll('#', '').trim();
        return Color(int.parse('0xFF$cleaned'));
      } catch (_) {
        return Color.fromARGB(255, 255, 255, 255);
      }
    } else {
      return Color.fromARGB(255, 255, 255, 255);
    }
  });

  final List<bool> hasError = List.generate(
    fieldLabels.length,
    (index) => false,
  );

  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Center(child: Text(label)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(fieldLabels.length, (index) {
                  int tipoFormatacao =
                      fieldLabels[index]['type'].toLowerCase().contains('data')
                          ? 1
                          : fieldLabels[index]['type'].toLowerCase().contains(
                            'hex',
                          )
                          ? 2
                          : fieldLabels[index]['type'].toLowerCase().contains(
                            'num',
                          )
                          ? 3
                          : 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (fieldLabels[index]['type'].toLowerCase().contains(
                          'hex',
                        )) ...[
                          SizedBox(width: 5),
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: hexColors[index],
                              border: Border.all(width: 2),
                            ),
                          ),
                          SizedBox(width: 15),
                        ],
                        Expanded(
                          child: TextField(
                            controller: controllers[index],
                            maxLines: tipoFormatacao == 0 ? null : 1,
                            keyboardType:
                                tipoFormatacao == 0
                                    ? TextInputType.multiline
                                    : null,
                            textInputAction:
                                tipoFormatacao == 0
                                    ? TextInputAction.newline
                                    : null,
                            inputFormatters:
                                tipoFormatacao == 1
                                    ? [
                                      TextInputFormatter.withFunction((
                                        oldValue,
                                        newValue,
                                      ) {
                                        String digitsOnly = newValue.text
                                            .replaceAll(RegExp(r'[^0-9]'), '');

                                        if (newValue.text.length <
                                            oldValue.text.length) {
                                          if (digitsOnly.isNotEmpty &&
                                              oldValue.text.contains('_')) {
                                            digitsOnly = digitsOnly.substring(
                                              0,
                                              digitsOnly.length - 1,
                                            );
                                          }
                                        }

                                        String result = '';

                                        for (int i = 0; i < 8; i++) {
                                          if (digitsOnly.length > i) {
                                            result += digitsOnly[i];
                                          } else {
                                            result += '_';
                                          }
                                        }

                                        result =
                                            '${result.substring(0, 2)}/${result.substring(2, 4)}/${result.substring(4)}';

                                        return TextEditingValue(
                                          text: result,
                                          selection: TextSelection.collapsed(
                                            offset: result.length,
                                          ),
                                        );
                                      }),
                                    ]
                                    : tipoFormatacao == 2
                                    ? [
                                      TextInputFormatter.withFunction((
                                        oldValue,
                                        newValue,
                                      ) {
                                        String hexOnly = newValue.text
                                            .replaceAll(
                                              RegExp(r'[^0-9a-fA-F]'),
                                              '',
                                            );

                                        if (newValue.text.length <
                                            oldValue.text.length) {
                                          if (hexOnly.isNotEmpty &&
                                              oldValue.text.contains('_')) {
                                            hexOnly = hexOnly.substring(
                                              0,
                                              hexOnly.length - 1,
                                            );
                                          }
                                        }

                                        String result = '';

                                        for (int i = 0; i < 6; i++) {
                                          if (hexOnly.length > i) {
                                            result += hexOnly[i];
                                          } else {
                                            result += '_';
                                          }
                                        }

                                        result = '#$result';

                                        return TextEditingValue(
                                          text: result,
                                          selection: TextSelection.collapsed(
                                            offset: result.length,
                                          ),
                                        );
                                      }),
                                    ]
                                    : tipoFormatacao == 3
                                    ? [
                                      TextInputFormatter.withFunction((
                                        oldValue,
                                        newValue,
                                      ) {
                                        String digitsOnly = newValue.text
                                            .replaceAll(RegExp(r'[^0-9]'), '');

                                        return TextEditingValue(
                                          text: digitsOnly,
                                          selection: TextSelection.collapsed(
                                            offset: digitsOnly.length,
                                          ),
                                        );
                                      }),
                                    ]
                                    : [],
                            decoration: InputDecoration(
                              labelText: fieldLabels[index]['value'],
                              errorText:
                                  hasError[index] ? 'Campo inválido' : null,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      hasError[index]
                                          ? Colors.red
                                          : Colors.grey.shade400,
                                ),
                              ),
                            ),
                            onChanged: (text) {
                              if (fieldLabels[index]['type']
                                  .toLowerCase()
                                  .contains('hex')) {
                                try {
                                  String cleaned =
                                      text.replaceAll('#', '').trim();
                                  if (cleaned.length == 6 ||
                                      cleaned.length == 8) {
                                    Color newColor = Color(
                                      int.parse('0xFF$cleaned'),
                                    );
                                    setState(() {
                                      hexColors[index] = newColor;
                                    });
                                  }
                                } catch (_) {}
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  bool dataEValida(String dataStr) {
                    try {
                      DateFormat format = DateFormat('dd/MM/yyyy');
                      format.parseStrict(dataStr);
                      return true;
                    } catch (e) {
                      return false;
                    }
                  }

                  final values =
                      controllers.map((controller) => controller.text).toList();

                  List<int> matchingIndicesData = [];
                  List<int> matchingIndicesTitle = [];
                  List<int> matchingIndicesHex = [];
                  List<int> matchingIndicesNecessarys = [];

                  for (var entry in fieldLabels.asMap().entries) {
                    final index = entry.key;
                    final type = entry.value['type'].toLowerCase();

                    if (type.contains('data')) matchingIndicesData.add(index);
                    if (type.contains('title')) matchingIndicesTitle.add(index);
                    if (type.contains('hex')) matchingIndicesHex.add(index);
                    if (type.contains('necessary'))
                      matchingIndicesNecessarys.add(index);
                  }

                  bool hasAnyError = false;

                  for (int i in matchingIndicesData) {
                    String digitsOnly = values[i].replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    if (digitsOnly.length < 8 || !dataEValida(values[i])) {
                      setState(() {
                        hasError[i] = true;
                      });
                      hasAnyError = true;
                    } else {
                      setState(() {
                        hasError[i] = false;
                      });
                    }
                  }

                  for (int i in matchingIndicesTitle) {
                    String tituloEscolhido = values[i];
                    if (tituloEscolhido.trim() !=
                        (await DatabaseHelper().verifyTitle(
                          tituloEscolhido,
                          'repository',
                          currentId: fieldLabels[i]['id'],
                        )).trim()) {
                      setState(() {
                        hasError[i] = true;
                      });
                      hasAnyError = true;
                    } else if (tituloEscolhido == "" ||
                        tituloEscolhido.isEmpty) {
                      setState(() {
                        hasError[i] = true;
                      });
                      hasAnyError = true;
                    } else {
                      setState(() {
                        hasError[i] = false;
                      });
                    }
                  }

                  for (int i in matchingIndicesHex) {
                    String hexOnly = values[i].replaceAll(
                      RegExp(r'[^0-9a-fA-F]'),
                      '',
                    );
                    if (hexOnly.isNotEmpty && hexOnly.length < 6) {
                      setState(() {
                        hasError[i] = true;
                      });
                      hasAnyError = true;
                    } else {
                      setState(() {
                        hasError[i] = false;
                      });
                    }
                    values[i] = values[i].replaceAll(
                      RegExp(r'[^0-9a-fA-F]'),
                      '',
                    );
                  }

                  for (int i in matchingIndicesNecessarys) {
                    String tituloEscolhido = values[i];
                    if (tituloEscolhido == "" || tituloEscolhido.isEmpty) {
                      setState(() {
                        hasError[i] = true;
                      });
                      hasAnyError = true;
                    } else {
                      setState(() {
                        hasError[i] = false;
                      });
                    }
                  }

                  if (hasAnyError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Corrija os campos')),
                    );
                    return;
                  }

                  if (onConfirm != null) {
                    onConfirm(values);
                  }

                  Navigator.of(context).pop(true);
                },
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );
    },
  );

  return result ?? false;
}
