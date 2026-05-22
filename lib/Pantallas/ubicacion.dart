import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  return await Geolocator.getCurrentPosition();
}

class Ubicacion extends StatefulWidget {
  const Ubicacion({super.key, required this.titulo});

  final String titulo;

  @override
  State<Ubicacion> createState() => _UbicacionState();
}

class _UbicacionState extends State<Ubicacion> {
  double lat = 0;
  double long = 0;
  double zoom = 2;
  List<Marker> _marcadores = [];

  MapController _mapController = MapController();

  void subszoom() {
    setState(() {
      zoom += 1;
      _mapController.move(LatLng(lat, long), zoom);
    });
  }

  void _obtenerubicacion() async {
    Position pos = await _determinePosition();
    setState(() {
      lat = pos.latitude;
      long = pos.longitude;
    });
    if (pos != null) {
      setState(() {
        LatLng positions = LatLng(lat, long);
        _marcadores = [];
        lat = pos.latitude;
        long = pos.longitude;
        _marcadores.add(
          Marker(
            point: positions,
            height: 80,
            width: 40,
            child: Icon(Icons.compass_calibration),
          ),
        );
      });

      LatLng positions = LatLng(lat, long);
      for (double z = zoom; z <= 15; z += 0.5) {
        await Future.delayed(Duration(milliseconds: 200));
        _mapController.move(positions, z);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.titulo),
      ),
      body: Column(
        children: [
          Text("Latitud: $lat"),
          Text("longitud: $long"),
          const SizedBox(height: 15),
          FilledButton(
            onPressed: _obtenerubicacion,
            child: Text("obtener ubicacion"),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(20, 0),
                initialZoom: 2,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.fes.frankie_aplication',
                ),
                MarkerLayer(markers: _marcadores),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
