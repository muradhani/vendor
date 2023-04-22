import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vendorapp/classes/Resturant.dart';
import 'package:vendorapp/services/database.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchText = '';
  var data = DatabaseServices();
  List<DocumentSnapshot> _searchResults=[] ;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(224, 223, 83, 48),
          title: Text(
            'Search Page',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          )),
      body: Column(
        children: [
          TextField(
            onChanged: (value) async {
              setState(() {
                _searchText = value;
              });
              if (_searchText.isEmpty) {
                setState(() {
                  _searchResults = [];
                });
              } else {
                final results = await data.searchRestaurantsByName(_searchText);
                setState(() {
                  _searchResults = results;
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'Search...',
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (BuildContext context, int index) {
                final docSnapshot = _searchResults[index];
                final restaurant = Restaurant.fromSnapshot(docSnapshot);
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      restaurant.imgUrl,
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    ),
                    title: Text(restaurant.name),
                    subtitle: Text(restaurant.description),

                  ),
                );
              },
            ),
          ),


        ],
      ),
    );
  }
}
