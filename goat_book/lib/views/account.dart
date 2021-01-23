import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:goat_book/core/auth.dart';

AuthService _authService;

class AccountView extends StatefulWidget {
  const AccountView();

  @override
  _AccountViewState createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  @override
  void initState() {
    super.initState();
    _authService = new AuthService();
  }

  @override
  Widget build(BuildContext ctx) {
    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
          Text("Account Page"),
          RaisedButton(
              onPressed: () => _authService.googleSignIn(),
              child: Text("Sign in with Google"))
        ]));
  }
}
