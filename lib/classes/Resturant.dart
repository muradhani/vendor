import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  String _name;
  String _description;
  List<String> _foodCategory;
  int _numTables;
  int _numSeats;
  List<String> _timeslots;
  String _id;
  String _longitude;
  String _latitude;
  String _imgUrl;
  String _token;

  // Constructor with id parameter
  Restaurant.withId(
      this._id,
      this._name,
      this._description,
      this._foodCategory,
      this._numTables,
      this._numSeats,
      this._timeslots,
      this._latitude,
      this._longitude,
      this._imgUrl,
      this._token);

  // Constructor without id parameter (sets _id to null)
  Restaurant(
      this._name,
      this._description,
      this._foodCategory,
      this._numTables,
      this._numSeats,
      this._timeslots,
      this._latitude,
      this._longitude,
      this._imgUrl,
      this._token)
      : _id = 'null';

  // Empty constructor
  Restaurant.empty()
      : _name = '',
        _description = '',
        _foodCategory = [],
        _numTables = 0,
        _numSeats = 0,
        _timeslots = [],
        _id = '',
        _latitude = '',
        _longitude = '',
        _imgUrl = '',
        _token = '';

  factory Restaurant.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Restaurant.withId(
      snapshot.id,
      data['name'] as String,
      data['description'] as String,
      List<String>.from(data['food_category']as List) as List<String>,
      data['num_tables'] as int,
      data['num_seats'] as int,
      List<String>.from(data['time_slots'] as List) as List<String>,
      data['latitude'] as String,
      data['longitude'] as String,
      data['image'] as String,
      data['token'],
    );
  }

  String get name => _name;

  set name(String name) => _name = name;

  String get description => _description;

  set description(String description) => _description = description;

  List<String> get foodCategory => _foodCategory;

  set foodCategory(List<String> foodCategory) => _foodCategory = foodCategory;

  int get numTables => _numTables;

  set numTables(int numTables) => _numTables = numTables;

  int get numSeats => _numSeats;

  set numSeats(int numSeats) => _numSeats = numSeats;

  List<String> get timeslots => _timeslots;

  set timeslots(List<String> timeslots) => _timeslots = timeslots;

  String get id => _id;

  set id(String id) => _id = id;

  String get imgUrl => _imgUrl;

  set imgUrl(String value) {
    _imgUrl = value;
  }

  String get token => _token;

  set token(String value) {
    _token = value;
  }

  String get latitude => _latitude;

  set latitude(String value) {
    _latitude = value;
  }

  String get longitude => _longitude;

  set longitude(String value) {
    _longitude = value;
  }
}
