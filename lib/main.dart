
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendorapp/classes/Resturant.dart';
import 'package:vendorapp/services/database.dart';
import 'dart:io';

import 'logvendor.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // var data = DatabaseServices();
  // data.addRestaurant("murad2", "ddddddd", "image", "foodCategory", 20, 20);
  runApp(MyApp());

}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vendor App',
      initialRoute: '/',
      routes: {
      '/': (context) => LoginScreen(),
      '/addRestaurant': (context) => AddRestaurantScreen(),
      },
    );
  }
}


class AddRestaurantScreen extends StatefulWidget
{

  @override
  _AddRestaurantScreenState createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _restaurantNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _foodCategoryController = TextEditingController();
  final _numTablesController = TextEditingController();
  final _numSeatsPerTableController = TextEditingController();
  final _locationController = TextEditingController();
  final picker = ImagePicker();
  Restaurant restaurant = Restaurant.empty();

  File? _image;
  List<String> selectedSlots = [];

  final List<TimeOfDay> _timeslots =
  [
    TimeOfDay(hour: 15, minute:0),
    TimeOfDay(hour: 16, minute:0),
    TimeOfDay(hour: 17, minute:0),
    TimeOfDay(hour: 18, minute:0),
    TimeOfDay(hour: 19, minute:0),
    TimeOfDay(hour: 20, minute:0),
    TimeOfDay(hour: 21, minute:0),
    TimeOfDay(hour: 22, minute:0),
    TimeOfDay(hour: 23, minute:0),
  ];

  final List<bool> _selectedTimeslots = List.filled(9,false);
  int _selectedCount = 0;


  void _updateSelectedCount(bool value)
  {
    setState(() {
      if (value) {
        _selectedCount++;
      } else {
        _selectedCount--;
      }
    });
  }

  bool _isSlotEnabled(int index) {
    return _selectedCount < 5 || _selectedTimeslots[index];
  }


  Future getImage() async
  {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });

  }

  Future takePicture() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(224, 223, 83, 48),
        title: const Text('Add Restaurant',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold),
        )
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Add a photo"),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                GestureDetector(
                                  child: const Text("Take a picture"),
                                  onTap: () {
                                    takePicture();
                                    Navigator.of(context).pop();
                                  },
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                ),
                                GestureDetector(
                                  child: const Text("Select from gallery"),
                                  onTap: () {
                                    getImage();
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: Center
                  (
                  child: _image == null
                      ? Text('Tap to add photo')
                      : Image.file(_image!),
                ),
              ),

              TextFormField
                (
                controller: _restaurantNameController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name',),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a restaurant name';
                  }
                  else{
                    restaurant.name = value;
                  }
                  return null;
                },
              ),

              TextFormField
                (
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description';
                  }
                  else{
                    restaurant.description = value;
                  }
                  return null;
                },
              ),

              TextFormField
                (
                controller: _foodCategoryController,
                decoration: const InputDecoration(
                  labelText: 'Food Category',),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a food category';
                  }
                  else{
                    restaurant.foodCategory = value;
                  }
                  return null;
                },
              ),

              TextFormField
                (
                controller: _numTablesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of Tables',),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the number of tables';
                  }
                  else{
                    restaurant.numTables = int.parse(value);
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _numSeatsPerTableController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of Seats per Table',),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the number of seats per table';
                  }
                  else if(int. parse(value) > 6) {
                    return 'each Table should have at most 6 seats';
                  }
                  else{
                    restaurant.numSeats = int.parse(value);
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Enter your location',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the location of the resturant';
                  }
                  restaurant.location = value;
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Select up to 5 timeslots:'),

              GridView.builder(
                shrinkWrap: true,
                itemCount: _timeslots.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.0,),
                itemBuilder: (BuildContext context, int index) {
                  return CheckboxListTile(
                    title: Text(_timeslots[index].format(context)),
                    value: _selectedTimeslots[index],
                    onChanged: _isSlotEnabled(index)
                        ? (bool? value) {
                      setState(() {
                        _selectedTimeslots[index] = value!;
                        if (value!) {
                          selectedSlots.add(_timeslots[index].format(context));
                          _updateSelectedCount(true);
                        } else {
                          selectedSlots.remove(_timeslots[index].format(context));
                          _updateSelectedCount(false);
                        }
                        print(selectedSlots);

                      });
                    }
                        : null,
                  );
                },
              ),

              const SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(224, 223, 83, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {


                  if (_formKey.currentState!.validate()) {
                    // TODO: Save the restaurant data to the database
                    var data = DatabaseServices();
                    restaurant.timeslots = selectedSlots;
                    data.addRestaurant(restaurant);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Restaurant'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
