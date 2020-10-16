import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poll/models/user.dart';

import 'vote.dart';
import '../services/database.dart';
import '../models/poll.dart';
import 'newPoll.dart';

class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot query;
  List<Poll> myPolls = [];

  bool isLoading = false;

  Future<void> loadData() async {
    await databaseMethods.getUserPolls().then((snapshot) {
      query = snapshot;
    });
    myPolls = [];
    for (int index = 0; index < query.docs.length; index++) {
      // print(query.docs[index].get('id'));
      await databaseMethods.getPoll(query.docs[index].get('id')).then(
        (snapshot) {
          DocumentSnapshot q = snapshot;
          myPolls.add(new Poll.name(q.get('name')));
        },
      );
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
    loadData();
    super.initState();
  }

  void dispose() {
    super.dispose();
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
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPoll(
                          pollId: pollId,
                        ),
                      ),
                    )
                  },
                ),
                Row(
                  children: [
                    RaisedButton(
                      child: Text('Wpp'),
                      onPressed: null,
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    databaseMethods.deletePoll(pollId);
                  },
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Polls'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewPoll(),
                ),
              ),
            },
          )
        ],
      ),
      body: userIsAnonymous
          ? Container(
              child: Center(
                child: Text('Please login in to see your polls',
                    style: TextStyle(color: Colors.white)),
              ),
            )
          : isLoading
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
                    itemCount: myPolls.length,
                    itemBuilder: (context, index) {
                      return Ink(
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
                                myPolls[index].name,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Vote(pollId: query.docs[index].get('id')),
                              ),
                            ),
                          },
                          onLongPress: () => {
                            pollDialog(myPolls[index].name, myPolls[index].id)
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
