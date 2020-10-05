import 'package:flutter/material.dart';
import 'package:poll/main.dart';

var settings = Container(
  child: Center(
        child: RaisedButton(
          child: Text('Sign Out'),
          onPressed: () => signOut(),
        ),
      ),
);