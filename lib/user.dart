import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './user_services/google_map_services.dart';
import './user_services/poly_services.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key, this.uid}) : super(key: key);
  final String uid;
  @override
  _UserPageState createState() => _UserPageState();
}

// StatelessWidget is @immutable => requires final attributes
class _UserPageState extends State<UserPage> {
  var currentLocation;
  bool mapToggle = false;
  Geoflutterfire geo = Geoflutterfire();
  final Firestore _firestore = Firestore.instance;
  FirebaseUser currentUser;
  DateTime now;
  Set<Marker> carMarker = Set<Marker>();
  Set<Polyline> routePolyline = Set<Polyline>();
  GoogleMapController mapController;

  void initState() {
    this.getCurrentUser();
    super.initState();
    Geolocator().getCurrentPosition().then((currloc) {
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
        // print(userLocation.longitude);
        // print(userLocation.latitude);
        // print(currentLocation.altitude);
      });
    });
  }

  // onMarked_location/userLocation
  void storeCarLocation(carLocation) {
    GeoFirePoint carloc = geo.point(
        latitude: carLocation.latitude, longitude: carLocation.longitude);
    _firestore
        .collection('user_data')
        .document(currentUser.uid)
        .collection('onMarked_location')
        .document('carLocation')
        .setData({
      "altitude": carLocation.altitude,
      "latitude": carloc.latitude,
      "longitude": carloc.longitude,
    }, merge: true);
    // print(carLocation.longitude);
    // print(carLocation.latitude);
    // print(currentLocation.altitude);
  }

  void getCurrentUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Car Location'),
        ),
        body: Column(children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height - 280.0,
              width: double.infinity,
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
                    ))),
          SizedBox(height: 5.0),
          RaisedButton(
            child: Text('Mark my Car!',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            color: Theme.of(context).primaryColor,
            onPressed: onAddMarkerButtonPressed,
          ),
          SizedBox(height: 5.0),
          FlatButton(
            child: Text('Go to Deck!',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            color: Theme.of(context).primaryColor,
            onPressed: onGoToDeckButtonPressed,
          ),
          RaisedButton(
              child: Text('Logout',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              }),
        ]));
  }

  void onAddMarkerButtonPressed() {
    setState(() {
      Geolocator().getCurrentPosition().then((currloc) {
        setState(() {
          currentLocation = currloc;
          now = new DateTime.now();
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
      var carLat, carLong, carAlt;
      _firestore
          .collection('user_data')
          .document(currentUser.uid)
          .collection('onMarked_location')
          .document('carLocation')
          .get()
          .then((result) {
        carLat = result.data['latitude'];
        carLong = result.data['longitude'];
        carAlt = result.data['altitude'];
        routePolyline.clear();
        Geolocator().getCurrentPosition().then((currloc) {
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
                      carLong.toString().substring(0, 5) +
                      ',\nAltitude: ' +
                      carAlt.toString().substring(0, 6)),
              icon: BitmapDescriptor.defaultMarker,
            ));
          });
        });
      });
    });
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
