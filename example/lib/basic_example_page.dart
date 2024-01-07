import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';

import 'drawer.dart';
import 'example_popup.dart';

class BasicExamplePage extends StatelessWidget {
  static const route = 'basicExamplePage';

  const BasicExamplePage({super.key});

  Future<List<Map<String, dynamic>>?> loadJsonData() async {
    final String data = await rootBundle.loadString('assets/locations.json');
    final List<Map<String, dynamic>>? jsonData =
        json.decode(data).cast<Map<String, dynamic>>();
    return jsonData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Example'),
      ),
      drawer: buildDrawer(context, route),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: loadJsonData(),
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Loading indicator while data is fetched
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data == null) {
            // Handle the case where data is null, e.g., show an error message or fallback data.
            return const Text('No data available');
          } else {
            final List<Map<String, dynamic>> jsonData = snapshot.data!;
            final List<Marker> markers = jsonData.map((locationData) {
              final dynamic latitude = locationData['location']['latitude'];
              final dynamic longitude = locationData['location']['longitude'];

              if (latitude is double && longitude is double) {
                // If latitude and longitude are valid doubles, create a marker
                return Marker(
                  point: LatLng(latitude, longitude),
                  width: 40,
                  height: 40,
                  alignment: Alignment.topCenter,
                  child: const Icon(Icons.location_on, size: 40),
                );
              } else {
                // Handle the case where latitude or longitude is not a double
                // You can choose to ignore these records or handle them differently
                return const Marker(
                  point: LatLng(0,
                      0), // Default to (0, 0) if latitude/longitude is invalid
                  width: 40,
                  height: 40,
                  alignment: Alignment.topCenter,
                  child: Icon(Icons.error, size: 40), // Display an error icon
                );
              }
            }).toList();

            return FlutterMap(
              options: const MapOptions(
                initialZoom: 10.0, // Adjust the zoom level as needed
                initialCenter: LatLng(41.7057,
                    -74.9831), // Set the initial location to Sullivan County, NY
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    markers: markers,
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (BuildContext context, Marker marker) =>
                          ExamplePopup(marker),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
