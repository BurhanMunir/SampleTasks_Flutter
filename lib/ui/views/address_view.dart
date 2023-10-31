import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final TextEditingController _locationController = TextEditingController();
  String selectedAddress = "";

  void openMapDialog() async {
    final selectedLocation = await showDialog<LocationData>(
      context: context,
      builder: (context) => MapDialog(),
    );

    if (selectedLocation != null) {
      setState(() {
        // Update the text field with the selected address
        selectedAddress = selectedLocation.address!;
        _locationController.text = selectedLocation.address!;
      });
    }
  }

  void openGoogleMaps(
      {required double latitude, required double longitude}) async {
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      // Handle the case where Google Maps could not be launched
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Integration Example'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
              ),
            ),
            ElevatedButton(
              child: Text('Open Google Maps'),
              onPressed: () {
                final selectedLocation = LocationData(_locationController.text);
                openGoogleMaps(
                  latitude: selectedLocation.latitude, // Provide latitude
                  longitude: selectedLocation.longitude, // Provide longitude
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LocationData {
  final String? address;
  LocationData(this.address);

  double get latitude {
    // Parse latitude from the address or use a geocoding library to get it
    return 37.7749; // Replace with the actual latitude
  }

  double get longitude {
    // Parse longitude from the address or use a geocoding library to get it
    return -122.4194; // Replace with the actual longitude
  }
}

class MapDialog extends StatefulWidget {
  @override
  _MapDialogState createState() => _MapDialogState();
}

class _MapDialogState extends State<MapDialog> {
  Completer<GoogleMapController> _controller = Completer();

  static const LatLng _center = const LatLng(45.521563, -122.677433);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Location on Map'),
      content: Container(
        height: 300, // Customize the map view's size as needed
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          // Add map markers and handle user selection
          // ...
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text('Select'),
          onPressed: () async {
            final GoogleMapController mapController = await _controller.future;
            final LatLngBounds visibleRegion =
                await mapController.getVisibleRegion();
            final LatLng selectedLocation = LatLng(
              (visibleRegion.southwest.latitude +
                      visibleRegion.northeast.latitude) /
                  2,
              (visibleRegion.southwest.longitude +
                      visibleRegion.northeast.longitude) /
                  2,
            );

            // You should obtain the address data through geocoding.
            final List<Placemark> placemarks = await placemarkFromCoordinates(
              selectedLocation.latitude,
              selectedLocation.longitude,
            );

            if (placemarks.isNotEmpty) {
              final Placemark placemark = placemarks[0];
              final selectedAddress =
                  LocationData(placemark.name); // Use placemark data
              Navigator.of(context).pop(selectedAddress);
            } else {
              // Handle the case when no address is found
            }
          },
        ),
      ],
    );
  }
}
