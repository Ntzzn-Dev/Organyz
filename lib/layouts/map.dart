import 'dart:convert';
import 'dart:developer';
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

  Marker? startPoint;
  /*LatLng? endPoint;
  List<LatLng> routePoints = [];*/

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

  Future<void> alterarPonto(LatLng coord) {
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
                    final end = await getAddressFromLatLng(
                      coord.latitude,
                      coord.longitude,
                    );

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
      body: FlutterMap(
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
          MarkerLayer(markers: marcadores),

          /*PolylineLayer(
            polylines: [
              Polyline(points: routePoints, color: Colors.blue, strokeWidth: 4),
            ],
          ),*/
        ],
      ),
      floatingActionButton:
          (startPoint != null)
              ? FloatingActionButton(
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
                                      () => criarPonto(startPoint!.point),
                                ),
                                ItemCard(
                                  id: 1,
                                  type: 'repo',
                                  titleNtf: ValueNotifier("Atualizar"),
                                  subtitleNtf: ValueNotifier(
                                    "Mudar coordenadas de um ponto já criado",
                                  ),
                                  onPressedCard:
                                      () => alterarPonto(startPoint!.point),
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
              )
              : null,
    );
  }

  void _handleTap(LatLng latlng) {
    setState(() {
      if (startPoint == null) {
        startPoint = Marker(
          point: latlng,
          width: 40,
          height: 40,
          child: Icon(
            Icons.add,
            size: 40,
            color: Theme.of(context).extension<CustomColors>()!.concluido,
          ),
        );
        marcadores.add(startPoint!);
      } else {
        marcadores.remove(startPoint);
        startPoint = null;
      }
    });
  }

  /*Future<void> getRoute() async {
    if (startPoint == null || endPoint == null) return;

    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${startPoint!.longitude},${startPoint!.latitude};'
      '${endPoint!.longitude},${endPoint!.latitude}?overview=full&geometries=geojson',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List;

      setState(() {
        routePoints = coords.map((c) => LatLng(c[1], c[0])).toList();

        if (routePoints.isNotEmpty) {
          mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(routePoints),
              padding: const EdgeInsets.all(40),
            ),
          );
        }
      });
    } else {
      debugPrint('Erro ao buscar rota: ${response.statusCode}');
    }
  }*/
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
