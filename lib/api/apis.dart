import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance; //auth

  static FirebaseFirestore firestore =
      FirebaseFirestore.instance; //access cloud db
}
