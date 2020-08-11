import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sports_meet/Material_Components/home_bottom_app_bar.dart';
import 'package:sports_meet/People/view_user.dart';

class FavoriteScreen extends StatefulWidget {
  static const id = 'favoritescreen';
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
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

  Widget createLeadingImage(doc) {
    if (doc['imageUrl'].isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.black12,
        child: Text(doc['name'].substring(0, 1)),
        radius: 30,
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(doc['imageUrl']),
        radius: 30,
      );
    }
  }

  List<Widget> createChildren(docs) {
    List<Widget> favorites = [];
    for (DocumentSnapshot doc in docs) {
      favorites.add(ListTile(
        title: Text(
          doc['name'],
          style: TextStyle(fontSize: 20),
        ),
        trailing: Icon(
          Icons.star,
          color: Colors.yellow,
        ),
        subtitle:
            doc['status'].isEmpty ? Text('No status') : Text(doc['status']),
        leading: createLeadingImage(doc),
        onTap: () {
          Firestore.instance
              .collection('users')
              .document(doc['userId'])
              .get()
              .then((value) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewUser(
                            otherData: value,
                            userData: userData,
                          ))));
        },
      ));
    }
    return favorites;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      bottomNavigationBar: MyBottomAppBar(),
      body: Center(
        child: userData == null
            ? CircularProgressIndicator()
            : StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection('users')
                    .document(userData['userId'])
                    .collection('favorites')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError)
                    return Text(
                        'Unfortunately their has been an error, please restart app');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return new CircularProgressIndicator();
                    default:
                      return snapshot.data.documents.length == 0
                          ? Center(
                              child: Text('You don\'t have any favorites'),
                            )
                          : ListView(
                              children:
                                  createChildren(snapshot.data.documents));
                  }
                },
              ),
      ),
    );
  }
}
