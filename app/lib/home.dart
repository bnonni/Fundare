import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.user_id}) : super(key: key);
  final String title;
  final String user_id;
  @override
  _HomePageState createState() => _HomePageState();
}

// StatelessWidget is @immutable => requires final attributes
class _HomePageState extends State<HomePage> {
  FirebaseUser currentUser;

  @override
  initState() {
    this.getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
  }

  // @override overrides default app build method
  // returns Scaffold obj containing main page with button choices
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(75.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 155.0,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              RaisedButton(
                child: Text('Login'),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
              RaisedButton(
                child: Text('Register'),
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
