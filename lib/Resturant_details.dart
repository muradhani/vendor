import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vendorapp/classes/Resturant.dart';
import 'package:vendorapp/services/database.dart';
import 'package:geocoding/geocoding.dart';

import 'classes/Book.dart';


class RestaurantDetailsPage extends StatefulWidget {
  final Restaurant restaurant;
  RestaurantDetailsPage({Key? key, required this.restaurant})
      : super(key: key);

  @override
  _RestaurantDetailsPageState createState() => _RestaurantDetailsPageState();
}
class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  late Restaurant restaurant;

  var category;
  var newCategory;
  @override
  void initState() {
    super.initState();
    restaurant = widget.restaurant;
  }
  Future<String?> getAddressFromLatLng(double latitude, double longitude) async {
    final List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks != null && placemarks.isNotEmpty) {
      final Placemark placemark = placemarks.first;
      return "${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}";
    } else {
      return null;
    }
  }
  void updateCategory(String newCategory) {
    setState(() {
      category = newCategory;
    });
  }
  Future<String> getFoodCategoryName(String categoryId) async {
    DatabaseServices db = new DatabaseServices();

    final categoryDoc = await db.categoryCollection.doc(categoryId).get();
    if (categoryDoc.exists) {
      final categoryName = categoryDoc.get('name');
      return categoryName;
    } else {
      throw Exception('Food category not found');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDF5330),
        title: Text(restaurant.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250.0,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Image.network(
                  restaurant.imgUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(
                    restaurant.description,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Food Category:',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Expanded(
                              child: FutureBuilder<String>(
                                future: getFoodCategoryName(restaurant.foodCategory),
                                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Text('Loading...');
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    category = snapshot.data;
                                    return Text('- ${snapshot.data}',
                                      style: TextStyle(fontSize: 16.0),
                                    );
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Edit Food Category'),
                                      content: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Text('Failed to load food categories');
                                          }
                                          if (!snapshot.hasData) {
                                            return Center(child: CircularProgressIndicator());
                                          }
                                          List<DropdownMenuItem<String>> dropdownItems = [];
                                          for (var category in snapshot.data!.docs) {
                                            dropdownItems.add(
                                              DropdownMenuItem(
                                                child: Text(category['name']),
                                                value: category.id,
                                              ),
                                            );
                                          }
                                          return DropdownButtonFormField(
                                            decoration: InputDecoration(hintText: 'Select new category'),
                                            value: newCategory,
                                            onChanged: (value) {
                                              newCategory = value;
                                              print(value);
                                            },
                                            items: dropdownItems,
                                          );
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Save'),
                                          onPressed: () {
                                            // Get a reference to the restaurant document in Firebase
                                            DocumentReference restaurantRef = FirebaseFirestore.instance.collection('resturant').doc(restaurant.id);

                                            // Update the food category field of the restaurant document with the new category name
                                            restaurantRef.update({'food_category': newCategory}).then((value) {
                                              restaurant.foodCategory = newCategory;
                                              updateCategory(newCategory);

                                              // If the update was successful, close the dialog
                                              Navigator.of(context).pop();
                                            }).catchError((error) {
                                              // If there was an error, display a message to the user
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Text('Failed to update food category: $error'),
                                              ));
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),

                          ],
                        ),


                      ],
                    ),
                  ),

                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Number of Tables:',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Text(
                          restaurant.numTables.toString(),
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,

                          ),
                        ),),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Number of Seats:',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Text(
                          restaurant.numSeats.toString(),
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Time Slots:',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      Wrap(
                        direction: Axis.vertical,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5.0,
                        runSpacing: 5.0,
                        children: restaurant.timeslots.map((timeSlot) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                            child: Text(
                              timeSlot,
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                  SizedBox(height: 16),
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

                  SizedBox(height: 32),
                  Text(
                    'Tables:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            TableLayout(restaurant: restaurant),
          ],
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class TableLayout extends StatelessWidget {
  final Restaurant restaurant;
  const TableLayout({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseServices data = DatabaseServices();

    return FutureBuilder<List<Book>>(
      future: data.getBookedTables(restaurant.id),
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
          final List<Book> bookedTables = snapshot.data ?? [];
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
              final isBooked = bookedTables.any((book) => book.table == index + 1);
              final bookedTable = bookedTables.firstWhere((book) => book.table == index + 1, orElse: () => Book( '',  '', 0));
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
                    SizedBox(height: 10),
                    isBooked
                        ? Column(
                      children: [
                        Text(
                          'Reserved on ${bookedTable.date}\n at ${bookedTable.timeSlot}',
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Table ${bookedTable.table}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    )
                        : SizedBox.shrink(),
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
