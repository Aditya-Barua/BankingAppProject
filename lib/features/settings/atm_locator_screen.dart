import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AtmLocatorScreen extends StatefulWidget {
  const AtmLocatorScreen({super.key});

  @override
  State<AtmLocatorScreen> createState() => _AtmLocatorScreenState();
}

class _AtmLocatorScreenState extends State<AtmLocatorScreen> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(37.7749, -122.4194); // Mock location

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('atm1'),
      position: LatLng(37.7749, -122.4194),
      infoWindow: InfoWindow(title: 'Main Branch ATM'),
    ),
    const Marker(
      markerId: MarkerId('atm2'),
      position: LatLng(37.7849, -122.4094),
      infoWindow: InfoWindow(title: 'City Center ATM'),
    ),
  };

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ATM & Branch Locator')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 13.0,
        ),
        markers: _markers,
      ),
    );
  }
}
