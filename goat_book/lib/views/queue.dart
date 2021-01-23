import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

/*
  All the database logic here is written directly into the widgets. It might be worth abstracting the database api into a wrapper class, but for the sake of speed it's easier just to write the
  firebase calls once since we probably don't have any need for reusability on this specific code. (Lots of it should really be moved server-side eventually anyway.)

    - Arthur
*/

class QueueView extends StatefulWidget {
  const QueueView();

  @override
  _QueueViewState createState() => _QueueViewState();
}

class _QueueViewState extends State<QueueView> {
  @override
  Widget build(BuildContext ctx) {
    return (ListView(
      children: <Widget>[
        Container(
            height: 500,
            child: Flex(
              children: [
                GetUsers("boardgames"),
                QueueUser("I am here to play games", "boardgames"),
                DequeueUser("boardgames")
              ],
              direction: Axis.vertical,
            ))
      ],
    ));
  }
}

class GetRooms extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {}
}

class GetUsers extends StatelessWidget {
  const GetUsers(this.room);

  final room;

  @override
  Widget build(BuildContext ctx) {
    DocumentReference users =
        FirebaseFirestore.instance.collection("rooms").doc(room);

    return StreamBuilder<DocumentSnapshot>(
        stream: users.snapshots(),
        builder: (BuildContext ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong.");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading..");
          }

          List<Widget> users = [];
          Map<String, dynamic> data = snapshot.data.data();
          data.forEach((k, v) => {
                users.add(new ListTile(
                  title: Text(k),
                  subtitle: Text(v["status"]),
                ))
              });

          return new Expanded(child: ListView(children: users));
        });
  }
}

// TODO: Migrate this to a server side function in order to ensure data correctness.
class QueueUser extends StatelessWidget {
  QueueUser(this.status, this.roomname);

  final String status;
  final String roomname;

  @override
  Widget build(BuildContext ctx) {
    DocumentReference room =
        FirebaseFirestore.instance.collection('rooms').doc(roomname);

    Future<void> queueUser() {
      return room.update({
        FirebaseAuth.instance.currentUser.uid: {'status': status}
      });
    }

    return TextButton(onPressed: queueUser, child: Text("I'm In!"));
  }
}

class DequeueUser extends StatelessWidget {
  DequeueUser(this.roomname);

  final String roomname;

  @override
  Widget build(BuildContext ctx) {
    DocumentReference room =
        FirebaseFirestore.instance.collection('rooms').doc(roomname);
    Future<void> dequeueUser() {
      return room
          .update({FirebaseAuth.instance.currentUser.uid: FieldValue.delete()});
    }

    return TextButton(onPressed: dequeueUser, child: Text("I'm Out!"));
  }
}
