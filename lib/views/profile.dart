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
      await databaseMethods.getPoll(query.docs[index].get('id')).then(
        (snapshot) {
          DocumentSnapshot q = snapshot;
          if (q.get('active'))
            myPolls.add(new Poll.nameAndID(q.get('name'), q.id));
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
    if (!userIsAnonymous) loadData();
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  Future<void> deleteDialog(String pollId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Poll'),
          content: Container(
            height: 150,
            child: Column(
              children: [
                Text('Are you sure? \nThis cannot be undone'),
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
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                await databaseMethods.deletePoll(pollId);
                Navigator.of(context).popUntil((route) => route.isFirst);
                setState(() {
                  isLoading = true;
                });
                if (!userIsAnonymous) loadData();
              },
            )
          ],
        );
      },
    );
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
                    deleteDialog(pollId);
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
              : myPolls.length == 0
                  ? RefreshIndicator(
                      onRefresh: userIsAnonymous ? null : loadData,
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Center(
                          child: Container(
                            child: Text(
                              'You do not have any polls yet! \nClick above to add one!',
                              style: TextStyle(color: Colors.white),
                            ),
                            height: MediaQuery.of(context).size.height,
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: userIsAnonymous ? null : loadData,
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
                          return pollCard(
                              name: myPolls[index].name,
                              creator: myPolls[index].creator,
                              pollId: myPolls[index].id,
                              context: context,
                              isOwner: true,
                            );
                        },
                      ),
                    ),
    );
  }
}
