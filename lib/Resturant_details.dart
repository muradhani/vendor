import 'package:flutter/material.dart';
import 'package:vendorapp/classes/Resturant.dart';
import 'package:vendorapp/services/database.dart';
import 'package:geocoding/geocoding.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final Restaurant restaurant;

  Future<String?> getAddressFromLatLng(double latitude, double longitude) async {
    final List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks != null && placemarks.isNotEmpty) {
      final Placemark placemark = placemarks.first;
      return "${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}";
    } else {
      return null;
    }
  }


  const RestaurantDetailsPage({Key? key, required this.restaurant})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(224, 223, 83, 48),
        title: Text(restaurant.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              restaurant.imgUrl,
              width: double.infinity,
              height: 200.0,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                restaurant.description,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Food Category: ${restaurant.foodCategory}',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Number of Tables: ${restaurant.numTables}',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Number of Seats: ${restaurant.numSeats}',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Time Slots: ${restaurant.timeslots.join(", ")}',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<String?>(
              future: getAddressFromLatLng(
                  double.parse(restaurant.latitude),
                  double.parse(restaurant.longitude)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final address = snapshot.data ?? '';
                  return Text(
                    'Location: $address',
                    style: TextStyle(fontSize: 16.0),
                  );
                }
              },
            ),
          ),

            TableLayout(restaurant: restaurant),
          ],
        ),
      ),
    );
  }
}

class TableLayout extends StatelessWidget {
  final Restaurant restaurant;
  const TableLayout({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseServices data = DatabaseServices();

    return FutureBuilder<List<int>>(
      future: data.getBookedTables(restaurant.id ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          final bookedTables = snapshot.data ?? [];
          return GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: restaurant.numTables,
            itemBuilder: (context, index) {
              final isBooked = index > bookedTables.length - 1 ? false : true;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isBooked ? Colors.redAccent : Colors.grey[300],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Table ${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${restaurant.numSeats} seats',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
