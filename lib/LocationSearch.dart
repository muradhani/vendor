import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];

  void _getSuggestions(String value) async {
    if (value.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    try {
      List<Location> locations = await locationFromAddress(value);
      List<String> suggestions = [];
      for (Location location in locations) {
        List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
        for (Placemark placemark in placemarks) {
          String suggestion = "${placemark.name}, ${placemark.locality}";
          suggestions.add(suggestion);
        }
      }
      setState(() {
        _suggestions = suggestions;
      });
    } catch (e) {
      print(e);
      setState(() {
        _suggestions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Enter a location',
              ),
              onChanged: _getSuggestions,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (BuildContext context, int index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    title: Text(suggestion),

                    onTap: () {
                      // Do something with the selected suggestion
                      Navigator.pop(context, suggestion);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
