import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "Fundare",
                  style: TextStyle(
                    fontSize: media.width > 375 ? 50.0 : 75.0,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  child: Image.asset(
                    'asset/fundare_logo.png',
                    fit: BoxFit.contain,
                    width: media.width > 375 ? 135.0 : 200.0,
                  ),
                ),
                SizedBox(
                  height: media.width > 375 ? 5.0 : 20.0,
                ),
                Text(
                  'Helping lost cars find their owners.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: media.width > 375 ? 15.0 : 20.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: media.width > 375 ? 75.0 : 150.0,
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                padding: media.width > 375
                    ? EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 60.0, right: 60.0)
                    : EdgeInsets.only(
                        top: 15.0, bottom: 15.0, left: 55.0, right: 55.0),
                child: Text('Login',
                    style: TextStyle(
                        fontSize: media.width > 375 ? 15 : 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  setState(() {
                    Navigator.pushNamed(context, '/login');
                  });
                },
              ),
              RaisedButton(
                padding: media.width > 375
                    ? EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 50.0, right: 50.0)
                    : EdgeInsets.only(
                        top: 15.0, bottom: 15.0, left: 45.0, right: 45.0),
                child: Text('Register',
                    style: TextStyle(
                        fontSize: media.width > 375 ? 15 : 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  setState(() {
                    Navigator.pushNamed(context, '/register');
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
