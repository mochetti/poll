import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'search.dart';
import 'vote.dart';
import '../services/database.dart';
import '../models/poll.dart';

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

  Future<void> loadData() async {
    await databaseMethods.getTrending().then((snapshot) {
      query = snapshot;
    });
    trendingPolls = [];
    for (int index = 0; index < query.docs.length; index++) {
      trendingPolls.add(new Poll(query.docs[index].get('name'),
          query.docs[index].get('createdBy'), query.docs[index].id));
    }
    setState(() {
      isLoading = false;
    });
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
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                primary: false,
                padding: const EdgeInsets.all(20),
                itemCount: trendingPolls.length,
                itemBuilder: (context, index) {
                  return CupertinoButton(
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
                          trendingPolls[index].name,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Vote(pollId: trendingPolls[index].id),
                        ),
                      ),
                    },
                  );
                },
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
