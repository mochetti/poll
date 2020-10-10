import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poll/models/poll.dart';
import '../services/database.dart';
import 'dart:math';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class Vote extends StatefulWidget {
  const Vote({Key key, this.pollId}) : super(key: key);

  final String pollId;

  @override
  _VoteState createState() => _VoteState();
}

class _VoteState extends State<Vote> {
  QuerySnapshot a, b;
  String pollName;
  ValueNotifier<List<PollItem>> items = ValueNotifier([]);
  DatabaseMethods databaseMethods = new DatabaseMethods();
  bool isLoading = false;
  bool proxLoading = false;
  bool firstTime = true;
  List<PollItem> topItems = [];

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    getData();
    super.initState();
  }

  Future<void> getData() async {
    print('Getting data...');
    // print('length: ${items.value.length}');

    if (items.value.length <= 1) {
      setState(() {
        isLoading = true;
      });
      Timer(
        const Duration(milliseconds: 500),
        () => {
          if (!proxLoading)
            {
              loadData(),
              proxLoading = true,
            },
          getData(),
        },
      );
    } else {
      proxLoading = false;
      // Remove last items
      if (items.value.length >= 4) {
        items.value.removeAt(1);
        items.value.removeAt(0);
      }

      loadData();

      // Load top items
      var poll = await databaseMethods.getTop(widget.pollId);
      topItems = [];
      for (int index = 0; index < poll.docs.length; index++)
        topItems.add(
          new PollItem.nameAndScore(
            poll.docs[index].get('name'),
            poll.docs[index].get('score'),
          ),
        );

      setState(() {
        isLoading = false;
        print('Got data!');
      });
    }
  }

  Future<void> loadData() async {
    while (items.value.length < 10) {
      // Get poll name
      var poll = await databaseMethods.getPoll(widget.pollId);
      pollName = poll.get("name");

      // Get poll qnt
      poll = await databaseMethods.getQnt(widget.pollId);
      int qnt = poll.docs[0].get("qnt");

      // Get two random id's
      int idA, idB;
      var rand = Random();
      idA = rand.nextInt(qnt);
      idB = rand.nextInt(qnt);
      while (idB == idA) idB = rand.nextInt(qnt);

      // Get two docs
      PollItem itemA = new PollItem();
      a = await databaseMethods.getDoc(widget.pollId, idA);
      itemA.name = a.docs[0].get('name');
      itemA.score = a.docs[0].get('score').toDouble();
      itemA.id = a.docs[0].id;
      itemA.link = a.docs[0].get('link');

      PollItem itemB = new PollItem();
      b = await databaseMethods.getDoc(widget.pollId, idB);
      itemB.name = b.docs[0].get('name');
      itemB.score = b.docs[0].get('score').toDouble();
      itemB.id = b.docs[0].id;
      itemB.link = b.docs[0].get('link');

      items.value.add(itemA);
      items.value.add(itemB);

      items.notifyListeners();
    }
  }

  void compute(bool aWon) async {
    int k = 5;
    var pA = (1.0 /
        (1.0 + pow(10, ((items.value[1].score - items.value[0].score) / 400))));
    var pB = (1.0 /
        (1.0 + pow(10, ((items.value[0].score - items.value[1].score) / 400))));

    if (aWon) {
      items.value[0].score = items.value[0].score + k * (1 - pA);
      items.value[1].score = items.value[1].score + k * (0 - pB);
    } else {
      items.value[0].score = items.value[0].score + k * (0 - pA);
      items.value[1].score = items.value[1].score + k * (1 - pB);
    }

    // Update scores locally
    for (int i = 0; i < items.value.length; i++) {
      if (items.value[i].id == items.value[0].id)
        items.value[i].score = items.value[0].score;
    }
    for (int i = 0; i < items.value.length; i++) {
      if (items.value[i].id == items.value[1].id)
        items.value[i].score = items.value[1].score;
    }

    // Update scores online
    await databaseMethods.setScore(
        widget.pollId, items.value[0].id, items.value[0].score);
    await databaseMethods.setScore(
        widget.pollId, items.value[1].id, items.value[1].score);

    // Refresh
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isLoading
          ? AppBar(title: Text('Poll'), backgroundColor: Colors.transparent)
          : AppBar(title: Text(pollName), backgroundColor: Colors.transparent),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : RefreshIndicator(
              onRefresh: () async => {
                await getData(),
              },
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(children: [
                            CupertinoButton(
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: items.value[0].link != ''
                                    ? BoxDecoration(
                                        image: DecorationImage(
                                          image:
                                              NetworkImage(items.value[0].link),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      )
                                    : BoxDecoration(
                                        color: Colors.yellow,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                                  child: Text(
                                    items.value[0].name,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              onPressed: () => compute(true),
                            ),
                          ]),
                          Column(
                            children: [
                              CupertinoButton(
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: items.value[1].link != ''
                                      ? BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                items.value[1].link),
                                            fit: BoxFit.fitWidth,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        )
                                      : BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                                    child: Text(
                                      items.value[1].name,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                onPressed: () => compute(false),
                              ),
                            ],
                          ),
                        ],
                      ),
                      RaisedButton(
                        child: Icon(Icons.refresh),
                        onPressed: () async => {
                          await getData(),
                        },
                      ),
                      SizedBox(height: 16),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: topItems.length,
                          itemBuilder: (context, index) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  (index + 1).toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  topItems[index].name,
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  topItems[index].score.toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            );
                          }),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
