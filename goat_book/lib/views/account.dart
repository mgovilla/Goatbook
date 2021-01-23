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

    
    
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[800],
          title: const Text('Account Information'),
        ),
        body: Column(
          children: <Widget> [
            Card(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Flex(direction: Axis.horizontal, children: <Widget>[
                      Text("Email: " + _authService.getCurrentUser().email),
                      Spacer(),
                      MaterialButton(
                  
                        child: Text(
                          "Change Username",
                          style: TextStyle(color: Colors.red[800])),
                        
                      )
                    ]))),
          Card(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Flex(direction: Axis.horizontal, children: <Widget>[
                      Text("Username: USERNAME HERE"),
                      Spacer(),
                      MaterialButton(
                      
                        child: Text(
                          "Change Username",
                          style: TextStyle(color: Colors.red[800])),
                      )
                    ]))),
          SignoutButton()
          ]
      ));
  }
}

class SignoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return MaterialButton(
      onPressed: () => _authService.signOut(),
      child: Text("Sign Out"),
      textColor: Colors.white,
      color: Colors.red[800],
    );
  }
}
