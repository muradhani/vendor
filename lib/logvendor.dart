
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _RestaurantName;

  get body => null;

  void _submit() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      // TODO: Implement login authentication here
      //Navigator.pushNamed(context,'/addRestaurant');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(224, 223, 83, 48),
        title: Text('VENDOR',
          style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold),
          ),
          ),



      body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                      Image.asset('images/1-removebg-preview.png',
                      height: 350,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: 
                        TextFormField(
                          validator: (input) {
                            if (input!.isEmpty) {
                              return 'Please type the Restaurant Name';
                            }
                            return null;
                          },
                          onSaved: (input) => _RestaurantName = input!,
                          decoration: const InputDecoration(
                            labelText: 'Restaurant Name',),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 5),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(224, 223, 83, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: _submit,
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),


                          const SizedBox(width: 20),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(224, 223, 83, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/addRestaurant');
                            },
                            child: const Text(
                              'Add Restaurant',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}