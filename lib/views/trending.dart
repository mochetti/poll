import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'search.dart';
import 'vote.dart';
import '../services/database.dart';
import '../models/poll.dart';
// import 'newPoll.dart';
import '../models/category.dart';
import 'package:cloud_functions/cloud_functions.dart';

class Trending extends StatefulWidget {
  const Trending({Key key}) : super(key: key);

  @override
  _TrendingState createState() => _TrendingState();
}

class _TrendingState extends State<Trending> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot query;
  List<Category> categories = [];
  bool isLoading = false;
  FirebaseFunctions functions = FirebaseFunctions.instance;

  Future<void> loadCategories() async {
    QuerySnapshot query = await databaseMethods.getCategories();
    categories = [];
    for (int index = 0; index < query.docs.length; index++) {
      categories.add(new Category(
          name: query.docs[index].get('name'), id: query.docs[index].id));
      // load polls id
      QuerySnapshot snap =
          await databaseMethods.getCatPolls(query.docs[index].id);
      for (int i = 0; i < snap.docs.length; i++) {
        categories[index].addPoll(snap.docs[i].get('id'));
      }
      loadData();
    }
  }

  Future<void> loadData() async {
    for (int index = 0; index < categories.length; index++) {
      // Load polls
      for (int i = 0; i < categories[index].polls.length; i++) {
        DocumentSnapshot snap =
            await databaseMethods.getPoll(categories[index].polls[i].id);
        categories[index].polls[i].name = snap.get('name');
        DocumentSnapshot creatorDoc;
        String creator = 'anonymous';
        if (snap.get('creator') != 'anonymous') {
          creatorDoc = await databaseMethods.getUser(snap.get('creator'));
          creator = creatorDoc.get('name');
        }
        categories[index].polls[i].creator = creator;
      }
    }

    // await databaseMethods.getTrending().then((snapshot) {
    //   query = snapshot;
    // });
    // trendingPolls = [];
    // for (int index = 0; index < query.docs.length; index++) {
    //   DocumentSnapshot creatorDoc;
    //   String creator = 'anonymous';
    //   if (query.docs[index].get('creator') != 'anonymous') {
    //     creatorDoc =
    //         await databaseMethods.getUser(query.docs[index].get('creator'));
    //     creator = creatorDoc.get('name');
    //   }
    //   trendingPolls.add(new Poll(
    //       name: query.docs[index].get('name'),
    //       creator: creator,
    //       id: query.docs[index].id));
    // }

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
    loadCategories();
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
              onRefresh: loadCategories,
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, ind) {
                  return Column(
                    children: [
                      Text(
                        categories[ind].name,
                        style: TextStyle(color: Colors.white),
                      ),
                      Container(
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          primary: true,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(20),
                          itemCount: categories[ind].polls.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.all(10),
                              width: 150,
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
                                    height: 50,
                                    // width: 100,
                                    child: Container(
                                      margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                                      child: Column(
                                        children: [
                                          Text(
                                            categories[ind].polls[index].name,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            'by: ${categories[ind].polls[index].creator}',
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
                                        builder: (context) => Vote(
                                            pollId: categories[ind]
                                                .polls[index]
                                                .id),
                                      ),
                                    ),
                                  },
                                  onLongPress: () => {
                                    pollDialog(
                                        categories[ind].polls[index].name,
                                        categories[ind].polls[index].id)
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              )),
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
