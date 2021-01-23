import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView();

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext ctx) {
    return (Center(child: LoginButton()));
  }
}

class LoginButton extends StatefulWidget {
  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  final _formKey = GlobalKey<FormState>();
  final uid = TextEditingController();
  final pass = TextEditingController();

  @override
  Widget build(BuildContext ctx) {
    return Form(
        key: _formKey,
        child: Card(
            child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 100.0),
                child: Flex(direction: Axis.vertical, children: <Widget>[
                  Text("Login"),
                  TextFormField(
                    controller: uid,
                    decoration: const InputDecoration(hintText: 'Email'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please Enter your email.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: pass,
                    decoration: const InputDecoration(hintText: 'Password'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please Enter your password.';
                      }
                      return null;
                    },
                  ),
                  IconButton(
                      icon: Icon(Icons.login_rounded),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: uid.text, password: pass.text);
                        }
                      })
                ]))));
  }
}
