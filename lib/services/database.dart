import 'package:cloud_firestore/cloud_firestore.dart';
class DatabaseServices{
  final CollectionReference resturantCollection = FirebaseFirestore.instance.collection('resturants');
}