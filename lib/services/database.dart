import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user.dart';
import '../models/poll.dart';
import 'package:cloud_functions/cloud_functions.dart';

class DatabaseMethods {
  Future<void> addUser(userData) async {
    FirebaseFirestore.instance
        .collection("users")
        .add(userData)
        .catchError((e) {
      print(e.toString());
    });
  }

  // get info using UID
  getUserInfo(String uid) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("uid", isEqualTo: uid)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // get user using id
  getUser(String id) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns doc from id
  getDoc(String docId, int id) async {
    return await FirebaseFirestore.instance
        .collection('polls')
        .doc(docId)
        .collection('items')
        .where('id', isEqualTo: id)
        .limit(1)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns multiple docs
  getTrending() async {
    return FirebaseFirestore.instance
        .collection('polls')
        .orderBy('pop', descending: true)
        .limit(5)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns multiple docs
  getUserPolls() async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userQuery.docs[0].id)
        .collection('polls')
        // .where('active', isEqualTo: true)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Delete specific poll from users document
  deletePollFromUser(String pollId) async {
    // First get poll's doc id inside user doc
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userQuery.docs[0].id)
        .collection('polls')
        .where('id', isEqualTo: pollId)
        .get()
        .catchError((e) {
      print(e.toString());
    });
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userQuery.docs[0].id)
        .collection('polls')
        .doc(snap.docs[0].id)
        .delete()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns specific poll id using name
  getPollId(String poll) async {
    return FirebaseFirestore.instance
        .collection('polls')
        .where('name', isEqualTo: poll)
        .limit(1)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns specific poll using id
  getPoll(String pollId) async {
    return await FirebaseFirestore.instance
        .collection('polls')
        .doc(pollId)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns poll's items using poll's id in item's id order
  getPollItems(String pollId) async {
    return await FirebaseFirestore.instance
        .collection('polls')
        .doc(pollId)
        .collection('items')
        .orderBy('id')
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns top items using poll id
  getTop(String pollId) async {
    return await FirebaseFirestore.instance
        .collection('polls')
        .doc(pollId)
        .collection('items')
        .orderBy('score', descending: true)
        .limit(5)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns specific poll qnt
  getQnt(String pollId) async {
    return await FirebaseFirestore.instance
        .collection("utils")
        .where('id', isEqualTo: pollId)
        .limit(1)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Set poll qnt
  Future<void> setQnt(String pollId, int qnt) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('utils')
        .where('id', isEqualTo: pollId)
        .limit(1)
        .get();
    return FirebaseFirestore.instance
        .collection('utils')
        .doc(query.docs[0].id)
        .update({
      'qnt': qnt,
    }).catchError((e) {
      print(e.toString());
    });
  }

  // Delete all poll's items using poll id
  Future<void> deletePollItems(String pollId) async {
    QuerySnapshot items = await getPollItems(pollId);
    for (int index = 0; index < items.docs.length; index++) {
      await FirebaseFirestore.instance
          .collection('polls')
          .doc(pollId)
          .collection('items')
          .doc(items.docs[index].id)
          .delete()
          .catchError((e) {
        print(e.toString());
      });
    }
  }

  // Calls cloud function to iterate over and delete every doc in poll using id
  deletePoll(String pollId) async {
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('recursiveDelete');
      final results = await callable.call({'path': pollId});
      return results.data;
    } catch (e) {
      print(e);
    }
  }

  // Set doc field
  Future<void> setScore(String pollId, String docId, double score) async {
    FirebaseFirestore.instance
        .collection('polls')
        .doc(pollId)
        .collection('items')
        .doc(docId)
        .update({
      'score': score,
    }).catchError((e) {
      print(e.toString());
    });
  }

  // Add poll to utils
  addUtils(utilsData) async {
    return FirebaseFirestore.instance
        .collection('utils')
        .add(utilsData)
        .catchError((e) {
      print(e.toString());
    });
  }

  // Add poll
  addPoll(pollData) async {
    return FirebaseFirestore.instance
        .collection('polls')
        .add(pollData)
        .catchError((e) {
      print(e.toString());
    });
  }

  // Add poll item
  Future<void> addPollItem(String pollId, itemData) async {
    FirebaseFirestore.instance
        .collection('polls')
        .doc(pollId)
        .collection('items')
        .doc()
        .set(itemData);
  }

  // Add poll to user info
  Future<void> addUserPoll(itemData) async {
    print(userQuery.docs[0].id);
    FirebaseFirestore.instance
        .collection('users')
        .doc(userQuery.docs[0].id)
        .collection('polls')
        .doc()
        .set(itemData);
  }

  // searchByName(String searchField) {
  //   return FirebaseFirestore.instance
  //       .collection("users")
  //       .where('userName', isEqualTo: searchField)
  //       .get();
  // }

  searchByPollName(String searchField) {
    return FirebaseFirestore.instance
        .collection("polls")
        .where('name', isGreaterThanOrEqualTo: searchField)
        .where('name', isLessThan: '$searchField\uF7FF')
        .get();
  }
}
