import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class DatabaseMethods {
  Future<void> addUser(userData) async {
    FirebaseFirestore.instance
        .collection("users")
        .add(userData)
        .catchError((e) {
      print(e.toString());
    });
  }

  // get info using email
  getUserInfo(String email) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
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
        .get()
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
  Future<void> setQnt(String docId, int qnt) async {
    FirebaseFirestore.instance.collection('utils').doc(docId).update({
      'qnt': qnt,
    }).catchError((e) {
      print(e.toString());
    });
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
  Future<void> addUtils(utilsData) async {
    FirebaseFirestore.instance
        .collection('utils')
        .add(utilsData)
        .catchError((e) {
      print(e.toString());
    });
  }

  // Add poll
  Future<void> addPoll(pollData) async {
    FirebaseFirestore.instance
        .collection('polls')
        .add(pollData)
        .catchError((e) {
      print(e.toString());
    });
  }

  // Add poll item
  Future<void> addPollItem(String docId, itemData) async {
    FirebaseFirestore.instance
        .collection('polls')
        .doc(docId)
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
