import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class UserLocationPicker extends StatefulWidget {
  // UserLocationPicker(this.locationPickFn);

  // final void Function(Position location) locationPickFn;

  @override
  State<UserLocationPicker> createState() => _UserLocationPickerState();
}

class _UserLocationPickerState extends State<UserLocationPicker> {
  Position? location;
  void _pickLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions are denied"), behavior: SnackBarBehavior.floating),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Location permissions are permanently denied, we cannot request permissions."), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled"), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    location = await Geolocator.getCurrentPosition();
    String locationString = 'long: ${location!.longitude.toString()}, lat: ${location!.latitude.toString()}';
    // if (location != null) {
    //   getAddressFromLatLng(location!.latitude, location!.longitude);
    // }
    print("here in location search");
    print(locationString);
    Navigator.pop(context, location);
    setState(() {});
    // widget.locationPickFn(location!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick Location'),
      ),
      body: Column(
        children: <Widget>[
          if (location != null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'long: ${location!.longitude}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'lat: ${location!.latitude}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: _pickLocation,
            icon: const Icon(Icons.location_on),
            label: const Text(
              'Determine Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
