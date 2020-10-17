import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:poll/models/user.dart';
import '../services/database.dart';
import '../widget/widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import '../models/poll.dart';
import 'package:location/location.dart';

class NewPoll extends StatefulWidget {
  const NewPoll({Key key}) : super(key: key);

  @override
  _NewPollState createState() => _NewPollState();
}

class _NewPollState extends State<NewPoll> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController newPollTC;
  String dropdownValue = 'None';

  createPoll() async {
    if (newPollTC.text.isNotEmpty) {
      // Get poll's id
      await databaseMethods.getPollId(newPollTC.text).then((snapshot) {
        newPollDialog('Do you want to create ${newPollTC.text}?', false);
      });

      setState(() {
        // isLoading = true;
      });
    } else {
      newPollDialog('Invalid name!', true);
    }
  }

  Future<void> newPollDialog(String txt, bool error) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Poll'),
          content: Text(txt),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            error
                ? Container()
                : TextButton(
                    child: Text('Ok'),
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPoll(poll: newPollTC.text),
                        ),
                      )
                    },
                  )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    newPollTC = TextEditingController();
  }

  void dispose() {
    newPollTC.dispose();
    super.dispose();
  }

  void dismiss(String s) {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          SizedBox(height: 50),
          Container(
            alignment: Alignment.centerLeft,
            // decoration: kBoxDecorationStyle,
            height: 60.0,
            child: TextField(
              onSubmitted: dismiss,
              controller: newPollTC,
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.poll,
                  color: Colors.white,
                ),
                hintText: 'Enter the new poll name',
                hintStyle: TextStyle(
                  color: Colors.white24,
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          RaisedButton(child: Text('Create'), onPressed: createPoll),
        ],
      )),
    );
  }
}

class AddPoll extends StatefulWidget {
  const AddPoll({Key key, this.poll}) : super(key: key);

  final String poll;

  @override
  _AddPollState createState() => _AddPollState();
}

class _AddPollState extends State<AddPoll> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  List<PollItem> pollItems = [];
  String pollId;
  final picker = ImagePicker();
  bool isLoading = false;
  double latitude = 0, longitude = 0;

  void getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    latitude = _locationData.latitude;
    longitude = _locationData.longitude;
    setState(() {});
    return;
  }

  Future chooseFile(int index) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        pollItems[index].image = File(pickedFile.path);
        pollItems[index].hasMedia = true;
      } else {
        print('empty image');
      }
    });
  }

  Future<String> uploadFile(File image) async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('${pollId}/${Path.basename(image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;
    print('File Uploaded');
    await storageReference.getDownloadURL().then((fileURL) {
      return fileURL;
    });
    return '';
  }

  void checkItems() {
    // Check if all items have name and image
    for (int i = 0; i < pollItems.length; i++) {
      if (pollItems[i].controller.text == '') {
        submitDialog(true, 'There are items with empty names!');
        return;
      }
    }
    for (int i = 0; i < pollItems.length; i++) {
      if (pollItems[i].hasMedia == false) {
        submitDialog(false, 'There are items without image. Continue anyway?');
        return;
      }
    }
    uploadPoll();
  }

  Future uploadPoll() async {
    setState(() {
      isLoading = true;
    });
    // add poll to polls
    Map<String, dynamic> pollData = {
      "name": widget.poll,
      "creator": userIsAnonymous ? '' : userQuery.docs[0].id,
      "pop": 0,
      "lat": latitude,
      "lon": longitude
    };
    print('queso');
    DocumentReference poll = await databaseMethods.addPoll(pollData);
    print('pimenta');
    pollId = poll.id;
    print('antes');
    print('docId = $pollId');
    print('depois');

    // add poll to utils
    Map<String, dynamic> utilsData = {"id": pollId, "qnt": pollItems.length};
    await databaseMethods.addUtils(utilsData);

    // add each poll item
    for (int index = 0; index < pollItems.length; index++) {
      String link = '';
      if (pollItems[index].image != null)
        link = await uploadFile(pollItems[index].image);

      Map<String, dynamic> itemData = {
        "id": index,
        "name": pollItems[index].controller.text,
        "link": link,
        "score": 800
      };
      // Adding item
      print('Adding item');
      await databaseMethods.addPollItem(pollId, itemData);
    }

    // Add poll to user
    print('Adding poll to user');
    Map<String, String> pollUser = {"id": pollId};
    await databaseMethods.addUserPoll(pollUser);

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void initState() {
    pollItems.add(new PollItem.TC());
    getLocation();
    super.initState();
  }

  Future<void> submitDialog(bool error, String txt) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit Poll'),
          content: Text(txt),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            error
                ? Container()
                : TextButton(
                    child: Text('Ok'),
                    onPressed: () => {
                      uploadPoll(),
                      Navigator.of(context).pop(),
                    },
                  )
          ],
        );
      },
    );
  }

  void dispose() {
    for (int i; i < pollItems.length; i++) pollItems[i].controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.poll),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'add item',
            onPressed: () {
              setState(() {
                pollItems.add(new PollItem.TC());
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : ListView.builder(
              itemCount: pollItems.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      pollItems.removeAt(index);
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.delete),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextField(
                          controller: pollItems[index].controller,
                          onEditingComplete: () => {setState(() {})},
                          style: simpleTextStyle(),
                          decoration: InputDecoration(
                              hintText: "add item name ...",
                              hintStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              border: InputBorder.none),
                        ),
                      ),
                      Icon(
                        Icons.text_fields,
                        color: pollItems[index].controller.text != ''
                            ? Colors.green
                            : Colors.red,
                      ),
                      SizedBox(width: 20),
                      Container(
                        height: 100,
                        width: 100,
                        child: !pollItems[index].hasMedia
                            ? IconButton(
                                icon: Icon(Icons.image),
                                color: Colors.red,
                                onPressed: () => chooseFile(index),
                              )
                            : Image.file(pollItems[index].image,
                                fit: BoxFit.cover),
                      ),
                    ],
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () {
          checkItems();
        },
      ),
    );
  }
}

class EditPoll extends StatefulWidget {
  const EditPoll({Key key, this.pollId}) : super(key: key);

  final String pollId;

  @override
  _EditPollState createState() => _EditPollState();
}

class _EditPollState extends State<EditPoll> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  List<PollItem> pollItems = [];
  List<PollItem> prevItems = [];
  String pollName = '';
  final picker = ImagePicker();
  bool isLoading = false;

  Future chooseFile(int index) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        pollItems[index].image = File(pickedFile.path);
        pollItems[index].hasMedia = true;
      } else {
        print('empty image');
      }
    });
  }

  Future<void> uploadFile(File image, int itemId) async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('${widget.pollId}/${Path.basename(image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;
    print('File Uploaded');
    await storageReference.getDownloadURL().then((fileURL) {
      pollItems[itemId].link = fileURL;
    });
  }

  void checkItems() {
    // Check if all items have name and image
    for (int i = 0; i < pollItems.length; i++) {
      if (pollItems[i].controller.text == '') {
        submitDialog(true, 'There are items with empty names!');
        return;
      }
    }
    for (int i = 0; i < pollItems.length; i++) {
      if (pollItems[i].hasMedia == false) {
        submitDialog(false, 'There are items without image. Continue anyway?');
        return;
      }
    }
    uploadPoll();
  }

  Future uploadPoll() async {
    setState(() {
      isLoading = true;
    });

    // delete previous items
    await databaseMethods.deletePollItems(widget.pollId);

    // compare which items have changed
    // if (pollItems.length <= prevItems.length) {
    //   for (int index = 0; index < pollItems.length; index++) {

    //   }
    // }

    // add each poll item
    for (int index = 0; index < pollItems.length; index++) {
      if (pollItems[index].image != null)
        await uploadFile(pollItems[index].image, index);

      Map<String, dynamic> itemData = {
        "id": index,
        "name": pollItems[index].controller.text,
        "link": pollItems[index].link,
        "score": pollItems[index].score,
      };
      // Adding item
      print('Adding items');
      databaseMethods.addPollItem(widget.pollId, itemData);
    }

    // Update qnt in utils
    databaseMethods.setQnt(widget.pollId, pollItems.length);

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void loadData() async {
    // get poll name
    DocumentSnapshot pollSnap = await databaseMethods.getPoll(widget.pollId);
    pollName = pollSnap.get('name');
    // load pollItems with current poll's items
    QuerySnapshot poll = await databaseMethods.getPollItems(widget.pollId);
    for (int i = 0; i < poll.docs.length; i++) {
      pollItems.add(
        new PollItem(
          name: poll.docs[i].get('name'),
          link: poll.docs[i].get('link'),
          score: poll.docs[i].get('score').toDouble(),
        ),
      );
      prevItems.add(
        new PollItem(
          name: poll.docs[i].get('name'),
          link: poll.docs[i].get('link'),
          score: poll.docs[i].get('score').toDouble(),
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
    print('data loaded!');
  }

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    print('edit poll: ${widget.pollId}');
    loadData();
    super.initState();
  }

  Future<void> submitDialog(bool error, String txt) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit Poll'),
          content: Text(txt),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            error
                ? Container()
                : TextButton(
                    child: Text('Ok'),
                    onPressed: uploadPoll,
                  )
          ],
        );
      },
    );
  }

  void dispose() {
    for (int i; i < pollItems.length; i++) pollItems[i].controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isLoading
          ? AppBar(
              title: Text('Edit Poll'), backgroundColor: Colors.transparent)
          : AppBar(
              title: Text(pollName),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'add item',
                  onPressed: () {
                    setState(() {
                      pollItems.add(new PollItem.TC());
                    });
                  },
                ),
              ],
            ),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : ListView.builder(
              itemCount: pollItems.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      pollItems.removeAt(index);
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.delete),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextField(
                          controller: pollItems[index].controller,
                          onEditingComplete: () => {setState(() {})},
                          style: simpleTextStyle(),
                          decoration: InputDecoration(
                              hintText: "add item name ...",
                              hintStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              border: InputBorder.none),
                        ),
                      ),
                      Icon(
                        Icons.text_fields,
                        color: pollItems[index].controller.text != ''
                            ? Colors.green
                            : Colors.red,
                      ),
                      SizedBox(width: 20),
                      Container(
                          height: 100,
                          width: 100,
                          child: !pollItems[index].hasMedia
                              ? IconButton(
                                  icon: Icon(Icons.image),
                                  color: Colors.red,
                                  onPressed: () => chooseFile(index),
                                )
                              : Ink(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          pollItems[index].link,
                                        ),
                                        fit: BoxFit.cover),
                                  ),
                                )),
                    ],
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () {
          checkItems();
        },
      ),
    );
  }
}
