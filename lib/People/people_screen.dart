import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sports_meet/Material_Components/home_bottom_app_bar.dart';
import 'package:sports_meet/People/view_user.dart';

class PeopleScreen extends StatefulWidget {
  static const id = "peoplescreen";
  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final _authority = FirebaseAuth.instance;
  final _database = Firestore.instance;
  var userInterests;
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

  // Geo hashing to see how far 2 locations are apart
  int compareDist(place1, place2) {
    double divisor = 180 / (22 / 7);

    // Convert to radians
    double lat0 = userData['coordinates'][0] / divisor;
    double long0 = userData['coordinates'][1] / divisor;

    double lat1 = place1['coordinates'][0] / divisor;
    double long1 = place1['coordinates'][1] / divisor;

    double lat2 = place2['coordinates'][0] / divisor;
    double long2 = place2['coordinates'][1] / divisor;

    double diff_lat_1 = lat0 - lat1;
    double diff_long_1 = long0 - long1;

    double diff_lat_2 = lat0 - lat2;
    double diff_long_2 = long0 - long2;

    double a1 = pow(sin(diff_lat_1 / 2), 2) +
        cos(lat0) * cos(lat1) * pow(sin(diff_long_1), 2);
    double a2 = pow(sin(diff_lat_2 / 2), 2) +
        cos(lat0) * cos(lat2) * pow(sin(diff_long_2), 2);

    double c1 = 2 * asin(sqrt(a1));
    double c2 = 2 * asin(sqrt(a2));

    double radius = 6371; // Radius of earth in km

    double dist1 = c1 * radius;
    double dist2 = c2 * radius;

    return dist1.compareTo(dist2);
  }

  List<DocumentSnapshot> removeIrrelevant(docs) {
    List<DocumentSnapshot> result = [];
    for (DocumentSnapshot doc in docs) {
      for (String interest in userData['interests']) {
        if (doc['interests'].contains(interest)) {
          result.add(doc);
          break;
        }
      }
    }
    return result;
  }

  List<Widget> createChildren(List<DocumentSnapshot> data) {
    data.removeWhere((element) => element['userId'] == userData['userId']);
    data = removeIrrelevant(data); // Removes users that don't any interests
    List<Widget> entries = [];
    data = data == null ? [] : data;
    if (data.length == 0) {
      entries.add(SizedBox(
        height: 200,
      ));
      entries.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
            'Sadly there are no users that have the same interests as you at this time :('),
      ));
      return entries;
    }
    if (userData['location'].isNotEmpty) {
      data.sort((a, b) => compareDist(a, b));
    }
    for (DocumentSnapshot snap in data) {
      entries.add(new ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewUser(
                        otherData: snap,
                        userData: userData,
                      )));
        },
        title: Text(
          snap['name'],
          style: TextStyle(fontSize: 18),
        ),
        subtitle:
            snap['status'].isEmpty ? Text('No status') : Text(snap['status']),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: snap["imageUrl"].isEmpty
              ? AssetImage('assets/soccer-ball.gif')
              : NetworkImage(snap["imageUrl"]),
        ),
        trailing: Icon(
          Icons.photo,
          color: Colors.black87,
        ),
      ));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('People'),
      ),
      bottomNavigationBar: MyBottomAppBar(),
      body: Center(
        child: userData == null
            ? CircularProgressIndicator()
            : StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('users').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError)
                    return new Text(
                        'Unfortunately their has been an error, please restart app');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return new CircularProgressIndicator();
                    default:
                      return new ListView(
                          children: createChildren(snapshot.data.documents));
                  }
                },
              ),
      ),
    );
  }
}
