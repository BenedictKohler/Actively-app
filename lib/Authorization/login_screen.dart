import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sports_meet/Authorization/sign_up.dart';
import 'package:sports_meet/home/home_page.dart';

class LoginScreen extends StatefulWidget {
  static const id = "loginscreen";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Log In',
        ),
      ),
      body: Center(
        child: MyLoginForm(),
      ),
    );
  }
}

class MyLoginForm extends StatefulWidget {
  @override
  MyLoginFormState createState() {
    return MyLoginFormState();
  }
}

class MyLoginFormState extends State<MyLoginForm> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _visible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
          height: 50,
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
          height: 50,
        ),
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    fillColor: Colors.lightBlueAccent,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This field can\'t be empty';
                    } else if (!validEmail(value)) {
                      return 'Please check your address again';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    fillColor: Colors.lightBlueAccent,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Your password must contain some text';
                    } else if (value.length < 6) {
                      return 'Please recheck password';
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
                        ));
                        final user = await _auth.signInWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text);
                        if (user != null) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, HomePage.id, (route) => false);
                        }
                      } catch (e) {
                        print(e);
                      }
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Please recheck credentials or create an account'),
                        backgroundColor: Colors.lightBlueAccent,
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Don't have an account?",
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: FlatButton(
                  child: Text(
                    'Create one',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.lightBlueAccent,
                        fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, SignUp.id);
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
