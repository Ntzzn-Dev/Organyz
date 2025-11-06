import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:organyz/database_helper.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final mapController = MapController();

  /*LatLng? startPoint;
  LatLng? endPoint;
  List<LatLng> routePoints = [];*/

  List<Marker> marcadores = [];

  @override
  void initState() {
    super.initState();

    _loadItems();
  }

  Future<void> _loadItems() async {
    List<Map<String, dynamic>> coords = await DatabaseHelper().getMaps();
    marcadores =
        coords
            .map(
              (item) => Marker(
                point: LatLng(item['lat'], item['long']),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.flag,
                  color: Color.fromARGB(255, 170, 23, 23),
                  size: 40,
                ),
              ),
            )
            .toList();

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
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa com Rotas (OSRM)")),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: const LatLng(-23.5505, -46.6333),
          initialZoom: 13,
          onTap: (tapPosition, latlng) => _handleTap(latlng),
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.seuprojeto.mapa',
          ),

          MarkerLayer(markers: marcadores),

          /*PolylineLayer(
            polylines: [
              Polyline(points: routePoints, color: Colors.blue, strokeWidth: 4),
            ],
          ),*/
        ],
      ),
      /*bottomNavigationBar: Container(
        color: Colors.grey.shade900,
        padding: const EdgeInsets.all(12),
        child: Text(
          "aaa",
          /*startPoint == null
              ? "🟢 Toque no mapa para escolher o ponto inicial"
              : endPoint == null
              ? "🔴 Toque para escolher o destino"
              : "✅ Rota traçada (toque novamente para redefinir)", */
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),*/
    );
  }

  void _handleTap(LatLng latlng) {
    setState(() {
      /*if (startPoint == null) {
        startPoint = latlng;
      } else if (endPoint == null) {
        endPoint = latlng;
        getRoute();
      } else {
        // Reinicia o mapa
        startPoint = latlng;
        endPoint = null;
        routePoints.clear();
      }*/
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
