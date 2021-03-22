import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

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

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = FirebaseAuth.instance.currentUser;
      assert(user.uid == currentUser.uid);

      print('signInWithGoogle succeeded: $user');

      return '$user';
    }

    return null;
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[800],
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Form(
                key: _formKey,
                child: Card(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 100.0),
                        child:
                            Flex(direction: Axis.vertical, children: <Widget>[
                          Text("Goatbook",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 32.0,
                                  color: Colors.red[800])),
                          Text("Connecting Goats across the globe!",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: Colors.grey)),
                          TextFormField(
                            controller: uid,
                            decoration:
                                const InputDecoration(hintText: 'Email'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter your email.';
                              }
                              return null;
                            },
                          ),
                          // TextFormField(
                          //   controller: uid,
                          //   decoration: const InputDecoration(hintText: 'Username'),
                          //   validator: (value) {
                          //     if (value.isEmpty) {
                          //       return 'Please Enter your username.';
                          //     }
                          //     return null;
                          //   },
                          // ),
                          TextFormField(
                            controller: pass,
                            decoration:
                                const InputDecoration(hintText: 'Password'),
                            enableSuggestions: false,
                            autocorrect: false,
                            obscureText: true,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter your password.';
                              }
                              return null;
                            },
                          ),
                          Column(children: <Widget>[
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 0),
                                      child: MaterialButton(
                                          child: Text("Sign In",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0)),
                                          color: Colors.red[800],
                                          textColor: Colors.white,
                                          onPressed: () {
                                            if (_formKey.currentState
                                                .validate()) {
                                              FirebaseAuth.instance
                                                  .signInWithEmailAndPassword(
                                                      email: uid.text,
                                                      password: pass.text);
                                            }
                                          })),
                                  MaterialButton(
                                      child: Text("Sign Up",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0)),
                                      color: Colors.red[800],
                                      textColor: Colors.white,
                                      onPressed: () {
                                        if (_formKey.currentState.validate()) {
                                          try {
                                            FirebaseAuth.instance
                                                .createUserWithEmailAndPassword(
                                                    email: uid.text,
                                                    password: pass.text);
                                          } on FirebaseAuthException catch (e) {
                                            print(e.code);
                                          }
                                        }
                                      }),
                                ]),
                            MaterialButton(
                                child: Text("Google Login",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0)),
                                color: Colors.white,
                                textColor: Colors.red[800],
                                onPressed: () {
                                  signInWithGoogle().then((String s) {});
                                }),
                          ])
                        ])))),
          ),
        ));
  }
}
