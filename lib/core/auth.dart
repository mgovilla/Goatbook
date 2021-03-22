import 'dart:async';
import 'package:goat_book/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseAuth {
  Future<User> signIn(String email, String password);

  Future<User> googleSignIn();

  Future<User> signUp(String email, String password);

  User getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();
}

class AuthService implements BaseAuth {
  //final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService() {}

  Future<User> signIn(String email, String password) async {
    UserCredential result = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    return result.user;
  }

  Future<User> googleSignIn() async {
    /*GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      print("Google user is Null!");
      return null;
    }
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken));

    print("Signed in: " + userCredential.user.displayName);

    return userCredential.user;
    */
  }

  Future<User> signUp(String email, String password) async {
    UserCredential result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    User user = result.user;
    return user;
  }

  User getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> signOut() async {
    return FirebaseAuth.instance.signOut();
  }

  Future<void> sendEmailVerification() async {
    User user = FirebaseAuth.instance.currentUser;
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    User user = FirebaseAuth.instance.currentUser;
    return user.emailVerified;
  }
}
