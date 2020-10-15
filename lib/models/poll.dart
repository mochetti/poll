import 'dart:io';
import 'package:flutter/material.dart';

class Poll {
  String name;
  String creator;
  String first;
  String id;
  Poll(String n, String c, String i) {
    name = n;
    creator = c;
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

  PollItem({String name, double score, String id, String link}) {
    this.name = name;
    this.score = score;
    this.id = id;
    this.link = link;
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
