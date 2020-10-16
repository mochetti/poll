import 'package:flutter/material.dart';
import 'package:poll/main.dart';
import '../services/auth.dart';
import '../models/user.dart';

class Setting extends StatefulWidget {
  const Setting({Key key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 40),
          userIsAnonymous
              ? Text(
                  'Hello, stranger',
                  style: TextStyle(color: Colors.white),
                )
              : Text(
                  'Hello, ${userQuery.docs[0].get('name')}',
                  style: TextStyle(color: Colors.white),
                ),
          RaisedButton(
            child: Text('Sign Out'),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
    );
  }
}
