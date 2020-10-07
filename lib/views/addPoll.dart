import 'dart:io';
import 'package:flutter/material.dart';
import '../services/database.dart';
import '../widget/widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;

class AddPoll extends StatefulWidget {
  const AddPoll({Key key, this.poll}) : super(key: key);

  final String poll;

  @override
  _AddPollState createState() => _AddPollState();
}

class _AddPollState extends State<AddPoll> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  List<TextEditingController> _controllers = new List();

  File image;
  final picker = ImagePicker();
  String _uploadedFileURL;
  int itemsQnt = 1;

  Future chooseFile() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('${widget.poll}/${Path.basename(image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
  }

  Future uploadPoll() async {}

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    for (int i; i < itemsQnt; i++) _controllers[i].dispose();
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
                itemsQnt += 1;
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: itemsQnt,
          itemBuilder: (context, index) {
            _controllers.add(new TextEditingController());

            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controllers[index],
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
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: chooseFile,
                )
              ],
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
