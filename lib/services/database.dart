import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendorapp/classes/Resturant.dart';

import '../classes/Category.dart';

class DatabaseServices {
  final CollectionReference restaurantsCollection =
  FirebaseFirestore.instance.collection('resturant');

  final CollectionReference categoryCollection =
  FirebaseFirestore.instance.collection('categories');

  final CollectionReference booksCollection =
  FirebaseFirestore.instance.collection('books');

  // Function to add a new restaurant document to Firestore
  Future<String> addRestaurant(Restaurant res) async {
    final docRef = await restaurantsCollection.add({
      'name': res.name,
      'description': res.description,
      'food_category': res.foodCategory,
      'num_tables': res.numTables,
      'num_seats': res.numSeats,
      'time_slots': res.timeslots,
      'latitude': res.latitude,
      'longitude': res.longitude,
      'image': res.imgUrl,
      'token': res.token,
      'location':res.location
    });

    // Get the ID of the newly added document
    final restaurantId = docRef.id;
    //
    // // Add a new document to the books collection with the restaurant ID
    // await booksCollection.add({
    //   'restaurant_id': restaurantId,
    //   'booked_tables': []
    // });

    return restaurantId;
  }

  // Function to get a list of all restaurants in Firestore
  Future<List<QueryDocumentSnapshot>> getAllRestaurants() async {
    final querySnapshot = await restaurantsCollection.get();
    return querySnapshot.docs;
  }

  // Function to get a single restaurant document from Firestore by ID
  Future<DocumentSnapshot> getRestaurantById(String id) async {
    final restaurantDoc = await restaurantsCollection.doc(id).get();
    return restaurantDoc;
  }

  // Function to update a restaurant document in Firestore by ID
  Future<void> updateRestaurantById(String id, String name, String description,
      String image, String foodCategory, int numTables, int numSeats,
      List<String> timeSlots, Map<String, double> salesPoint) async {
    await restaurantsCollection.doc(id).update({
      'name': name,
      'description': description,
      'image': image,
      'food_category': foodCategory,
      'num_tables': numTables,
      'num_seats': numSeats,
      'time_slots': timeSlots,
      'sales_point': salesPoint,

    });
  }

  // Function to delete a restaurant document from Firestore by ID
  Future<void> deleteRestaurantById(String id) async {
    await restaurantsCollection.doc(id).delete();
  }
  // Function to get a single restaurant document from Firestore by name
  Future<DocumentSnapshot?> getRestaurantByName(String name) async {
    final querySnapshot =
    await restaurantsCollection.where('name', isEqualTo: name).get();
    if (querySnapshot.docs.isEmpty) {
      return null;
    }
    return querySnapshot.docs.first;
  }

  Future<List<DocumentSnapshot>> searchRestaurantsByName(String query) async {
    final querySnapshot = await restaurantsCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();
    return querySnapshot.docs;
  }

  Future<Map<int, String>> getBookedTables(String restaurantId) async {
    Map<int, String> bookedTables = {};

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('books')
        .where('restaurant_id', isEqualTo: restaurantId)
        .get();

    querySnapshot.docs.forEach((doc) {
      dynamic table = doc['table'];
      if (table is List<dynamic>) {
        List<dynamic> bookedTableNumbers = table;
        String date = doc['date'];
        String timeSlot = doc['time_slot'];
        // Check if the date and time slot match the desired values

        bookedTableNumbers.forEach((tableNumber) {
          bookedTables[tableNumber] = timeSlot;
        });

      } else if (table is int) {
        int bookedTableNumber = table;
        String date = doc['date'];
        String timeSlot = doc['time_slot'];
        // Check if the date and time slot match the desired values

        bookedTables[bookedTableNumber] = timeSlot;
      }
    });

    print(bookedTables);
    return bookedTables;
  }




  Future<List<Category>> getAllCategories() async {
    List<Category> categories = [];

    try {
      QuerySnapshot querySnapshot = await categoryCollection.get();
      querySnapshot.docs.forEach((doc) {
        categories.add(Category.fromSnapshot(doc));
      });
    } catch (e) {
      print('Error getting categories: $e');
    }

    return categories;
  }
}
