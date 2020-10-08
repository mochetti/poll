import 'package:flutter/material.dart';
import '../services/database.dart';
import 'newPoll.dart';

class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  void dismiss(String s) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          SizedBox(height: 50),
          Container(
              alignment: Alignment.centerLeft,
              // decoration: kBoxDecorationStyle,
              height: 60.0,
              child: Text('Your Polls')),
          RaisedButton(
            child: Text('Create'),
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewPoll(),
                ),
              ),
            },
          ),
        ],
      )),
    );
  }
}
