import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sports_meet/home/user_profile.dart';

class SignUp extends StatefulWidget {
  static const id = "signup";
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up',
        ),
      ),
      body: Center(child: MySignUpForm()),
    );
  }
}

void uploadData(userId, name, email, password) {
  final databaseRef = Firestore.instance;
  databaseRef.collection('users').document(userId).setData({
    "name": name,
    "status": "",
    "userId": userId,
    "email": email,
    "password": password,
    "imageUrl": "",
    "location": "",
    "coordinates": [0.0, 0.0],
    "interests": [],
  });
}

class MySignUpForm extends StatefulWidget {
  @override
  _MySignUpFormState createState() => _MySignUpFormState();
}

class _MySignUpFormState extends State<MySignUpForm> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _visible = false;

  void animate() {
    setState(() {
      _visible = true;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((value) => {
          animate(),
        });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool validEmail(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    var status = regExp.hasMatch(email);
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: 40,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: Duration(seconds: 3),
              curve: Curves.bounceInOut,
              child: Text(
                'Actively',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.lightBlueAccent,
                    fontFamily: 'helvetica'),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Name:',
                    fillColor: Colors.lightBlueAccent,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a name';
                    } else if (value.length > 24) {
                      return "Wow, that's a long name. Please shorten it";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    fillColor: Colors.lightBlueAccent,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Your email address can't be empty";
                    } else if (!validEmail(value)) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    fillColor: Colors.lightBlueAccent,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a valid password';
                    } else if (value.length < 6) {
                      return 'Your password should contain at least 6 characters';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  color: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 8,
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      try {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Processing Data'),
                          backgroundColor: Colors.lightBlueAccent,
                          behavior: SnackBarBehavior.floating,
                        ));
                        final user = await _auth.createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text);
                        uploadData(user.user.uid, _nameController.text,
                            _emailController.text, _passwordController.text);
                        if (user != null) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, UserProfile.id, (route) => false);
                        }
                      } catch (e) {
                        print(e);
                      }
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'You already have an account. Please proceed to Log In'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.lightBlueAccent,
                      ));
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Already have an account?",
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: FlatButton(
                  child: Text(
                    'Log In',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.lightBlueAccent,
                        fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
