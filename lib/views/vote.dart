import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/database.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class Vote extends StatefulWidget {
  const Vote({Key key, this.poll}) : super(key: key);

  final String poll;

  @override
  _VoteState createState() => _VoteState();
}

class _VoteState extends State<Vote> {
  QuerySnapshot a, b;
  String aName = 'A', bName = 'B';
  double aScore, bScore;
  String aId, bId, pollId, aLink = '', bLink = '';
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

  void loadData() async {
    print('Loading data ...');
    // Get poll qnt
    var qnt = 0;
    await databaseMethods.getQnt(widget.poll).then((snapshot) {
      qnt = snapshot.docs[0].data()["qnt"];
    });

    // Get poll's id
    await databaseMethods.getPollId(widget.poll).then((snapshot) {
      pollId = snapshot.docs[0].id;
    });

    // Get two random id's
    var rand = Random();
    idA = rand.nextInt(qnt + 1);
    idB = rand.nextInt(qnt + 1);
    while (idB == idA) idB = rand.nextInt(qnt + 1);

    // Get two docs
    await databaseMethods.getDoc(widget.poll, pollId, idA).then((snapshot) {
      a = snapshot;
      aName = a.docs[0].get('name');
      aScore = a.docs[0].get('score');
      aId = a.docs[0].id;
      aLink = a.docs[0].get('link');
    });
    await databaseMethods.getDoc(widget.poll, pollId, idB).then((snapshot) {
      b = snapshot;
      bName = b.docs[0].get('name');
      bScore = b.docs[0].get('score');
      bId = b.docs[0].id;
      bLink = b.docs[0].get('link');

      setState(() {
        isLoading = false;
        print('Loaded!');
      });
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
    await databaseMethods.setScore(widget.poll, pollId, aId, aScore);
    await databaseMethods.setScore(widget.poll, pollId, bId, bScore);

    // Refresh
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
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
                          decoration: BoxDecoration(
                            color: Colors.pink,
                            image: DecorationImage(
                              image: NetworkImage(
                                  'https://firebasestorage.googleapis.com/v0/b/poll-abd8b.appspot.com/o/logo_unesp.png?alt=media&token=0f86bd85-ce9a-4d66-b0c7-736b42887e62'),
                              fit: BoxFit.cover,
                            ),
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
                      // Text(aScore.toString()),
                    ]),
                    Column(
                      children: [
                        CupertinoButton(
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              // image: DecorationImage(
                              //   image: NetworkImage(bLink),
                              //   fit: BoxFit.cover,
                              // ),
                              borderRadius: BorderRadius.circular(12),
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
                        // Text(bScore.toString()),
                      ],
                    ),
                  ],
                ),
                RaisedButton(
                  child: Icon(Icons.refresh),
                  onPressed: () => loadData(),
                )
              ],
            ),
    );
  }
}
