import 'dart:io';
import 'package:flutter/material.dart';
import '../services/database.dart';
import 'package:image_picker/image_picker.dart';
import 'addPoll.dart';

class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController newPollTC;

  File image;
  final picker = ImagePicker();
  String _uploadedFileURL;

  addPoll() async {
    if (newPollTC.text.isNotEmpty) {
      // Get poll's id
      await databaseMethods.getPollId(newPollTC.text).then((snapshot) {
        newPollDialog(false);
      });

      setState(() {
        // isLoading = true;
      });
    } else {
      newPollDialog(true);
    }
  }

  Future<void> newPollDialog(bool error) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: error ? Text('Error') : Text('Create Poll'),
          content: SingleChildScrollView(
            child: ListBody(
              children: error
                  ? <Widget>[
                      Text('Please provide a name!'),
                    ]
                  : <Widget>[
                      Text('Do you want to create the poll ${newPollTC.text}?')
                    ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            error
                ? Container()
                : TextButton(
                    child: Text('Ok'),
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPoll(
                            poll: newPollTC.text,
                          ),
                        ),
                      )
                    },
                  )
          ],
        );
      },
    );
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

  void dismiss(String s) {
    FocusScope.of(context).unfocus();
  }

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
            child: TextField(
              onSubmitted: dismiss,
              controller: newPollTC,
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.poll,
                  color: Colors.white,
                ),
                hintText: 'Enter the new poll name',
                hintStyle: TextStyle(
                  color: Colors.white24,
                ),
              ),
            ),
          ),
          RaisedButton(child: Text('Create'), onPressed: addPoll),
        ],
      )),
    );
  }
}
