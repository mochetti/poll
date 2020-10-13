import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:poll/models/user.dart';
import '../services/database.dart';
import '../widget/widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import '../models/poll.dart';

class NewPoll extends StatefulWidget {
  const NewPoll({Key key}) : super(key: key);

  @override
  _NewPollState createState() => _NewPollState();
}

class _NewPollState extends State<NewPoll> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController newPollTC;
  String dropdownValue = 'None';

  File image;
  final picker = ImagePicker();
  String _uploadedFileURL;

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
  final picker = ImagePicker();
  String _uploadedFileURL = '';
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

  Future<void> uploadFile(File image) async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('${widget.poll}/${Path.basename(image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;
    print('File Uploaded');
    await storageReference.getDownloadURL().then((fileURL) {
      _uploadedFileURL = fileURL;
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
    // add poll to polls
    Map<String, dynamic> pollData = {
      "name": widget.poll,
      "creator": userQuery.docs[0].id,
      "pop": 0
    };
    databaseMethods.addPoll(pollData);

    // Get poll's id
    String docId;
    await databaseMethods.getPollId(widget.poll).then((snapshot) {
      docId = snapshot.docs[0].id;
    });
    print('docId = $docId');

    // add poll to utils
    Map<String, dynamic> utilsData = {"id": docId, "qnt": 0};
    databaseMethods.addUtils(utilsData);

    // Get utils qnt and id
    int qnt = 0;
    String qntId = '';
    await databaseMethods.getQnt(docId).then((snapshot) {
      qnt = snapshot.docs[0].get("qnt");
      qntId = snapshot.docs[0].id;
    });

    // add each poll item
    for (int index = 0; index < pollItems.length; index++) {
      _uploadedFileURL = '';
      if (pollItems[index].image != null)
        await uploadFile(pollItems[index].image);

      Map<String, dynamic> itemData = {
        "id": qnt + index,
        "name": pollItems[index].controller.text,
        "link": _uploadedFileURL,
        "score": 800
      };
      // Add poll to polls
      print('Adding poll to polls');
      databaseMethods.addPollItem(docId, itemData);
    }

    // Update qnt in utils
    databaseMethods.setQnt(qntId, qnt + pollItems.length);

    // Add poll to user
    print('Adding poll to user');
    Map<String, String> pollUser = {"id": docId};
    databaseMethods.addUserPoll(pollUser);

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void initState() {
    pollItems.add(new PollItem.TC());
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
                  onDismissed: (direction) {
                    // Remove the item from the data source.
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
                    children: [
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
                            : Colors.black,
                      ),
                      IconButton(
                        icon: Icon(Icons.image),
                        color: pollItems[index].hasMedia
                            ? Colors.green
                            : Colors.black,
                        onPressed: () => chooseFile(index),
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
