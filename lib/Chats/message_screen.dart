import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  MessageScreen({this.otherData});
  final otherData;
  static const id = 'messagescreen';
  @override
  _MessageScreenState createState() =>
      _MessageScreenState(otherData: otherData);
}

class _MessageScreenState extends State<MessageScreen> {
  _MessageScreenState({this.otherData});

  FocusNode _focusNode = FocusNode();
  bool show = false;

  final otherData;
  String lastMessage;
  Timestamp timestamp;
  final _messageController = TextEditingController();

  final _authority = FirebaseAuth.instance;
  final _database = Firestore.instance;
  DocumentSnapshot userData;
  FirebaseUser currentUser;

  void getUserInfo() async {
    FirebaseUser user = await _authority.currentUser();
    currentUser = user;
    Future<DocumentSnapshot> document =
        _database.collection('users').document(currentUser.uid).get();

    document.then((snapshot) {
      setState(() {
        userData = snapshot;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          show = true;
        });
      } else {
        setState(() {
          show = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget createView(doc) {
    DateTime d = doc['date'].toDate();
    String date = d.hour.toString() + ":" + d.minute.toString();
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment:
            doc['isMe'] ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 230,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              color: doc['isMe'] ? Colors.lightBlueAccent : Colors.greenAccent,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text('${doc['text']}\n${date}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget sendMessageArea() {
    return Padding(
      padding: EdgeInsets.all(6.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter a message',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.blue,
            ),
            onPressed: () {
              lastMessage = _messageController.text;
              if (!_messageController.text.isEmpty) {
                timestamp = Timestamp.now();
                _messageController.clear();
                Firestore.instance
                    .collection('users')
                    .document(userData['userId'])
                    .collection('messages')
                    .document(otherData['userId'])
                    .collection('chats')
                    .document(timestamp.toString())
                    .setData(
                        {'text': lastMessage, 'isMe': true, 'date': timestamp});
                Firestore.instance
                    .collection('users')
                    .document(otherData['userId'])
                    .collection('messages')
                    .document(userData['userId'])
                    .collection('chats')
                    .document(timestamp.toString())
                    .setData({
                  'text': lastMessage,
                  'isMe': false,
                  'date': timestamp
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (lastMessage == null || lastMessage.isEmpty) {
          Navigator.of(context).pop(true);
          return true;
        }
        if (lastMessage.length > 30) {
          lastMessage = lastMessage.substring(0, 30) + "...";
        }
        Firestore.instance
            .collection('users')
            .document(userData['userId'])
            .collection('messages')
            .document(otherData['userId'])
            .setData({
          'title': otherData['name'],
          'imageUrl': otherData['imageUrl'],
          'subtitle': lastMessage,
          'date': timestamp,
          'userId': otherData['userId']
        }, merge: true);
        Firestore.instance
            .collection('users')
            .document(otherData['userId'])
            .collection('messages')
            .document(userData['userId'])
            .setData({
          'title': userData['name'],
          'imageUrl': userData['imageUrl'],
          'subtitle': lastMessage,
          'date': timestamp,
          'userId': userData['userId']
        }, merge: true);
        Navigator.of(context).pop(true);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(otherData['name']),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              userData == null
                  ? CircularProgressIndicator()
                  : StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection('users')
                          .document(userData['userId'])
                          .collection('messages')
                          .document(otherData['userId'])
                          .collection('chats')
                          .orderBy('date')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError)
                          return Text(
                              'Unfortunately their has been an error, please restart app');
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return CircularProgressIndicator();
                          default:
                            return Expanded(
                              child: ListView(
                                children: snapshot.data.documents
                                    .map((DocumentSnapshot document) {
                                  return createView(document);
                                }).toList(),
                              ),
                            );
                        }
                      },
                    ),
              userData != null ? sendMessageArea() : Text(' '),
            ],
          ),
        ),
      ),
    );
  }
}
