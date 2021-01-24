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
    List<String> subbedTo;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[800],
          title: const Text('Queue For Activities'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser.uid)
              .snapshots(),
          initialData: [],
          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong.");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading..");
            }

            Map<String, dynamic> data = snapshot.data.data();
            List<GroupQueueTile> tiles = [];

            for (String roomname in data['subbedTo']) {
              tiles.add(new GroupQueueTile(roomname));
            }
            if(tiles.length == 0){
              return Card(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Flex(direction: Axis.horizontal, children: <Widget>[
                      Text("Not Currently Subscribed to Any Activities"),
                      Spacer(),
                      
                    ])));
            }
            else{
              return ListView(
              children: tiles,
            );
            }
          },
        ));
  }
}

// This widget is for each tile
// One for each group that you are subbed to and expands with the list of others
// currently queued
class GroupQueueTile extends StatelessWidget {
  GroupQueueTile(this.roomname);

  final String roomname;
  String queueText = "0 queued currently";
  MaterialButton queueBtn;

  @override
  Widget build(BuildContext ctx) {
    DocumentReference currentlyQueued =
        FirebaseFirestore.instance.collection('rooms').doc(roomname);

    return Card(
        child: StreamBuilder(
            stream: currentlyQueued.snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong.");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading..", style: TextStyle(color: Colors.red[800]));
              }

              Map<String, dynamic> data = snapshot.data.data();
              // Change the button based on if we are already in the queue
              if (data['queued']
                  .contains(FirebaseAuth.instance.currentUser.uid)) {
                queueBtn = MaterialButton(
                  onPressed: () {
                    currentlyQueued.update({
                      'queued': FieldValue.arrayRemove(
                          [FirebaseAuth.instance.currentUser.uid])
                    }).then((result) {});
                  },
                  child: Text("Leave Queue",
                      style: TextStyle(color: Colors.white)),
                );
              } else {
                queueBtn = MaterialButton(
                  onPressed: () {
                    currentlyQueued.update({
                      'queued': FieldValue.arrayUnion(
                          [FirebaseAuth.instance.currentUser.uid])
                    }).then((result) {});
                  },
                  child:
                      Text("Join Queue", style: TextStyle(color: Colors.white)),
                );
              }

              int numQueued = data['queued'].length;
              queueText = "$numQueued Currently in queue";

              return ExpansionTile(
                title: Text(roomname, style: TextStyle(color: Colors.black)),
                children: [
                  Container(
                      color: Colors.red[800],
                      child: Row(
                        children: [
                          Padding(
                              child: Text(queueText,
                                  style: TextStyle(color: Colors.white)),
                              padding: EdgeInsets.symmetric(horizontal: 15.0)),
                          queueBtn,
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ))
                ],
              );
            }));
  }
}
