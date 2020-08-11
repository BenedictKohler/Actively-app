import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sports_meet/Chats/message_screen.dart';
import 'package:sports_meet/Material_Components/home_bottom_app_bar.dart';

class ChatScreen extends StatefulWidget {
  static const id = "chatscreen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
  }

  Widget createDate(date) {
    if (date != null) {
      DateTime d = date.toDate();
      Duration duration = d.difference(DateTime.now());
      int dur = duration.inHours;
      if (dur < 1) {
        return Text('Recent');
      } else if (dur < 24) {
        return Text('Today');
      } else if (dur < 48) {
        return Text('Yesterday');
      } else {
        return Text(d.day.toString() +
            "/" +
            d.month.toString() +
            "/" +
            d.year.toString());
      }
    } else {
      return Text('No Date');
    }
  }

  Widget createLeading(doc) {
    if (doc["imageUrl"].isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.blue,
        radius: 30,
        child: Text(doc['title'].substring(0, 1)),
      );
    } else {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(doc['imageUrl']),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      bottomNavigationBar: MyBottomAppBar(),
      body: Center(
        child: userData == null
            ? CircularProgressIndicator()
            : StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection('users')
                    .document(userData['userId'])
                    .collection('messages')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError)
                    return new Text(
                        'Unfortunately their has been an error, please restart app');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return new CircularProgressIndicator();
                    default:
                      return snapshot.data.documents.length == 0
                          ? Center(
                              child: Text('You have no chats currently :('),
                            )
                          : ListView(
                              children: snapshot.data.documents
                                  .map((DocumentSnapshot document) {
                                return ListTile(
                                  leading: createLeading(document),
                                  trailing: createDate(document['date']),
                                  title: new Text(document['title']),
                                  subtitle: new Text(document['subtitle']),
                                  onTap: () {
                                    Firestore.instance
                                        .collection('users')
                                        .document(document['userId'])
                                        .get()
                                        .then(
                                          (value) => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MessageScreen(
                                                      otherData: value),
                                            ),
                                          ),
                                        );
                                  },
                                );
                              }).toList(),
                            );
                  }
                },
              ),
      ),
    );
  }
}
