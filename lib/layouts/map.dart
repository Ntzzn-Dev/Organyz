import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:organyz/database_helper.dart';
import 'package:organyz/itens/itemcard.dart';
import 'package:organyz/itens/popup.dart';
import 'package:organyz/themes.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final mapController = MapController();

  Marker? selectMark;
  ValueNotifier endereco = ValueNotifier("");

  List<Map<String, dynamic>> selectedPoints = [];
  List<LatLng> routePoints = [];
  double totalDistanceKm = 0;

  List<Marker> marcadores = [];

  List<Map<String, dynamic>> coords = [];
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> ajusteFino(item) {
    return showPopup(
      context,
      'Editar Mapa',
      [
        {'value': 'Descrição', 'type': 'necessary'},
        {'value': 'Endereço', 'type': 'text'},
        {'value': 'Latitude', 'type': 'text'},
        {'value': 'Longitude', 'type': 'text'},
        {'value': 'Icone', 'type': 'dropdown'},
        {'value': 'Cor', 'type': 'hex'},
      ],
      fieldValues: [
        item['desc'],
        item['endereco'],
        item['lat'].toString(),
        item['long'].toString(),
        item['icon'],
        item['colorIcon'],
      ],
      onConfirm: (valores) async {
        await DatabaseHelper().updateMaps(
          item['idpoint'],
          valores[0],
          valores[1],
          double.parse(valores[2]),
          double.parse(valores[3]),
          valores[4],
          valores[5],
          item['ordem'],
        );

        await _loadItems();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Mapa Atualizado')));
        }
      },
    );
  }

  Future<void> listarPontos(
    Future<void> Function(Map<String, dynamic>) cardEvent,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecionar Ponto'),
          insetPadding: const EdgeInsets.all(8),
          contentPadding: const EdgeInsets.all(6),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: coords.length,
              itemBuilder: (context, index) {
                final item = coords[index];
                final icon = Icon(
                  getIconFromString(item['icon']),
                  color: hexToColor(item['colorIcon']),
                );
                return ItemCard(
                  id: index,
                  type: 'repo',
                  titleNtf: ValueNotifier(item['desc']),
                  subtitleNtf: ValueNotifier(item['endereco']),
                  iconNtf: ValueNotifier(icon),
                  onPressedCard: () async {
                    await cardEvent(item);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> adicionarPonto(Map<String, dynamic> item) async {
    selectedPoints.add({
      'name': item['desc'],
      'icon': item['icon'],
      'colorIcon': item['colorIcon'],
      'distP0': 0,
      'distPAnt': 0,
      'lat': item['lat'],
      'long': item['long'],
    });

    if (selectedPoints.length >= 2) {
      await getMultiRoute();
    }

    setState(() {});
  }

  Future<void> atualizarPonto(Map<String, dynamic> item, LatLng coord) async {
    final end = await getAddressFromLatLng(coord.latitude, coord.longitude);

    await DatabaseHelper().updateMaps(
      item['idpoint'],
      item['desc'],
      end ?? item['endereco'],
      coord.latitude,
      coord.longitude,
      item['icon'],
      item['colorIcon'],
      item['ordem'],
    );

    await _loadItems();
  }

  Future<void> criarPonto(LatLng coord) async {
    List<Map<String, dynamic>> repos = await DatabaseHelper().getRepo();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecionar Repositório'),
          insetPadding: const EdgeInsets.all(8),
          contentPadding: const EdgeInsets.all(6),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: repos.length,
              itemBuilder: (context, index) {
                final item = repos[index];
                return ItemCard(
                  id: index,
                  type: 'repo',
                  titleNtf: ValueNotifier(item['title']),
                  subtitleNtf: ValueNotifier(item['subtitle']),
                  onPressedCard: () async {
                    final end = await getAddressFromLatLng(
                      coord.latitude,
                      coord.longitude,
                    );
                    showPopup(
                      context,
                      'Adicionar Mapa',
                      [
                        {'value': 'Descrição', 'type': 'necessary'},
                        {'value': 'Endereço', 'type': 'text'},
                        {'value': 'Icone', 'type': 'dropdown'},
                        {'value': 'Cor', 'type': 'hex'},
                      ],
                      fieldValues: ['', end ?? '', '', ''],
                      onConfirm: (valores) async {
                        await DatabaseHelper().insertMaps(
                          valores[0],
                          valores[1],
                          (coord.latitude).toDouble(),
                          (coord.longitude).toDouble(),
                          valores[2],
                          valores[3],
                          item['id'],
                          900, // Consertar ordem
                        );

                        await _loadItems();

                        Navigator.pop(context);
                        await ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mapa Adicionado')),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadItems() async {
    coords = await DatabaseHelper().getMaps();
    marcadores =
        coords.map((item) {
          return Marker(
            point: LatLng(item['lat'], item['long']),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['desc'] ?? 'Sem título'),
                            Icon(
                              getIconFromString(item['icon']),
                              color: hexToColor(item['colorIcon']),
                            ),
                          ],
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Latitude: ${item['lat']}'),
                              Text('Longitude: ${item['long']}'),
                              Text('Endereço: ${item['endereco']}'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fechar'),
                          ),
                          TextButton(
                            onPressed:
                                () => ajusteFino(item).then((_) {
                                  Navigator.pop(context);
                                }),
                            child: const Text('Ajustar'),
                          ),
                        ],
                      ),
                );
              },
              child: Icon(
                getIconFromString(item['icon']),
                color: hexToColor(item['colorIcon']),
                size: 30,
              ),
            ),
          );
        }).toList();

    if (coords.isNotEmpty) {
      double avgLat = 0;
      double avgLong = 0;

      for (var item in coords) {
        avgLat += item['lat'];
        avgLong += item['long'];
      }

      avgLat /= coords.length;
      avgLong /= coords.length;

      LatLng centro = LatLng(avgLat, avgLong);

      mapController.move(centro, 12);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    final tileUrl =
        isDarkMode
            ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
            : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';

    return Scaffold(
      appBar: AppBar(title: const Text("Mapa")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(-23.5505, -46.6333),
              initialZoom: 13,
              onTap: (tapPosition, latlng) => _handleTap(latlng),
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                subdomains: ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.musync.mapa',
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 1,
                    color:
                        Theme.of(context).extension<CustomColors>()!.concluido,
                  ),
                ],
              ),
              MarkerLayer(markers: marcadores),
            ],
          ),

          Positioned(
            bottom: 10,
            right: 10,
            child: AnimatedSlide(
              offset: selectMark != null ? Offset.zero : const Offset(0, 1),
              duration: const Duration(milliseconds: 300),
              child: AnimatedOpacity(
                opacity: selectMark != null ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedScale(
                  scale: selectMark != null ? 1 : 0.7,
                  duration: const Duration(milliseconds: 200),
                  child: FloatingActionButton(
                    heroTag: "btn1",
                    backgroundColor:
                        Theme.of(context).extension<CustomColors>()!.concluido,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              insetPadding: const EdgeInsets.all(8),
                              contentPadding: const EdgeInsets.all(0),
                              title: const Text('Ponto marcado'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ItemCard(
                                      id: 0,
                                      type: 'repo',
                                      titleNtf: ValueNotifier("Criar"),
                                      subtitleNtf: ValueNotifier(
                                        "Criar uma nova localização onde está marcado",
                                      ),
                                      onPressedCard:
                                          () => criarPonto(selectMark!.point),
                                    ),
                                    ItemCard(
                                      id: 1,
                                      type: 'repo',
                                      titleNtf: ValueNotifier("Atualizar"),
                                      subtitleNtf: ValueNotifier(
                                        "Mudar coordenadas de um ponto já criado",
                                      ),
                                      onPressedCard: () {
                                        listarPontos(
                                          (itemSelecionado) => atualizarPonto(
                                            itemSelecionado,
                                            selectMark!.point,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Fechar'),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 10,
            right: 10,
            child: FloatingActionButton(
              heroTag: "btn2",
              backgroundColor:
                  Theme.of(context).extension<CustomColors>()!.concluido,
              shape: const CircleBorder(),
              child: const Icon(Icons.route_outlined, color: Colors.white),
              onPressed: () {
                listarPontos(
                  (itemSelecionado) => adicionarPonto(itemSelecionado),
                );
              },
            ),
          ),

          AnimatedSlide(
            offset:
                selectedPoints.isNotEmpty ? Offset.zero : const Offset(0, -0.3),
            duration: const Duration(milliseconds: 300),
            child: AnimatedOpacity(
              opacity: selectedPoints.isNotEmpty ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedScale(
                scale: selectedPoints.isNotEmpty ? 1 : 0.7,
                duration: const Duration(milliseconds: 200),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 100,
                                child: SingleChildScrollView(
                                  child: Table(
                                    border: TableBorder.all(
                                      color: const Color.fromARGB(
                                        0,
                                        255,
                                        255,
                                        255,
                                      ),
                                    ),
                                    columnWidths: const {
                                      0: FlexColumnWidth(1),
                                      1: FlexColumnWidth(1),
                                      2: FlexColumnWidth(1),
                                    },
                                    children: [
                                      for (final item in selectedPoints)
                                        buildRouteRow(item),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                'Distancia total : ${totalDistanceKm.toStringAsFixed(2)} Km',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          AnimatedSlide(
            offset: selectMark != null ? Offset.zero : const Offset(0, 0.3),
            duration: const Duration(milliseconds: 300),
            child: AnimatedOpacity(
              opacity: selectMark != null ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedScale(
                scale: selectMark != null ? 1 : 0.7,
                duration: const Duration(milliseconds: 200),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ValueListenableBuilder(
                          valueListenable: endereco,
                          builder: (context, value, _) {
                            return Text(
                              'Lat: ${selectMark?.point.latitude.toStringAsFixed(5) ?? ''}\n'
                              'Lon: ${selectMark?.point.longitude.toStringAsFixed(5) ?? ''}\n'
                              'Endereço: $value',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(LatLng latlng) async {
    if (selectMark == null) {
      selectMark = Marker(
        point: latlng,
        width: 40,
        height: 40,
        child: Icon(
          Icons.add,
          size: 40,
          color: Theme.of(context).extension<CustomColors>()!.concluido,
        ),
      );
      marcadores.add(selectMark!);
      setState(() {});

      endereco.value = await getAddressFromLatLng(
        latlng.latitude,
        latlng.longitude,
      );
    } else {
      marcadores.remove(selectMark);
      selectMark = null;
      endereco.value = "";
      setState(() {});
    }
  }

  void removeDuplicatasConsecutivas(List<Map<String, dynamic>> pontos) {
    int i = 1;

    while (i < pontos.length) {
      final atual = pontos[i];
      final anterior = pontos[i - 1];

      final iguais =
          atual['lat'] == anterior['lat'] && atual['long'] == anterior['long'];

      if (iguais) {
        pontos.removeAt(i);
        i = 1;
      } else {
        i++;
      }
    }
  }

  Future<void> getMultiRoute() async {
    if (selectedPoints.length < 2) return;

    final coordsString = selectedPoints
        .map((p) => '${p['long']},${p['lat']}')
        .join(';');

    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$coordsString?overview=full&geometries=geojson',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final route = data['routes'][0];

      totalDistanceKm = (route['distance'] as num) / 1000.0;

      final coords = route['geometry']['coordinates'] as List;
      routePoints = coords.map((c) => LatLng(c[1], c[0])).toList();

      final legs = route['legs'] as List<dynamic>?;

      if (legs != null && legs.isNotEmpty) {
        if (selectedPoints.isNotEmpty) {
          selectedPoints[0]['distPAnt'] = 0.0;
          selectedPoints[0]['distP0'] = 0.0;
        }

        double acumulado = 0.0;

        for (int i = 0; i < legs.length && i + 1 < selectedPoints.length; i++) {
          final legDistKm = (legs[i]['distance'] as num) / 1000.0;

          selectedPoints[i + 1]['distPAnt'] = legDistKm;
          acumulado += legDistKm;
          selectedPoints[i + 1]['distP0'] = acumulado;
        }
      }

      mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(routePoints),
          padding: const EdgeInsets.all(40),
        ),
      );

      setState(() {});
    } else {
      debugPrint('Erro ao buscar rota OSRM: ${response.statusCode}');
    }
  }

  TableRow buildRouteRow(Map<String, dynamic> item) {
    void onTapRow() async {
      if (await showPopup(
        context,
        'Deseja remover o Ponto: ${item['name']} ?',
        [],
      )) {
        selectedPoints.remove(item);
        removeDuplicatasConsecutivas(selectedPoints);
        if (selectedPoints.length >= 2) {
          await getMultiRoute();
        } else {
          routePoints = [];
          totalDistanceKm = 0;
          setState(() {});
        }
      }
    }

    return TableRow(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTapRow,
          child: Row(
            children: [
              Icon(
                getIconFromString(item['icon']),
                size: 18,
                color: hexToColor(item['colorIcon']),
              ),
              const SizedBox(width: 4),
              Text(item['name']),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTapRow,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text('${item['distP0'].toStringAsFixed(2)} Km'),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTapRow,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text('${item['distPAnt'].toStringAsFixed(2)} Km'),
          ),
        ),
      ],
    );
  }
}

final Map<String, IconData> iconMap = {
  "home": Icons.home,
  "star": Icons.star,
  "flag": Icons.flag,
  "map": Icons.map,
  "favorite": Icons.favorite,
  "music_note": Icons.music_note,
  "location": Icons.location_on,
  "person": Icons.person,
  "work": Icons.work,
  "setting": Icons.settings,
};

IconData getIconFromString(String? iconName) {
  if (iconName == null) return Icons.help_outline;
  final normalized = iconName.trim().toLowerCase();
  return iconMap[normalized] ?? Icons.help_outline;
}

Color hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  return Color(int.parse(hex, radix: 16));
}

Future<LatLng?> getLatLngFromAddress(String address) async {
  final encodedAddress = Uri.encodeComponent(address);
  final url =
      'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'User-Agent': 'SeuAppFlutter/1.0 (contato: seuemail@exemplo.com)',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data.isNotEmpty) {
      final lat = double.parse(data[0]['lat']);
      final lon = double.parse(data[0]['lon']);
      return LatLng(lat, lon);
    }
  }

  return null;
}

Future<String?> getAddressFromLatLng(double lat, double lon) async {
  final url =
      'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'User-Agent': 'SeuAppFlutter/1.0 (contato: seuemail@exemplo.com)',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data['address'] != null) {
      final address = data['address'];

      final rua = address['road'] ?? '';
      final bairro = address['suburb'] ?? address['neighbourhood'] ?? '';
      final cep = address['postcode'] ?? '';

      return [bairro, rua, cep].where((e) => e.isNotEmpty).join(', ');
    }
  }

  return null;
}
