import 'dart:io';
import 'package:flutter/material.dart';

class Poll {
  String name;
  String createdBy;
  String first;
  String id;
  Poll(String n, String c, String i) {
    name = n;
    createdBy = c;
    id = i;
  }
  Poll.name(String n) {
    name = n;
  }
}

class PollItem {
  File image;
  TextEditingController controller;
  String name = '';
  double score = 0;
  String id = '';
  String link = '';
  bool hasMedia = false;

  PollItem() {}

  PollItem.nameAndScore(String n, double s) {
    name = n;
    score = s;
  }

  PollItem.TC() {
    controller = new TextEditingController();
  }
}
