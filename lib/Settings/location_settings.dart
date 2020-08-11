import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationSettings extends StatefulWidget {
  static const id = 'locationsettings';
  @override
  _LocationSettingsState createState() => _LocationSettingsState();
}

class _LocationSettingsState extends State<LocationSettings> {
  final _authority = FirebaseAuth.instance;
  final _database = Firestore.instance;
  DocumentSnapshot userData;
  FirebaseUser currentUser;

  String userLocation;
  Geolocator geolocator = Geolocator();
  Position newLocation;

  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  void getUserInfo() async {
    FirebaseUser user = await _authority.currentUser();
    currentUser = user;
    Future<DocumentSnapshot> document =
        _database.collection('users').document(currentUser.uid).get();

    document.then((snapshot) {
      setState(() {
        userData = snapshot;
        userLocation = userData['location'];
      });
    });
  }

  Future<void> setCurrentLocation() async {
    try {
      await geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((value) => newLocation = value);
    } catch (e) {
      print(e);
    }

    if (newLocation != null) {
      List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(
          newLocation.latitude, newLocation.longitude);

      setState(() {
        userLocation = placemark[0].subAdministrativeArea.toString() +
            ", " +
            placemark[0].administrativeArea.toString() +
            ", " +
            placemark[0].country.toString();
      });
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> manualLocationFind(address) async {
    try {
      await geolocator.placemarkFromAddress(address).then((value) {
        setState(() {
          userLocation = value[0].subAdministrativeArea.toString() +
              ", " +
              value[0].administrativeArea.toString() +
              ", " +
              value[0].country.toString();
          newLocation = value[0].position;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  void uploadChangedData() {
    if (newLocation == null) {
      return;
    }
    Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .updateData({
      'location': userLocation,
      'coordinates': [newLocation.latitude, newLocation.longitude]
    });
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Settings'),
      ),
      body: ListView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Current location:',
                    style: TextStyle(fontSize: 22, color: Colors.blue),
                  ),
                ),
                userLocation != null && userLocation.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          userLocation,
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Not yet specified',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    onPressed: setCurrentLocation,
                    color: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 8,
                    child: Text('Use Current Location'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text('or',
                      style: TextStyle(color: Colors.black87, fontSize: 22)),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Enter Location manually',
                      style: TextStyle(color: Colors.blue, fontSize: 22)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Street Name',
                            ),
                            controller: _streetController,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'City',
                            ),
                            controller: _cityController,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Country',
                      ),
                      controller: _countryController,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: RaisedButton(
                    child: Text('Find Location'),
                    color: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 8,
                    onPressed: () {
                      manualLocationFind((_streetController.text +
                          " " +
                          _cityController.text +
                          " " +
                          _countryController.text));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          leading: Icon(
                            Icons.save,
                            color: Colors.green,
                          ),
                          title: Text(
                            'Save',
                            style: TextStyle(color: Colors.black87),
                          ),
                          onTap: () {
                            uploadChangedData();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          leading: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          title: Text(
                            'Discard',
                            style: TextStyle(color: Colors.black87),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
