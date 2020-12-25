import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sports_meet/Chats/chat_screen.dart';
import 'package:sports_meet/Chats/favorite_screen.dart';
import 'package:sports_meet/People/people_screen.dart';
import 'package:sports_meet/home/user_profile.dart';

class HomePage extends StatefulWidget {
  static const id = 'homepage';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  Widget optionButton(route, label, image) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(fontSize: 18, fontFamily: 'helvetica'),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => route));
            },
            child: CircleAvatar(
              child: Text(
                label.substring(0, 1),
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
              radius: 60,
              backgroundColor: Colors.lightBlue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          optionButton(ChatScreen(), "Chats", null),
          optionButton(PeopleScreen(), "People", null),
          optionButton(FavoriteScreen(), "Favorites", null),
          optionButton(UserProfile(), "My Profile", null),
        ],
      ),
    );
  }
}
