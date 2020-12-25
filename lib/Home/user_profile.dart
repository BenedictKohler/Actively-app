import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sports_meet/Material_Components/home_bottom_app_bar.dart';
import 'package:path/path.dart' as Path;
import 'package:sports_meet/Settings/location_settings.dart';
import 'package:sports_meet/Settings/user_interests.dart';
import 'package:sports_meet/home/home_page.dart';

class UserProfile extends StatefulWidget {
  static const id = "userprofile";
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: Center(
        child: EditProfilePage(),
      ),
      bottomNavigationBar: MyBottomAppBar(),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _authority = FirebaseAuth.instance;
  final _database = Firestore.instance;
  DocumentSnapshot userData;
  FirebaseUser currentUser;

  final picker = ImagePicker();
  final _nameController = TextEditingController();
  final _statusController = TextEditingController();
  File _changedImage;

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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Widget chooseImage() {
    if (_changedImage != null) {
      return CircleAvatar(
        backgroundImage: FileImage(_changedImage),
        radius: 150,
      );
    } else if (userData['imageUrl'].isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.black38,
        radius: 150,
        child: Text(
          'Please select an image',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(userData['imageUrl']),
        radius: 150,
      );
    }
  }

  Future chooseFile() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    File _image = File(pickedFile.path);
    await ImageCropper.cropImage(sourcePath: _image.path).then((value) {
      setState(() {
        _changedImage = value;
      });
    });
  }

  Future takePicture() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    File _image = File(pickedFile.path);
    await ImageCropper.cropImage(sourcePath: _image.path).then((value) {
      setState(() {
        _changedImage = value;
      });
    });
  }

  Future<void> saveChanges() async {
    if (_statusController.text.isNotEmpty) {
      _database
          .collection('users')
          .document(currentUser.uid)
          .updateData({'status': _statusController.text});
    }
    if (_nameController.text.isNotEmpty && _changedImage == null) {
      _database
          .collection('users')
          .document(currentUser.uid)
          .updateData({'name': _nameController.text});
    } else if (_nameController.text.isEmpty && _changedImage != null) {
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('profilePics/${Path.basename(_changedImage.path)}}');
      StorageUploadTask uploadTask = storageReference.putFile(_changedImage);
      await uploadTask.onComplete;
      storageReference.getDownloadURL().then((fileURL) {
        _database
            .collection('users')
            .document(currentUser.uid)
            .updateData({'imageUrl': fileURL});
      });
    } else if (_nameController.text.isNotEmpty && _changedImage != null) {
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('profilePics/${Path.basename(_changedImage.path)}}');
      StorageUploadTask uploadTask = storageReference.putFile(_changedImage);
      await uploadTask.onComplete;
      storageReference.getDownloadURL().then((fileURL) {
        _database
            .collection('users')
            .document(currentUser.uid)
            .updateData({'name': _nameController.text, 'imageUrl': fileURL});
      });
    }
    Navigator.pushNamedAndRemoveUntil(context, HomePage.id, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return userData == null
        ? CircularProgressIndicator()
        : ListView(
            children: [
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Name:   ',
                          style: TextStyle(fontSize: 20, color: Colors.blue),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: userData['name'].isEmpty
                                  ? 'Change name'
                                  : userData['name'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Status:   ',
                          style: TextStyle(fontSize: 20, color: Colors.blue),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _statusController,
                            decoration: InputDecoration(
                              hintText: userData['status'].isEmpty
                                  ? 'Enter a status'
                                  : userData['status'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: userData != null || _changedImage != null
                        ? chooseImage()
                        : CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: ListTile(
                            onTap: takePicture,
                            leading: Icon(
                              Icons.photo_camera,
                              color: Colors.black87,
                            ),
                            title: Text('Take Picture'),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            onTap: chooseFile,
                            leading: Icon(
                              Icons.photo_library,
                              color: Colors.black87,
                            ),
                            title: Text('Gallery'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.my_location,
                        color: Colors.black87,
                      ),
                      title: Text('My Location'),
                      subtitle: Text('Set this up for improved filtering'),
                      onTap: () {
                        Navigator.pushNamed(context, LocationSettings.id);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: RaisedButton(
                      elevation: 8,
                      color: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Text('My Interests'),
                      onPressed: () {
                        Navigator.pushNamed(context, UserInterests.id);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: Icon(
                              Icons.save,
                              color: Colors.green,
                            ),
                            title: Text('Save Changes'),
                            onTap: () {
                              saveChanges();
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Saving changes'),
                                backgroundColor: Colors.lightBlueAccent,
                              ));
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            title: Text('Discard changes'),
                            onTap: () {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Discarded changes'),
                                backgroundColor: Colors.lightBlueAccent,
                              ));
                              Navigator.pushNamedAndRemoveUntil(
                                  context, HomePage.id, (route) => false);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ],
          );
  }
}
