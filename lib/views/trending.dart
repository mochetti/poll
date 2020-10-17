import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'search.dart';
import 'vote.dart';
import '../services/database.dart';
import '../models/poll.dart';
import 'newPoll.dart';
import 'package:cloud_functions/cloud_functions.dart';

class Trending extends StatefulWidget {
  const Trending({Key key}) : super(key: key);

  @override
  _TrendingState createState() => _TrendingState();
}

class _TrendingState extends State<Trending> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot query;
  List<Poll> trendingPolls = [];
  bool isLoading = false;
  FirebaseFunctions functions = FirebaseFunctions.instance;

  Future<void> loadData() async {
    await databaseMethods.getTrending().then((snapshot) {
      query = snapshot;
    });
    trendingPolls = [];
    for (int index = 0; index < query.docs.length; index++) {
      DocumentSnapshot creatorDoc;
      String creator = 'anonymous';
      if (query.docs[index].get('creator') != 'anonymous') {
        creatorDoc =
            await databaseMethods.getUser(query.docs[index].get('creator'));
        creator = creatorDoc.get('name');
      }
      trendingPolls.add(new Poll(
          query.docs[index].get('name'), creator, query.docs[index].id));
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> pollDialog(String name, String pollId) async {
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

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    // FocusScope.of(context).unfocus();
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      primary: true,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(20),
                      itemCount: trendingPolls.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 100,
                          width: 100,
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
                                // height: 100,
                                // width: 100,
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                                  child: Column(
                                    children: [
                                      Text(
                                        trendingPolls[index].name,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        'by: ${trendingPolls[index].creator}',
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
                                    builder: (context) =>
                                        Vote(pollId: trendingPolls[index].id),
                                  ),
                                ),
                              },
                              onLongPress: () => {
                                pollDialog(trendingPolls[index].name,
                                    trendingPolls[index].id)
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Container(height: 100, child: Text('oi')),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Search()));
        },
      ),
    );
  }
}
