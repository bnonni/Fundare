import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import 'register.dart';

final TextStyle textStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
//Main function invocation initiates app
void main() => runApp(FundareApp());

class FundareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fundare: Helping Lost Vehicles Find Lost Drivers.',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => HomePage(title: 'Home'),
        '/login': (BuildContext context) => LoginForm(),
        '/register': (BuildContext context) => RegisterForm(),
      },
    );
  }
}
