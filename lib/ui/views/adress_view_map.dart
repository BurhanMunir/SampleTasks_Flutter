import 'dart:async';

import 'package:geocode/geocode.dart';

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sample_tasks/services/location_service.dart';

class AddressPageMap extends StatefulWidget {
  const AddressPageMap({Key? key}) : super(key: key);

  @override
  State<AddressPageMap> createState() => _AddressPageMapState();
}

class _AddressPageMapState extends State<AddressPageMap> {
  final TextEditingController _locationController = TextEditingController();
  String selectedAddress = "";

  void openMapDialog() async {
    final selectedLocation = await showDialog<LocationData>(
      context: context,
      builder: (context) => MapDialog(updateSelectedLocation),
    );

    if (selectedLocation != null) {
      setState(() {
        // Update the text field with the selected address
        selectedAddress = selectedLocation.address;
        _locationController.text = selectedLocation.address;
      });
    }
  }

  // Callback function to update the selected location
  void updateSelectedLocation(LocationData location) {
    setState(() {
      selectedAddress = location.address;
      _locationController.text = location.address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Integration Example'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              maxLines: 2,
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: openMapDialog,
            ),
          ],
        ),
      ),
    );
  }
}

class LocationData {
  final String address;
  LocationData(this.address);
}

class MapDialog extends StatefulWidget {
  final Function(LocationData) onUpdateLocation;

  MapDialog(this.onUpdateLocation);

  @override
  _MapDialogState createState() => _MapDialogState();
}

class _MapDialogState extends State<MapDialog> {
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(33.5656146, 73.1458635);
  CameraPosition? _currentCameraPosition;
  final TextEditingController _searchController = TextEditingController();
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    // final List<Placemark> placemarks = await placemarkFromCoordinates(
    //   latLng.latitude,
    //   latLng.longitude,
    // );
    //  if (placemarks.isNotEmpty) {
    //   final Placemark placemark = placemarks[0];
    //   return placemark.street.toString();
    // }
    final currentAddress = await GeoCode().reverseGeocoding(
        latitude: latLng.latitude, longitude: latLng.longitude);
    if (currentAddress.city != null) {
      var address =
          "${currentAddress.streetAddress},${currentAddress.city},${currentAddress.countryName}";
      return address;
    }
    return "Address not found";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Location on Map'),
      content: SizedBox(
        height: MediaQuery.of(context).size.height / 1.8,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _searchController,
                    textCapitalization: TextCapitalization.words,
                    decoration:
                        const InputDecoration(hintText: 'Search By City'),
                    onChanged: (value) {
                      print(value);
                    },
                  )),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      LocationService().getPlaceId(_searchController.text);
                    },
                  )
                ],
              ),
            ),
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: _center,
                  zoom: 11.0,
                ),
                onCameraMove: (CameraPosition position) {
                  _currentCameraPosition = position;
                },
                // Add map markers and handle user selection
                // ...
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Select'),
          onPressed: () async {
            if (_currentCameraPosition != null) {
              LatLng selectedLocation = _currentCameraPosition!.target;
              String selectedAddress =
                  await _getAddressFromLatLng(selectedLocation);

              LocationData locationData = LocationData(selectedAddress);
              widget.onUpdateLocation(locationData);

              Navigator.of(context).pop();
            }
          },
        ),
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
