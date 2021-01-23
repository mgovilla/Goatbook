import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
  Future<void> _subscribeHandler(String id) async {
    FirebaseFunctions.instance
        .useFunctionsEmulator(origin: "http://localhost:5001");
    FirebaseFunctions.instance.httpsCallable("subscribeUser")();
  }

  @override
  Widget build(BuildContext ctx) {
    CollectionReference users = FirebaseFirestore.instance.collection("rooms");

    return StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return new ListView(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            return Card(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Flex(direction: Axis.horizontal, children: <Widget>[
                      Text(document.id),
                      Spacer(),
                      MaterialButton(
                        onPressed: () => _subscribeHandler(document.id),
                        child: Text("Subscribe"),
                        textColor: Theme.of(ctx).primaryColor,
                      )
                    ])));
          }).toList(),
        );
      },
    );
  }
}
