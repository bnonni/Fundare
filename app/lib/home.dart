import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.uid}) : super(key: key);
  final String title;
  final double uid;
  @override
  _HomePageState createState() => _HomePageState();
}

// StatelessWidget is @immutable => requires final attributes
class _HomePageState extends State<HomePage> {
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
        padding: const EdgeInsets.all(50.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("MedWallet", style: TextStyle(fontSize: 55.0)),
              SizedBox(
                width: 100.0,
                child: Image.asset(
                  'assets/brain.png',
                  fit: BoxFit.contain,
                ),
              ),
              RaisedButton(
                padding: const EdgeInsets.fromLTRB(50.0, 0, 50.0, 0),
                child: Text('Login'),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
              RaisedButton(
                padding: const EdgeInsets.fromLTRB(40.0, 0, 40.0, 0),
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
