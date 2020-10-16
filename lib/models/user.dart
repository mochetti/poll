import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String uid;
  MyUser({this.uid});
}

QuerySnapshot userQuery;
bool userIsAnonymous = false;
