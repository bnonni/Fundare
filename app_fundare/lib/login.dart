import 'package:app/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginForm extends StatefulWidget {
  LoginForm({Key key}) : super(key: key);
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController nameInputController;
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  FirebaseUser currentUser;

  String registerRoute = '/register';

  @override
  initState() {
    nameInputController = new TextEditingController();
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    super.initState();
  }

  String emailValidator(String value) {
    Pattern pattern = r'^[a-zA-Z0-9\._%+-]+@[A-Za-z0-9.-]+[\.A-Za-z]{2,3}$';
    RegExp email = new RegExp(pattern);
    if (!email.hasMatch(value)) {
      return 'Email format is invalid.\ne.g. username@domain.ext\n';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    Pattern pattern = r'^((?=.*\d)(?=.*[A-Z])(?=.*\W).{8,})$';
    RegExp password = new RegExp(pattern);
    if (!password.hasMatch(value)) {
      return 'Password Invalid.';
    } else {
      return null;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
                child: Form(
              key: _loginFormKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Full Name*', hintText: 'First Last'),
                    controller: nameInputController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'emailaddress@domain.com'),
                    controller: emailInputController,
                    keyboardType: TextInputType.emailAddress,
                    validator: emailValidator,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Password', hintText: '********'),
                    controller: pwdInputController,
                    obscureText: true,
                    validator: pwdValidator,
                  ),
                  RaisedButton(
                    child: Text('Login'),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      if (_loginFormKey.currentState.validate()) {
                        FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: emailInputController.text,
                                password: pwdInputController.text)
                            .then((currentUser) => Firestore.instance
                                .collection('register')
                                .document(nameInputController.text +
                                    '/' +
                                    currentUser.uid)
                                .get()
                                .then((DocumentSnapshot result) =>
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => UserPage(
                                                  title: "Welcome " +
                                                      result["name"],
                                                  uid: currentUser.uid,
                                                ))))
                                .catchError((err) => print(err)))
                            .catchError((err) => print(err));
                      }
                    },
                  ),
                  Text("Don't have an account yet?"),
                  FlatButton(
                    child: Text('Register here!'),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                  )
                ],
              ),
            ))));
  }
}
/*
class CurrentUser {
  String email;
  String name;
  String password;
  String uid;

  UserRecord.fromMap(Map<dynamic, dynamic> data)
      : email = data['email'],
        name = data['name'],
        password = data['password'],
        uid = data['uid'];
}

class UserRecord {
  String documentID;
  List<CurrentUser> itemCounts = new List<CurrentUser>();

  UserRecord.fromSnapshot(DocumentSnapshot snapshot)
      : documentID = snapshot.documentID,
        users = snapshot['users'],
        user_data = snapshot['itemCount'].map<ItemCount>((item) {
          return ItemCount.fromMap(item);
        }).toList();

  static fromMap(snapshot) {}
}
*/
