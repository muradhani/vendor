import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendorapp/Resturant_details.dart';
import 'package:vendorapp/classes/Category.dart';
import 'package:vendorapp/classes/Resturant.dart';
import 'package:vendorapp/services/database.dart';
import 'dart:io';

import 'LocationSearch.dart';
import 'logvendor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}


class MessagingService {
  late FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  Future<void> initialize() async {
    // Initialize the Firebase Messaging instance.
    _firebaseMessaging = FirebaseMessaging.instance;
    // Configure the local notification plugin.
    await initializeNotifications();

    // Listen for FCM messages.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final String title = message.notification?.title ?? 'Title';
      final String body = message.notification?.body ?? 'Body';
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('your channel id', 'your channel name', 'your channel description',
          importance: Importance.high, priority: Priority.high, ticker: 'ticker');
      final NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          0, title, body, platformChannelSpecifics,
          payload: 'item x');
    });

    // Handle the tap event when the app is in the foreground.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle the tap event here.
    });
  }
  Future<void> initializeNotifications() async {

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> onSelectNotification(String? payload) async {
    // Handle the notification tap event here.
  }

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

class AddRestaurantScreen extends StatefulWidget {
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
  String fcmToken = '';
  File? _image;
  String? _userLocation;
  var selectedValue;

  List<Category> foodCategories =[];
  Category selectedCategory = new Category(id:" ",name: " ");
  List<String> selectedSlots = [];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _selectedLocation;

  Future<List<Location>> _getLocationSuggestions(String query) async {
    List<Location> locations = await locationFromAddress(query);
    return locations;
  }
  DatabaseServices db = new DatabaseServices();

  //String _fcmToken;
  @override
  void initState(){
    super.initState();
    _getFcmToken();
    loadCategories();
    registerNotifications();
    MessagingService messagingService = MessagingService();
    messagingService.initialize();

    if (foodCategories.isNotEmpty) {
      selectedCategory = foodCategories.first;
    }
  }

  void registerNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received notification: ${message.notification!.title}');
    });
    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) {
      print('Received notification: ${message.notification!.title}');
      return Future.value();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened: ${message.notification!.title}');
    });
  }
  void loadCategories() async {
    List<Category> categories = await db.getAllCategories();
    setState(() {
      foodCategories = categories;
      print(foodCategories[0].name);
      print(foodCategories[1].name);
    });
  }
  Future<void> _getFcmToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      setState(() {
        fcmToken = token;
        restaurant.token = fcmToken;
        print("the token is " + fcmToken.toString());
      });
    }
  }

  final List<TimeOfDay> _timeslots = [
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 17, minute: 0),
    TimeOfDay(hour: 18, minute: 0),
    TimeOfDay(hour: 19, minute: 0),
    TimeOfDay(hour: 20, minute: 0),
    TimeOfDay(hour: 21, minute: 0),
    TimeOfDay(hour: 22, minute: 0),
    TimeOfDay(hour: 23, minute: 0),
  ];

  final List<bool> _selectedTimeslots = List.filled(9, false);
  int _selectedCount = 0;
  String apiKey = 'AIzaSyC-2_Kfdr855XvkoCfj5qf6cFHGQKFGOFQ';

  void _updateSelectedCount(bool value) {
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

  Future getImage() async {
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
    });
  }

  Future<String?> getAddressFromLatLng(double latitude, double longitude) async {
    final List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks != null && placemarks.isNotEmpty) {
      final Placemark placemark = placemarks.first;
      return "${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}";
    } else {
      return null;
    }}

      @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(224, 223, 83, 48),
          title: const Text(
            'Add Restaurant',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          )),
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
                child: Center(
                  child: _image == null
                      ? Text('Tap to add photo')
                      : Image.file(_image!),
                ),
              ),
              TextFormField(
                controller: _restaurantNameController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a restaurant name';
                  } else {
                    restaurant.name = value;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description';
                  } else {
                    restaurant.description = value;
                  }
                  return null;
                },
              ),
              DropdownButtonFormField(
                value: selectedValue,
                items: foodCategories
                    .map((category) => DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ))
                    .toList(),
                hint: Text("Select a food category"),
                onChanged: ( categoryId) { // explicitly annotate the type as String
                  setState(() {
                    selectedValue = categoryId.toString();
                    restaurant.foodCategory = selectedValue.toString();
                    print("id from object"+restaurant.foodCategory);
                  });
                  print("Selected category ID: $categoryId");
                },
              ),
              TextFormField(
                controller: _numTablesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of Tables',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the number of tables';
                  } else {
                    restaurant.numTables = int.parse(value);
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _numSeatsPerTableController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of Seats per Table',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the number of seats per table';
                  } else if (int.parse(value) > 6) {
                    return 'each Table should have at most 6 seats';
                  } else {
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
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location of the restaurant';
                  }

                  return null;
                },
                onSaved: (value) async {
                  // your logic here
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final suggestion = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserLocationPicker()));
                  if (suggestion != null) {
                    setState(() async {
                      final location = suggestion as Position;
                      restaurant.longitude = location.longitude.toString();
                      restaurant.latitude = location.latitude.toString();

                      final locationString = await getAddressFromLatLng(
                          location.latitude, location.longitude);
                      _locationController.text = locationString ?? '';
                      restaurant.location = locationString!;
                    });
                  } else {
                    print('return nothing');
                  }
                },
                child: Text('Location Search'),
              ),
              const SizedBox(height: 16.0),
              const Text('Select up to 5 timeslots:'),
              GridView.builder(
                shrinkWrap: true,
                itemCount: _timeslots.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return CheckboxListTile(
                    title: Text(_timeslots[index].format(context)),
                    value: _selectedTimeslots[index],
                    onChanged: _isSlotEnabled(index)
                        ? (bool? value) {
                            setState(() {
                              _selectedTimeslots[index] = value!;
                              if (value!) {
                                selectedSlots
                                    .add(_timeslots[index].format(context));
                                _updateSelectedCount(true);
                              } else {
                                selectedSlots
                                    .remove(_timeslots[index].format(context));
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
                    final FirebaseStorage storage = FirebaseStorage.instance;
                    var data = DatabaseServices();
                    restaurant.timeslots = selectedSlots;
                    Reference ref;
                    final _image = this._image;
                    if (_image != null) {
                      ref = storage.ref().child(_image.path.split('/').last);
                      UploadTask uploadTask = ref.putFile(_image!);
                      uploadTask.then((res) {
                        print('File uploaded successfully.');
                      }).catchError((error) {
                        print('Error uploading file: $error');
                      });

                      uploadTask.whenComplete(() async {
                        String downloadUrl = await ref.getDownloadURL();
                        //print("Download URL: $downloadUrl");
                        restaurant.imgUrl = downloadUrl.toString();
                        //print("img url : "+restaurant.imgUrl.toString());
                        await data.addRestaurant(restaurant);
                      }).catchError((error) {
                        print('Error uploading file: $error');
                      });
                    }

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
