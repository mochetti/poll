import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
import '../models/user.dart';
// import '../models/poll.dart';
// import 'package:cloud_functions/cloud_functions.dart';

class DatabaseMethods {
  Future<void> addUser(userData) async {
    await FirebaseFirestore.instance
        .collection("users")
        .add(userData)
        .catchError((e) {
      print(e.toString());
    });
  }

  // get info using UID
  getUserInfo(String uid) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("uid", isEqualTo: uid)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // get user using id
  getUser(String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns doc from id
  getItem(String pollId, int id) async {
    return await FirebaseFirestore.instance
        .collection('polls')
        .doc(pollId)
        .collection('items')
        .where('id', isEqualTo: id)
        .limit(1)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns multiple docs
  getTrending(String catId) async {
    return await FirebaseFirestore.instance
        .collection('categories')
        .doc(catId)
        .collection('polls')
        .where('active', isEqualTo: true)
        .orderBy('pop', descending: true)
        .limit(5)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns user polls
  getUserPolls() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userQuery.docs[0].id)
        .collection('polls')
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Delete specific poll from users document
  // deletePollFromUser(String pollId) async {
  //   // First get poll's doc id inside user doc
  //   QuerySnapshot snap = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(userQuery.docs[0].id)
  //       .collection('polls')
  //       .where('id', isEqualTo: pollId)
  //       .get()
  //       .catchError((e) {
  //     print(e.toString());
  //   });
  //   return FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(userQuery.docs[0].id)
  //       .collection('polls')
  //       .doc(snap.docs[0].id)
  //       .delete()
  //       .catchError((e) {
  //     print(e.toString());
  //   });
  // }

  // Returns specific poll id using name
  // getPollId(String poll) async {
  //   return await FirebaseFirestore.instance
  //       .collection('polls')
  //       .where('name', isEqualTo: poll)
  //       .limit(1)
  //       .get()
  //       .catchError((e) {
  //     print(e.toString());
  //   });
  // }

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
    return await FirebaseFirestore.instance
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
  // deletePoll(String pollId) async {
  //   try {
  //     HttpsCallable callable =
  //         FirebaseFunctions.instance.httpsCallable('recursiveDelete');
  //     final results = await callable.call({'path': pollId});
  //     return results.data;
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // Set field active to false
  deletePoll(String pollId) async {
    await FirebaseFirestore.instance.collection('polls').doc(pollId).update({
      'active': false,
    }).catchError((e) {
      print(e.toString());
    });
  }

  // Set doc field
  Future<void> setScore(String pollId, String docId, double score) async {
    await FirebaseFirestore.instance
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

  // Check if poll's name already exists
  Future<bool> checkPollName(String name) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('polls')
        .where('nameFormatted', isEqualTo: name)
        .get()
        .catchError((e) {
      print(e.toString());
    });
    if (query.docs.length > 0) return true;
    return false;
  }

  // Add poll to utils
  addUtils(utilsData) async {
    return await FirebaseFirestore.instance
        .collection('utils')
        .add(utilsData)
        .catchError((e) {
      print(e.toString());
    });
  }

  // Add poll
  addPoll(pollData) async {
    return await FirebaseFirestore.instance
        .collection('polls')
        .add(pollData)
        .catchError((e) {
      print(e.toString());
    });
  }

  // Add poll item
  Future<void> addPollItem(String pollId, itemData) async {
    await FirebaseFirestore.instance
        .collection('polls')
        .doc(pollId)
        .collection('items')
        .doc()
        .set(itemData)
        .catchError((e) {
      print(e.toString());
    });
  }

  // Add poll to user info
  Future<void> addUserPoll(itemData) async {
    print(userQuery.docs[0].id);
    FirebaseFirestore.instance
        .collection('users')
        .doc(userQuery.docs[0].id)
        .collection('polls')
        .doc()
        .set(itemData)
        .catchError((e) {
      print(e.toString());
    });
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
        .where('active', isEqualTo: true)
        .where('nameFormatted', isGreaterThanOrEqualTo: searchField)
        .where('nameFormatted', isLessThan: '$searchField\uF7FF')
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Return all categories
  getCategories() async {
    return await FirebaseFirestore.instance
        .collection("categories")
        .where('active', isEqualTo: true)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns category's polls
  getCatPolls(String catId) async {
    return await FirebaseFirestore.instance
        .collection('categories')
        .doc(catId)
        .collection('polls')
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }
}
