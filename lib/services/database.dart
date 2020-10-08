import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addUser(userData) async {
    FirebaseFirestore.instance
        .collection("users")
        .add(userData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserInfo(String email) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns doc from id
  getDoc(String docId, int id) async {
    return FirebaseFirestore.instance
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
        .limit(5)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns specific doc id
  getPollId(String poll) async {
    // QuerySnapshot searchResultSnapshot;
    return FirebaseFirestore.instance
        .collection('polls')
        .where('name', isEqualTo: poll)
        .limit(1)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns specific poll qnt
  getQnt(String poll) async {
    // QuerySnapshot searchResultSnapshot;
    return FirebaseFirestore.instance
        .collection("utils")
        .where('name', isEqualTo: poll)
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
        .setData(itemData);
  }

  searchByName(String searchField) {
    return FirebaseFirestore.instance
        .collection("users")
        .where('userName', isEqualTo: searchField)
        .get();
  }

  searchByPollName(String searchField) {
    return FirebaseFirestore.instance
        .collection("polls")
        .where('name', isGreaterThanOrEqualTo: searchField)
        .where('name', isLessThan: '$searchField\uF7FF')
        .get();
  }

  Future<bool> addChatRoom(chatRoom, chatRoomId) {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .set(chatRoom)
        .catchError((e) {
      print(e);
    });
  }

  getChats(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy('time')
        .snapshots();
  }

  Future<void> addMessage(String chatRoomId, chatMessageData) {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserChats(String itIsMyName) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .where('users', arrayContains: itIsMyName)
        .snapshots();
  }
}
