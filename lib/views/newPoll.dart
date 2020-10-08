import 'dart:io';
import 'package:flutter/material.dart';
import '../services/database.dart';
import '../widget/widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;

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
        newPollDialog(false);
      });

      setState(() {
        // isLoading = true;
      });
    } else {
      newPollDialog(true);
    }
  }

  Future<void> newPollDialog(bool error) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: error ? Text('Error') : Text('Create Poll'),
          content: SingleChildScrollView(
            child: ListBody(
              children: error
                  ? <Widget>[
                      Text('Please provide a name!'),
                    ]
                  : <Widget>[
                      Text('Do you want to create the poll ${newPollTC.text}?')
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
            error
                ? Container()
                : TextButton(
                    child: Text('Ok'),
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPoll(
                            poll: newPollTC.text,
                            type: dropdownValue,
                          ),
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
          DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: <String>['None', 'Photo', 'Video', 'Gif']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 30),
          RaisedButton(child: Text('Create'), onPressed: createPoll),
        ],
      )),
    );
  }
}

class AddPoll extends StatefulWidget {
  const AddPoll({Key key, this.poll, this.type}) : super(key: key);

  final String poll;
  final String type;

  @override
  _AddPollState createState() => _AddPollState();
}

class _AddPollState extends State<AddPoll> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  List<pollItem> pollItems = [];
  final picker = ImagePicker();
  String _uploadedFileURL = '';
  bool needsMedia = false;
  bool isLoading = false;

  Future chooseFile(int index) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        pollItems[index].image = File(pickedFile.path);
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

  Future uploadPoll() async {
    setState(() {
      isLoading = true;
    });
    // add poll to polls
    Map<String, String> pollData = {
      "name": widget.poll,
      "type": widget.type,
      "createdBy": 'user'
    };
    databaseMethods.addPoll(pollData);

    // add poll to utils
    Map<String, dynamic> utilsData = {"name": widget.poll, "qnt": 0};
    databaseMethods.addUtils(utilsData);

    // Get poll's id
    String docId;
    await databaseMethods.getPollId(widget.poll).then((snapshot) {
      docId = snapshot.docs[0].id;
    });
    print('docId = $docId');

    // Get utils qnt and id
    int qnt = 0;
    String qntId = '';
    await databaseMethods.getQnt(widget.poll).then((snapshot) {
      qnt = snapshot.docs[0].get("qnt");
      qntId = snapshot.docs[0].id;
    });

    // add each poll item
    for (int index = 0; index < pollItems.length; index++) {
      if (pollItems[index].image != null)
        await uploadFile(pollItems[index].image);

      Map<String, dynamic> itemData = {
        "id": qnt + index,
        "name": pollItems[index].controller.text,
        "link": _uploadedFileURL,
        "score": 800
      };
      databaseMethods.addPollItem(docId, itemData);
    }

    // Update qnt in utils
    databaseMethods.setQnt(qntId, qnt + pollItems.length);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    if (widget.type != 'None') needsMedia = true;
    pollItems.add(new pollItem());
    super.initState();
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
                pollItems.add(new pollItem());
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
                          // onChanged: (String text) =>
                          //     {pollItems[index].controller.text = text},
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
                      needsMedia
                          ? IconButton(
                              icon: Icon(Icons.image),
                              onPressed: () => chooseFile(index),
                            )
                          : Container()
                    ],
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () {
          uploadPoll();
        },
      ),
    );
  }
}

class pollItem {
  File image;
  TextEditingController controller;

  pollItem() {
    controller = new TextEditingController();
  }
}
