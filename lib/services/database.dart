import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendorapp/classes/Resturant.dart';

class DatabaseServices {
  final CollectionReference restaurantsCollection =
  FirebaseFirestore.instance.collection('restaurants');

  // Function to add a new restaurant document to Firestore
  Future<void> addRestaurant(Restaurant res) async {
    await restaurantsCollection.add({
      'name': res.name,
      'description': res.description,
      'food_category': res.foodCategory,
      'num_tables': res.numTables,
      'num_seats': res.numSeats,
      'time_slots': res.timeslots,
      'location':res.location,
      'image':res.imgUrl
      // 'sales_point': salesPoint,
    });
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
}
//
// (String name, String description, String image,
// String foodCategory, int numTables, int numSeats,
// List<String> timeSlots, Map<String, double> salesPoint)