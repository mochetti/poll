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
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.yellowAccent,
            // image: DecorationImage(
            //   image: AssetImage("assets/mindful.jpg"),
            //   fit: BoxFit.cover,
            // ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
            child: Text(
              "Cervejas",
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
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.pinkAccent,
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
      ),
    ],
  ),
);
