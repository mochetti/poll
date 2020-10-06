import 'package:flutter/material.dart';
import '../services/database.dart';

class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController newPollTC;

  addPoll() async {
    if (newPollTC.text.isNotEmpty) {
      setState(() {
        // isLoading = true;
      });
      // await databaseMethods.addPoll(newPollTC.text);
    }
  }

  @override
  void initState() {
    super.initState();

    newPollTC = TextEditingController();
  }

  void dispose() {
    newPollTC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            // decoration: kBoxDecorationStyle,
            height: 60.0,
            child: TextField(
              controller: newPollTC,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.white,
                ),
                hintText: 'Enter the new poll name',
                // hintStyle: kHintTextStyle,
              ),
            ),
          ),
          RaisedButton(child: Text('criar poll'), onPressed: () => addPoll()),
        ],
      )),
    );
  }
}
