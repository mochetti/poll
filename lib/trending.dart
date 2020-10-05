import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

var trending = Container(
  child: GridView.count(
    primary: false,
    padding: const EdgeInsets.all(20),
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    crossAxisCount: 2,
    children: <Widget>[
      CupertinoButton(
        child: Container(
          // height: 200,
          // width: 200,
          decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage("assets/mindful.jpg"),
            //   fit: BoxFit.cover,
            // ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
            child: Text(
              "Mindfulness",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        onPressed: () {},
      ),
      CupertinoButton(
        child: Container(
          // height: 200,
          // width: 200,
          decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage("assets/mindful.jpg"),
            //   fit: BoxFit.cover,
            // ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
            child: Text(
              "Universidades",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        onPressed: () {},
      ),,
      Container(
        padding: const EdgeInsets.all(8),
        child: const Text('Sound of screams but the'),
        color: Colors.teal[300],
      ),
      Container(
        padding: const EdgeInsets.all(8),
        child: const Text('Who scream'),
        color: Colors.teal[400],
      ),
      Container(
        padding: const EdgeInsets.all(8),
        child: const Text('Revolution is coming...'),
        color: Colors.teal[500],
      ),
      Container(
        padding: const EdgeInsets.all(8),
        child: const Text('Revolution, they...'),
        color: Colors.teal[600],
      ),
    ],
  ),
);
