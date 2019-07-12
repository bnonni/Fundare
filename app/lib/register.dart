import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

final TextStyle textStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

class RegisterForm extends StatefulWidget {
  RegisterForm({Key key}) : super(key: key);
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController nameInputController;
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;
  var i;

  @override
  initState() {
    nameInputController = new TextEditingController();
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();
    super.initState();
  }

  String emailValidator(String value) {
    Pattern pattern = r'^[a-zA-Z0-9\._%+-]+@[A-Za-z0-9.-]+[\.A-Za-z]{2,3}$';
    RegExp email = new RegExp(pattern);
    if (!email.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    Pattern pattern = r'^((?=.*\d)(?=.*[A-Z])(?=.*\W).{8,8})$';
    RegExp password = new RegExp(pattern);
    if (!password.hasMatch(value)) {
      return 'Password must be longer than 8 characters.\n Must include at least 1 Uppercase letter, 1 number and 1 special character.';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Register'),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
                child: Form(
              key: _registerFormKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Full Name*',
                        hintText: 'John Doe or Jane Doe'),
                    controller: nameInputController,
                    validator: (value) {
                      if (value.length < 1) {
                        return 'Please enter a valid first name.\nMust include at least 1 character.';
                      }
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Email', hintText: 'john.doe@gmail.com'),
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
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Confirm Password', hintText: '********'),
                    controller: confirmPwdInputController,
                    obscureText: true,
                    validator: pwdValidator,
                  ),
                  RaisedButton(
                    child: Text('Register'),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      if (_registerFormKey.currentState.validate()) {
                        if (pwdInputController.text ==
                            confirmPwdInputController.text) {
                          FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: emailInputController.text,
                                  password: pwdInputController.text)
                              .then((currentUser) => Firestore.instance
                                  .collection('register')
                                  .document(currentUser.uid)
                                  .setData({
                                    'user_id': currentUser.uid,
                                    'name': nameInputController.text,
                                    'email': emailInputController.text,
                                    "account_id": i += 1
                                  })
                                  .then((result) => {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => HomePage(
                                                      title: nameInputController
                                                              .text +
                                                          "'s Tasks",
                                                      uid: currentUser.uid,
                                                    )),
                                            (_) => false),
                                        nameInputController.clear(),
                                        emailInputController.clear(),
                                        pwdInputController.clear(),
                                        confirmPwdInputController.clear()
                                      })
                                  .catchError((err) => print(err)))
                              .catchError((err) => print(err));
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Error'),
                                  content: Text('The passwords do not match'),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              });
                        }
                      }
                    },
                  ),
                  Text('Already have an account?'),
                  FlatButton(
                    child: Text('Login here!'),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  )
                ],
              ),
            ))));
  }
}
