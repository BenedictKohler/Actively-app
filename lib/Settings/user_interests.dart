import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserInterests extends StatefulWidget {
  static const id = 'userinterests';
  @override
  _UserInterestsState createState() => _UserInterestsState();
}

class _UserInterestsState extends State<UserInterests> {
  final allInterests = [
    'Tennis',
    'Golf',
    'Cricket',
    'Cycling',
    'Rowing',
    'Ice Hockey',
    'Fishing',
    'Knitting',
    'Flying',
    'Motorbiking',
    'Waterskiing'
  ];
  final _authority = FirebaseAuth.instance;
  final _database = Firestore.instance;
  var userInterests = [];
  var unchosenInterests = [];
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
        userInterests = userData['interests'];
        for (String interest in allInterests) {
          if (!userInterests.contains(interest)) {
            unchosenInterests.add(interest);
          }
        }
      });
    });
  }

  void saveChanges() {
    Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .updateData({'interests': userInterests});
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  List<Widget> createOptions() {
    List<dynamic> colors = [
      Colors.black12,
      Colors.lightBlueAccent,
      Colors.yellow,
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.pinkAccent,
      Colors.purple
    ];
    List<Widget> options = [];
    for (String option in unchosenInterests) {
      int ind = Random.secure().nextInt(7);
      options.add(new ListTile(
        title: Text(option),
        leading: CircleAvatar(
          backgroundColor: colors[ind],
          child: Text(option.substring(0, 1)),
        ),
        trailing: Icon(
          Icons.check_circle,
          color: Colors.lightGreenAccent,
        ),
        onTap: () {
          setState(() {
            unchosenInterests.remove(option);
            userInterests.add(option);
          });
        },
      ));
    }
    return options;
  }

  List<Widget> createChosen() {
    List<Widget> options = [];
    for (String option in userInterests) {
      options.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
          child: Chip(
            avatar: CircleAvatar(
              child: Text(option.substring(0, 1)),
              backgroundColor: Colors.greenAccent,
            ),
            label: Text(option),
            onDeleted: () {
              setState(() {
                unchosenInterests.add(option);
                userInterests.remove(option);
              });
            },
          ),
        ),
      );
    }
    return options;
  }

  Widget sportOptions() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        height: 300,
        child: ListView(
          children: createOptions(),
        ),
      ),
    );
  }

  Widget chosenSports() {
    return Wrap(
      children: createChosen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Interests')),
      body: Center(
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Choose Interests',
                  style: TextStyle(fontSize: 24, color: Colors.blue),
                ),
                sportOptions(),
                userInterests.length == 0
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'You have no interests currently',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : chosenSports(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    color: Colors.lightBlueAccent,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('Save Changes'),
                    onPressed: () {
                      saveChanges();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
