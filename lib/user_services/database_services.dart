import '../user.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final Firestore _firestore = Firestore.instance;
FirebaseUser currentUser;

class Loc3D {
  double latitude;
  double longitude;
  double altitude;

  Loc3D(double lati, double longi, double alti) {
    this.latitude = lati;
    this.longitude = longi;
    this.altitude = alti;
  }
}

class DatabaseServices {
  Future<Loc3D> getCarLocation() async {
    // double lati = 33.74;
    // double longi = -84.33;
    // double alti = 5;
    // return Loc3D(lati, longi, alti);
    _firestore
        .collection('user_data')
        .document(currentUser.uid)
        .get()
        .then((DocumentSnapshot result) => print(result))
        .catchError((err) => print(err));
  }
}
