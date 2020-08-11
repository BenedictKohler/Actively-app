import 'package:flutter/material.dart';
import 'package:sports_meet/home/home_page.dart';

class MyBottomAppBar extends StatefulWidget {
  @override
  _MyBottomAppBarState createState() => _MyBottomAppBarState();
}

class _MyBottomAppBarState extends State<MyBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            splashColor: Colors.greenAccent,
            icon: Icon(
              Icons.home,
              color: Colors.lightBlueAccent,
              size: 25,
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, HomePage.id, (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
