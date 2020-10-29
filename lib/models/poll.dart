import 'dart:io';
import 'package:flutter/material.dart';
import 'package:poll/views/vote.dart';

class Poll {
  String name;
  String nameFormatted;
  String creator;
  String first;
  String id;
  Poll({String name, String creator, String id}) {
    this.name = name;
    this.creator = creator;
    this.id = id;
  }
  Poll.nameAndID(String n, String i) {
    name = n;
    id = i;
  }
}

class PollItem {
  File image;
  TextEditingController controller;
  String name = '';
  double score = 0;
  int id = 0;
  String docId = '';
  String link = '';
  bool hasMedia = false;

  PollItem({String name, double score, String docId, String link, int id}) {
    this.name = name;
    this.score = score;
    this.docId = docId;
    this.link = link;
    this.id = id;
    this.controller = new TextEditingController(text: name);
    if (link != '') this.hasMedia = true;
  }

  PollItem.nameAndScore(String n, double s) {
    name = n;
    score = s;
  }

  PollItem.TC() {
    controller = new TextEditingController();
  }
}

Future<void> pollDialog({String name, String pollId, BuildContext context}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(name),
        content: Container(
          height: 150,
          child: Column(
            children: [
              Row(
                children: [
                  RaisedButton(
                    child: Text('Wpp'),
                    onPressed: null,
                  ),
                ],
              ),
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
        ],
      );
    },
  );
}

Widget pollCard({String name, String creator, String pollId, BuildContext context, bool isOwner = false}) {
  return Container(
    padding: const EdgeInsets.all(10),
    width: 150,
    child: Ink(
      decoration: BoxDecoration(
        color: Colors.yellowAccent,
        // image: DecorationImage(
        //   image: AssetImage("assets/mindful.jpg"),
        //   fit: BoxFit.cover,
        // ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        splashColor: Colors.blue,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 50,
          // width: 100,
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
            child: Column(
              children: [
                Text(
                  name,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  'by: $creator',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Vote(
                  pollId: pollId),
            ),
          ),
        },
        onLongPress: () => {
          isOwner
            ? pollDialog(
                name: name,
                pollId: pollId,
                context: context)
            : null
        },
      ),
    ),
  );
}
