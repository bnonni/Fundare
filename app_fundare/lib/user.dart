import 'package:flutter/material.dart';
import 'home.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key, this.title, this.uid}) : super(key: key);
  final String title;
  final String uid;
  @override
  _UserPageState createState() => _UserPageState();
}

// StatelessWidget is @immutable => requires final attributes
class _UserPageState extends State<UserPage> {
  // @override overrides default app build method
  // returns Scaffold obj containing main page with button choices
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Page'),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(75.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('Home'),
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
              ),
            ]),
      ),
    );
  }
}
