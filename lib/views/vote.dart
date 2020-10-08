import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/database.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class Vote extends StatefulWidget {
  const Vote({Key key, this.pollId}) : super(key: key);

  final String pollId;

  @override
  _VoteState createState() => _VoteState();
}

class _VoteState extends State<Vote> {
  QuerySnapshot a, b;
  String aName = 'A', bName = 'B';
  String pollName;
  double aScore, bScore;
  String aId, bId, aLink = '', bLink = '';
  int idA, idB;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  bool isLoading = false;

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    loadData();
    super.initState();
  }

  Future<void> loadData() async {
    print('Loading data ...');

    // Get poll name
    print(widget.pollId);
    var poll = await databaseMethods.getPoll(widget.pollId);
    pollName = poll.get("name");
    // Get poll qnt
    poll = await databaseMethods.getQnt(widget.pollId);
    int qnt = poll.docs[0].get("qnt");

    // Get two random id's
    var rand = Random();
    idA = rand.nextInt(qnt);
    idB = rand.nextInt(qnt);
    while (idB == idA) idB = rand.nextInt(qnt);

    // Get two docs
    a = await databaseMethods.getDoc(widget.pollId, idA);
    aName = a.docs[0].get('name');
    print('aName: $aName');
    aScore = a.docs[0].get('score').toDouble();
    aId = a.docs[0].id;
    aLink = a.docs[0].get('link');
    b = await databaseMethods.getDoc(widget.pollId, idB);
    bName = b.docs[0].get('name');
    print('bName: $bName');
    bScore = b.docs[0].get('score').toDouble();
    bId = b.docs[0].id;
    bLink = b.docs[0].get('link');

    setState(() {
      isLoading = false;
      print('Loaded!');
    });
  }

  void compute(bool aWon) async {
    int k = 5;
    var pA = (1.0 / (1.0 + pow(10, ((bScore - aScore) / 400))));
    var pB = (1.0 / (1.0 + pow(10, ((aScore - bScore) / 400))));

    if (aWon) {
      aScore = aScore + k * (1 - pA);
      bScore = bScore + k * (0 - pB);
    } else {
      aScore = aScore + k * (0 - pA);
      bScore = bScore + k * (1 - pB);
    }
    print(aScore);
    print(bScore);

    // Update scores
    await databaseMethods.setScore(widget.pollId, aId, aScore);
    await databaseMethods.setScore(widget.pollId, bId, bScore);

    // Refresh
    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isLoading
          ? AppBar(title: Text('Poll'))
          : AppBar(title: Text(pollName)),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : RefreshIndicator(
              onRefresh: () async => {
                await loadData(),
              },
              child: ListView(
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
                                height: 100,
                                width: 100,
                                decoration: aLink != ''
                                    ? BoxDecoration(
                                        color: Colors.yellow,
                                        image: DecorationImage(
                                          image: NetworkImage(aLink),
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
                                    aName,
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
                                  height: 100,
                                  width: 100,
                                  decoration: bLink != ''
                                      ? BoxDecoration(
                                          color: Colors.red,
                                          image: DecorationImage(
                                            image: NetworkImage(aLink),
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
                                      bName,
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
                          await loadData(),
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
