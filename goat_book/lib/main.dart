import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


import './views/account.dart';
import './views/groups.dart';
import './views/queue.dart';
import './views/messaging.dart';
import './views/login.dart';
import './views/loading.dart';

import 'core/auth.dart';

// This is the color theme for the whole app
ThemeData theme = ThemeData(primarySwatch: Colors.red);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  void _foregroundMessageHandler(RemoteMessage message) {}

  Future<void> _backgroundMessageHandler(RemoteMessage message) {}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // Initalize Firebase
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error.toString());
            return Container();
          }

          if (snapshot.connectionState == ConnectionState.done) {
            // After firebase init is done.
            () async => {
                  await FirebaseMessaging.instance.requestPermission(
                      alert: true,
                      announcement: false,
                      badge: true,
                      carPlay: false,
                      criticalAlert: false,
                      provisional: false,
                      sound: true)
                };

            FirebaseMessaging.onMessage
                .listen((event) => _foregroundMessageHandler(event));

            FirebaseMessaging.onBackgroundMessage(
                (m) => _backgroundMessageHandler(m));

            return AuthManager();
          }

          return LoadingView(); // fix this
        });
  }
}

class AuthManager extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (FirebaseAuth.instance.currentUser != null) {
            return MaterialApp(
              title: 'Goatbook',
              theme: theme,
              home: NavigationWrapper(),
              debugShowCheckedModeBanner: false,
            );
          } else {
            return MaterialApp(
              title: 'Goatbook',
              theme: theme,
              home: LoginView(),
              debugShowCheckedModeBanner: false,
            );
          }
        });
  }
}

class NavigationWrapper extends StatefulWidget {
  NavigationWrapper();

  @override
  _NavigationWrapperState createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _selectedIndex = 0;
  static const TextStyle optionsStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _bottomNavOptions = <Widget>[
    // Add each page here!!!!
    GroupsView(),
    QueueView(),
    MessagingView(),
    AccountView()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(child: _bottomNavOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Color(0xFFC62828),
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.run_circle),
            backgroundColor: Color(0xFFC62828),
            label: 'Queue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            backgroundColor: Color(0xFFC62828),
            label: 'Messaging',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account')
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.red[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
