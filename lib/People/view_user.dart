import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sports_meet/Chats/message_screen.dart';

class ViewUser extends StatefulWidget {
  static const id = "viewuser";
  ViewUser({this.otherData, this.userData});
  final otherData;
  final userData;
  @override
  _ViewUserState createState() =>
      _ViewUserState(otherData: otherData, userData: userData);
}

class _ViewUserState extends State<ViewUser> {
  _ViewUserState({this.otherData, this.userData});

  final otherData;
  final userData;
  List<dynamic> commonInterests = [];

  void getUserInfo() {
    List<dynamic> otherInterests = otherData["interests"];
    List<dynamic> mInterests = userData["interests"];
    for (String interest in mInterests) {
      if (otherInterests.contains(interest)) {
        commonInterests.add(interest);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Widget profilePic() {
    if (otherData["imageUrl"].isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: CircleAvatar(
          child: Text(
            otherData["name"].substring(0, 1),
            style: TextStyle(fontSize: 60),
          ),
          radius: 150,
          backgroundColor: Colors.greenAccent,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: CircleAvatar(
          radius: 150,
          backgroundImage: NetworkImage(otherData["imageUrl"]),
        ),
      );
    }
  }

  Widget location() {
    if (otherData["location"].isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text('Location: This user has not specified there location'),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text('Location: ${otherData['location']}'),
      );
    }
  }

  List<Widget> createCommon() {
    List<Widget> common = [];
    for (String comInt in commonInterests) {
      common.add(Padding(
        padding: const EdgeInsets.all(2.0),
        child: new Chip(
          label: Text(comInt),
          elevation: 5,
          padding: EdgeInsets.all(2.0),
          avatar: CircleAvatar(
            backgroundColor: Colors.lightBlueAccent,
            child: Text(comInt.substring(0, 1)),
          ),
        ),
      ));
    }
    return common;
  }

  Widget mutualInterests() {
    return Wrap(
      children: createCommon(),
    );
  }

  Widget createScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            otherData["name"],
            style: TextStyle(color: Colors.lightBlueAccent, fontSize: 30),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: otherData['status'].isEmpty
              ? Text(
                  'Status: No status',
                  style: TextStyle(fontSize: 18),
                )
              : Text(
                  'Status: ' + otherData["status"],
                  style: TextStyle(fontSize: 18),
                ),
        ),
        profilePic(),
        location(),
        Padding(
          padding: EdgeInsets.all(6.0),
          child: Text(
            'Common Interests:',
            style: TextStyle(fontSize: 18, color: Colors.blue),
          ),
        ),
        mutualInterests(),
        Row(
          children: <Widget>[
            Expanded(
              child: ListTile(
                leading: Icon(
                  Icons.star,
                  color: Colors.yellow,
                ),
                onTap: () {
                  Firestore.instance
                      .collection('users')
                      .document(userData['userId'])
                      .collection('favorites')
                      .document(otherData['userId'])
                      .setData({
                    'name': otherData['name'],
                    'status': otherData['status'],
                    'userId': otherData['userId'],
                    'imageUrl': otherData['imageUrl']
                  });
                },
                title: Text('Add to favorites',
                    style: TextStyle(color: Colors.black87)),
              ),
            ),
            Expanded(
              child: ListTile(
                onTap: () {
                  Firestore.instance
                      .collection('users')
                      .document(otherData['userId'])
                      .get()
                      .then((value) => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MessageScreen(otherData: value))));
                },
                leading: Icon(
                  Icons.chat,
                  color: Colors.black87,
                ),
                title: Text('Message', style: TextStyle(color: Colors.black87)),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            child: Text('Back'),
            color: Colors.lightBlueAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 8.0,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: userData != null ? createScreen() : CircularProgressIndicator(),
      ),
    );
  }
}
