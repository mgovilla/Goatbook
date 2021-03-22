import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

class MessagingView extends StatefulWidget {
  const MessagingView();

  @override
  _MessagingViewState createState() => _MessagingViewState();
}

class _MessagingViewState extends State<MessagingView> {
  bool isLoading;

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  final int _limitIncrement = 20;
  String selectedRoom;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_scrollListener);

    isLoading = false;
  }

  void _onShopDropItemSelected(String newValueSelected) {
    setState(() {
      selectedRoom = newValueSelected;
      print(selectedRoom);
    });
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Edit text
          Flexible(
            child: Container(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.0, 0, 0, 0),
                child: TextField(
                  onSubmitted: (value) {
                    onSendMessage(textEditingController.text, 0);
                  },
                  style: TextStyle(color: Colors.black, fontSize: 15.0),
                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Type your message...',
                  ),
                  focusNode: focusNode,
                ),
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 40.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.red[800], width: 0.5)),
          color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        title: const Text('The Goat Hub'),
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser.uid)
                        .snapshots(),
                    builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) return Text('Loading...');

                      List<DropdownMenuItem<String>> items = [];
                      Map<String, dynamic> data = snapshot.data.data();
                      for (String room in data['subbedTo']) {
                        items.add(DropdownMenuItem(
                          child: Text(room),
                          value: room,
                        ));
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Select a group: "),
                          DropdownButton(
                            items: items,
                            onChanged: _onShopDropItemSelected,
                            value: selectedRoom,
                          ),
                        ],
                      );
                    }),
                // List of messages
                buildListMessage(),
                // Input content
                buildInput(),
              ],
            ),

            // Loading
            buildLoading()
          ],
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const Loading() : Container(),
    );
  }

  void onSendMessage(String content, int type) {
    if (selectedRoom == null) {
      print("No room selected");
      return;
    }

    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('rooms')
          .doc(selectedRoom)
          .collection('chatlog');

      documentReference.add({
        'idFrom': FirebaseAuth.instance.currentUser.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content
      }).then((value) => null);
    }
    listScrollController.animateTo(0.0,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document.data()['idFrom'] == FirebaseAuth.instance.currentUser.uid) {
      // Right (my message)
      return Row(
        children: <Widget>[
          Container(
            child: Text(
              document.data()['content'],
              style: TextStyle(color: Colors.black),
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(
                bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: Container(
                          width: 35.0,
                          height: 35.0,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35.0),
                Container(
                  child: Text(
                    document.data()['content'],
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.red[800],
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(left: 10.0),
                )
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document.data()['timestamp']))
                          .toString(),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data()['idFrom'] ==
                FirebaseAuth.instance.currentUser.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data()['idFrom'] !=
                FirebaseAuth.instance.currentUser.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildListMessage() {
    return Flexible(
      child: selectedRoom == null
          ? Center(child: Text("Please select a group to start chatting!"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rooms')
                  .doc(selectedRoom)
                  .collection('chatlog')
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.red[800])));
                } else {
                  listMessage.addAll(snapshot.data.docs);
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data.docs[index]),
                    itemCount: snapshot.data.docs.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
}

class Loading extends StatelessWidget {
  const Loading();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red[800]),
        ),
      ),
      color: Colors.white.withOpacity(0.8),
    );
  }
}
