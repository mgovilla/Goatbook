import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupsView extends StatefulWidget {
  const GroupsView();

  @override
  _GroupsViewState createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  @override
  Widget build(BuildContext ctx) {
    return (GroupsList());
  }
}

class GroupsList extends StatelessWidget {
  // Function to subscribe a user to the room which writes to the users and rooms collections
  Future<void> _subscribeHandler(String id) async {
    await FirebaseFirestore.instance.collection("rooms").doc(id).update({
      'subbed':
          FieldValue.arrayUnion(<String>[FirebaseAuth.instance.currentUser.uid])
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({
      'subbedTo': FieldValue.arrayUnion(<String>[id])
    });
  }

  Future<void> _unsubscribeHandler(String id) async {
    await FirebaseFirestore.instance.collection("rooms").doc(id).update({
      'subbed': FieldValue.arrayRemove(
          <String>[FirebaseAuth.instance.currentUser.uid])
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({
      'subbedTo': FieldValue.arrayRemove(<String>[id])
    });

    await FirebaseFirestore.instance.collection('rooms').doc(id).update({
      'queued': FieldValue.arrayRemove(
          <String>[FirebaseAuth.instance.currentUser.uid])
    });
  }

  @override
  Widget build(BuildContext ctx) {
    CollectionReference users = FirebaseFirestore.instance.collection("rooms");

    return 
    Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[800],
          title: const Text('Join A Group'),
        ),
        body: StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong',
              style: TextStyle(color: Colors.red[800]));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading", style: TextStyle(color: Colors.red[800]));
        }
        MaterialButton subBtn;

        return new ListView(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            if (!document
                .data()['subbed']
                .contains(FirebaseAuth.instance.currentUser.uid)) {
              subBtn = MaterialButton(
                onPressed: () => _subscribeHandler(document.id),
                child:
                    Text("Subscribe", style: TextStyle(color: Colors.red[800])),
                textColor: Theme.of(ctx).primaryColor,
              );
            } else {
              subBtn = MaterialButton(
                onPressed: () => _unsubscribeHandler(document.id),
                child: Text("Unsubscribe",
                    style: TextStyle(color: Colors.red[800])),
                textColor: Theme.of(ctx).primaryColor,
              );
            }

            return Card(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Flex(direction: Axis.horizontal, children: <Widget>[
                      Text(document.id),
                      Spacer(),
                      subBtn
                    ])));
          }).toList(),
        );
      },
    ));
  }
}
