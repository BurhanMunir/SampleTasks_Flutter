import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class AddressPageAlert extends StatefulWidget {
  const AddressPageAlert({super.key});

  @override
  State<AddressPageAlert> createState() => _AddressPageAlertState();
}

class _AddressPageAlertState extends State<AddressPageAlert> {
  final TextEditingController _locationController =
      TextEditingController(); // Define the TextEditingController
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  // ... Other code for your main widget ...

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
              controller:
                  _locationController, // Use the _locationController for the TextField
              decoration: const InputDecoration(
                labelText: 'Location',
              ),
            ),
            TextField(
              controller: _streetController,
              decoration: const InputDecoration(
                labelText: 'Street',
              ),
            ),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
              ),
            ),
            TextField(
              controller: _zipCodeController,
              decoration: const InputDecoration(
                labelText: 'Zip Code',
              ),
            ),
            TextField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Country',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => MapAutoCompleteDialog(
                    controller: _locationController,
                    streetController: _streetController,
                    cityController: _cityController,
                    zipCodeController: _zipCodeController,
                    countryController: _countryController,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MapAutoCompleteDialog extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController streetController;
  final TextEditingController cityController;
  final TextEditingController zipCodeController;
  final TextEditingController countryController;

  MapAutoCompleteDialog({
    required this.controller,
    required this.streetController,
    required this.cityController,
    required this.zipCodeController,
    required this.countryController,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Location'),
      content: SizedBox(
        height: 500,
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            placesAutoCompleteTextField(context),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  placesAutoCompleteTextField(BuildContext context) {
    return GooglePlaceAutoCompleteTextField(
      textEditingController: controller,
      googleAPIKey: "AIzaSyBCaVSu8OIPyyC28ETDN9pvG9URoq_QROk",
      inputDecoration: const InputDecoration(
        hintText: "Search your location",
      ),
      debounceTime: 400,
      getPlaceDetailWithLatLng: (Prediction prediction) async {
        print("placeDetails: ${prediction.lat.toString()}");
        print(prediction.lng);

        try {
          final List<Placemark> placemarks = await placemarkFromCoordinates(
            double.parse(prediction.lat!),
            double.parse(prediction.lng!),

            localeIdentifier:
                "en_US", // You can specify the locale for address format
          );
          if (placemarks.isNotEmpty) {
            final Placemark placemark = placemarks.first;
            streetController.text = placemark.street ?? "";
            cityController.text = placemark.locality ?? "";
            zipCodeController.text = placemark.postalCode ?? "";
            countryController.text = placemark.country ?? "";
          }
        } catch (ex) {
          print(ex);
        }
      },
      itemClick: (Prediction prediction) async {
        controller.text = prediction.description ?? "";
        controller.selection = TextSelection.fromPosition(
            TextPosition(offset: prediction.description?.length ?? 0));
        Navigator.of(context).pop(); //
      },
      seperatedBuilder: Divider(),
      // OPTIONAL: If you want to customize list view item builder
      itemBuilder: (context, index, Prediction prediction) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const Icon(Icons.location_on),
              const SizedBox(
                width: 7,
              ),
              Expanded(child: Text("${prediction.description ?? ""}"))
            ],
          ),
        );
      },
      isCrossBtnShown: true,
    );
  }
}
