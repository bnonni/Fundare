import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './user_services/google_map_services.dart';
import './user_services/poly_services.dart';
import './user_services/paint_altitude.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key, this.uid}) : super(key: key);
  final String uid;
  @override
  _UserPageState createState() => _UserPageState();
}

// StatelessWidget is @immutable => requires final attributes
class _UserPageState extends State<UserPage> {
  bool mapToggle = false;
  bool altitudeToggle = false;
  Set<Marker> carMarker = Set<Marker>();
  Set<Polyline> routePolyline = Set<Polyline>(); // new
  var myGeolocator = Geolocator();
  var currentLocation;
  double carLat;
  double carLong;
  double carAlt;
  double arriveDeckAlt;
  double currentAlt;
  GoogleMapController mapController;
  StreamSubscription<double> altitudeStream;
  final Geoflutterfire geo = Geoflutterfire();
  final Firestore _firestore = Firestore.instance;
  FirebaseUser currentUser;

  void initState() {
    this.getCurrentUser();
    super.initState();
    myGeolocator.getCurrentPosition().then((currloc) {
      setState(() {
        currentLocation = currloc;
        mapToggle = true;
        //store initial location onLoad
        GeoFirePoint userLocation = geo.point(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude);
        _firestore
            .collection('user_data')
            .document(currentUser.uid)
            .collection('onLoad_location')
            .document('userLocation')
            .setData({
          "altitude": currentLocation.altitude,
          "latitude": userLocation.latitude,
          "longitude": userLocation.longitude,
        }, merge: true);
      });
    });
  }

  // reusable function to store carLocation
  void storeCarLocation(carLocation) {
    GeoFirePoint carloc = geo.point(
        latitude: carLocation.latitude, longitude: carLocation.longitude);
    print(carloc);
    _firestore
        .collection('user_data')
        .document(currentUser.uid)
        .collection('onMarked_location')
        .document('carLocation')
        .setData({
      "altitude": 267.9001121520996,
      "latitude": 33.753891,
      "longitude": -84.389412,
    }, merge: true);
    // print(carLocation.longitude);
    // print(carLocation.latitude);
    // print(currentLocation.altitude);
  }

  //gets current user from Firebase
  void getCurrentUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
  }

  // create stream
  Stream<double> generateAltitudeStream(double originalAltitude) async* {
    double alti = originalAltitude;
    var tempLoc;
    while (true) {
      // altitudeToggle
      tempLoc = await myGeolocator.getCurrentPosition();
      if ((tempLoc.altitude - alti).abs() > 0.5 &&
          (tempLoc.altitude - 0.0).abs() > 0.001) {
        // print("${tempLoc.altitude} in stream");
        alti = tempLoc.altitude;
        yield alti;
      }
    }
  }
/* 
          bottomNavigationBar:
            BottomNavigationBar(items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Register'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            title: Text('School'),
          ),
        ]));
*/
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Fundare'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: media.width > 375
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: mapToggle
                  ? GoogleMap(
                      onMapCreated: onMapCreated,
                      initialCameraPosition: CameraPosition(
                          target: LatLng(currentLocation.latitude,
                              currentLocation.longitude),
                          zoom: 10.0),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: carMarker,
                      polylines: routePolyline)
                  : Center(
                      child: Text(
                        'Loading.. Please wait..',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
            ),
            Center(
                child: RaisedButton(
              child: Text('Mark my Car!',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              color: Theme.of(context).primaryColor,
              onPressed: onAddMarkerButtonPressed,
            )),
            // SizedBox(height: 5.0),
            Center(
                child: RaisedButton(
              child: Text('Go to Deck!',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              color: Theme.of(context).primaryColor,
              onPressed: onGoToDeckButtonPressed,
            )),
            Center(
                child: RaisedButton(
              child: Text('Guide in Deck!',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              color: Theme.of(context).primaryColor,
              onPressed: onGuideInDeckButtonPressed,
            )),
            Positioned(
                top: 30,
                left: 30,
                width: 100,
                height: 400,
                child: altitudeToggle
                    ? Center(
                        child: CustomPaint(
                            size: Size(100, 400),
                            painter:
                                MyPainter(carAlt, currentAlt, arriveDeckAlt)))
                    : Center()),
            Positioned(
                top: -30,
                left: 30,
                width: 100,
                height: 100,
                child: altitudeToggle
                    ? Center(
                        child: Text('Altitude',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)))
                    : Center()),
            Positioned(
              top: 600,
              left: 90,
              width: 200,
              height: 35,
              child: RaisedButton(
                child: Text(
                  'Reset',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/user');
                  altitudeStream.cancel();
                },
              ),
            ),
            Positioned(
              top: 10,
              left: 270,
              width: 95,
              height: 35,
              child: RaisedButton(
                child: Text(
                  'Logout',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void onAddMarkerButtonPressed() {
    setState(() {
      myGeolocator.getCurrentPosition().then((currloc) {
        setState(() {
          currentLocation = currloc;
          storeCarLocation(currentLocation);
          mapToggle = true;
          carMarker.clear();
          carMarker.add(Marker(
            // This marker id can be anything that uniquely identifies each marker.
            markerId: MarkerId('usercar'),
            position:
                LatLng(currentLocation.latitude, currentLocation.longitude),
            infoWindow: InfoWindow(
                title: '   Your Car ',
                snippet: '  Latitude: ' +
                    currentLocation.latitude.toString().substring(0, 5) +
                    ',\nLongitude: ' +
                    currentLocation.longitude.toString().substring(0, 6) +
                    ',\nAltitude: ' +
                    currentLocation.altitude.toString().substring(0, 6)),
            icon: BitmapDescriptor.defaultMarker,
          ));
        });
      });
    });
  }

  void onGoToDeckButtonPressed() {
    setState(() {
      // get car location from database, has fields latitude, longitude, altitude
      _firestore
          .collection('user_data')
          .document(currentUser.uid)
          .collection('onMarked_location')
          .document('testCarLocation')
          .get()
          .then((result) {
        carLat = result.data['latitude'];
        carLong = result.data['longitude'];
        carAlt = result.data['altitude'];
        routePolyline.clear();
        myGeolocator.getCurrentPosition().then((currloc) {
          // get user's current location below
          currentLocation = currloc;
          GoogleMapsServices()
              .getRouteCoordinates(
                  LatLng(currentLocation.latitude, currentLocation.longitude),
                  LatLng(carLat, carLong))
              .then((routeString) {
            // get polyline points from Google
            createRoute(routeString);
            // update carMarker below
            carMarker.clear();
            carMarker.add(Marker(
              markerId: MarkerId('usercar'),
              position: LatLng(carLat, carLong),
              infoWindow: InfoWindow(
                  title: '   Your Car ',
                  snippet: '  Latitude: ' +
                      carLat.toString().substring(0, 5) +
                      ',\nLongitude: ' +
                      carLong.toString().substring(0, 6) +
                      ',\nAltitude: ' +
                      carAlt.toString().substring(0, 6)),
              icon: BitmapDescriptor.defaultMarker,
            ));
          });
        });
      });
    });
  }

  void onGuideInDeckButtonPressed() {
    double carLat, carLong, carAlt;
    // get car location from database: latitude, longitude, altitude
    _firestore
        .collection('user_data')
        .document(currentUser.uid)
        .collection('onMarked_location')
        .document('testCarLocation')
        .get()
        .then((result) {
      carLat = result.data['latitude'];
      carLong = result.data['longitude'];
      carAlt = result.data['altitude'];
      // get user's current location below
      myGeolocator.getCurrentPosition().then((currloc) {
        currentLocation = currloc;
        print(currloc.altitude);
        setState(() {
          // clear polyline below
          routePolyline.clear();
          // update carMarker below
          carMarker.clear();
          carMarker.add(Marker(
            markerId: MarkerId('usercar'),
            position: LatLng(carLat, carLong),
            infoWindow: InfoWindow(
                title: 'My Car',
                snippet: 'latitude: ' +
                    carLat.toString().substring(0, 5) +
                    ',' +
                    'longitude: ' +
                    carLong.toString().substring(0, 6) +
                    ',' +
                    'altitude: ' +
                    carAlt.toString().substring(0, 6)),
            icon: BitmapDescriptor.defaultMarker,
          ));
          // open altitude window below
          arriveDeckAlt = currentLocation.altitude;
          currentAlt = currentLocation.altitude;
          altitudeToggle = true;
          zoomInMap(currentLocation.latitude, currentLocation.longitude, carLat,
              carLong);
        });
        // listen to stream
        altitudeStream = generateAltitudeStream(currentLocation.altitude)
            .listen((double alti) {
          setState(() {
            currentAlt = alti;
          });
        });
      });
    });
  }

  void zoomInMap(double lati1, double longi1, double lati2, double longi2) {
    // lati1 is user, lati2 is car
    double deltaLati = (lati1 - lati2).abs();
    double deltaLongi = (longi1 - longi2).abs();
    double zoomFactor = 1;
    mapController.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        northeast: LatLng(
            lati1 + zoomFactor * deltaLati, longi1 + zoomFactor * deltaLongi),
        southwest: LatLng(
            lati1 - zoomFactor * deltaLati, longi1 - zoomFactor * deltaLongi),
      ),
      50.0,
    ));
  }

  void createRoute(String encodedPoly) {
    setState(() {
      routePolyline.clear();
      routePolyline.add(Polyline(
          polylineId: PolylineId('myRoute'),
          width: 5,
          points: convertToLatLng(decodePoly(encodedPoly)),
          color: Colors.black));
    });
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }
}
