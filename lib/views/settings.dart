import 'package:flutter/material.dart';
import 'package:poll/main.dart';
import '../services/auth.dart';

class Setting extends StatefulWidget {
  const Setting({Key key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          child: Text('Sign Out'),
          onPressed: () => AuthService().signOut(),
        ),
      ),
    );
  }
}
