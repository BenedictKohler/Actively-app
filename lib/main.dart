import 'package:flutter/material.dart';
import 'package:sports_meet/Chats/chat_screen.dart';
import 'package:sports_meet/Chats/favorite_screen.dart';
import 'package:sports_meet/Chats/message_screen.dart';
import 'package:sports_meet/People/people_screen.dart';
import 'package:sports_meet/People/view_user.dart';
import 'package:sports_meet/Settings/location_settings.dart';
import 'package:sports_meet/Settings/user_interests.dart';
import 'package:sports_meet/home/home_page.dart';
import 'package:sports_meet/home/user_profile.dart';
import 'Authorization/login_screen.dart';
import 'Authorization/sign_up.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: LoginScreen.id, // Should be login screen
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        SignUp.id: (context) => SignUp(),
        HomePage.id: (context) => HomePage(),
        UserProfile.id: (context) => UserProfile(),
        MessageScreen.id: (context) => MessageScreen(),
        ChatScreen.id: (context) => ChatScreen(),
        ViewUser.id: (context) => ViewUser(),
        LocationSettings.id: (context) => LocationSettings(),
        UserInterests.id: (context) => UserInterests(),
        PeopleScreen.id: (context) => PeopleScreen(),
        FavoriteScreen.id: (context) => FavoriteScreen(),
      },
    );
  }
}
