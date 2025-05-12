import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organyz/database_helper.dart';

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
          fieldValues != null && index < fieldValues.length
              ? fieldValues[index]
              : fieldLabels[index]['type'].toLowerCase().contains('data')
              ? 'xx/xx/xxxx'
              : '',
    ),
  );

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
                  bool isDateField = fieldLabels[index]['type']
                      .toLowerCase()
                      .contains('data');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: controllers[index],
                      inputFormatters:
                          isDateField
                              ? [
                                TextInputFormatter.withFunction((
                                  oldValue,
                                  newValue,
                                ) {
                                  String digitsOnly = newValue.text.replaceAll(
                                    RegExp(r'[^0-9]'),
                                    '',
                                  );

                                  if (newValue.text.length <
                                      oldValue.text.length) {
                                    if (digitsOnly.isNotEmpty &&
                                        oldValue.text.contains('x')) {
                                      digitsOnly = digitsOnly.substring(
                                        0,
                                        digitsOnly.length - 1,
                                      );
                                    }
                                  }

                                  String result = '';

                                  for (int i = 0; i < 8; i++) {
                                    if (digitsOnly.length > i) {
                                      if (i == 0) {
                                        result +=
                                            (int.parse(digitsOnly[i]) > 3)
                                                ? 'x'
                                                : digitsOnly[i];
                                      } else if (i == 1) {
                                        result +=
                                            (int.parse(digitsOnly[i - 1]) ==
                                                        3 &&
                                                    int.parse(digitsOnly[i]) >
                                                        1)
                                                ? 'x'
                                                : digitsOnly[i];
                                      } else if (i == 2) {
                                        result +=
                                            (int.parse(digitsOnly[i]) > 1)
                                                ? 'x'
                                                : digitsOnly[i];
                                      } else if (i == 3) {
                                        result +=
                                            (int.parse(digitsOnly[i - 1]) ==
                                                        1 &&
                                                    int.parse(digitsOnly[i]) >
                                                        2)
                                                ? 'x'
                                                : digitsOnly[i];
                                      } else {
                                        result += digitsOnly[i];
                                      }
                                    } else {
                                      result += 'x';
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
                              : [],
                      decoration: InputDecoration(
                        labelText: fieldLabels[index]['value'],
                        errorText: hasError[index] ? 'Campo inválido' : null,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                hasError[index]
                                    ? Colors.red
                                    : Colors.grey.shade400,
                          ),
                        ),
                      ),
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
                  final values =
                      controllers.map((controller) => controller.text).toList();

                  List<int> matchingIndicesData =
                      fieldLabels
                          .asMap()
                          .entries
                          .where(
                            (entry) => entry.value['type']
                                .toLowerCase()
                                .contains('data'),
                          )
                          .map((entry) => entry.key)
                          .toList();

                  List<int> matchingIndicesTitle =
                      fieldLabels
                          .asMap()
                          .entries
                          .where(
                            (entry) => entry.value['type']
                                .toLowerCase()
                                .contains('title'),
                          )
                          .map((entry) => entry.key)
                          .toList();

                  bool hasAnyError = false;

                  for (int i in matchingIndicesData) {
                    String digitsOnly = values[i].replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    if (digitsOnly.length < 8) {
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
