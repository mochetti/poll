import 'dart:io';
import 'package:flutter/material.dart';

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
