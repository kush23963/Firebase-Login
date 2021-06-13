import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import '../model/contact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class AddContact extends StatefulWidget {
  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  String _firstName = '';
  String _lastName = '';
  String _phone = '';
  String _email = '';
  String _address = '';
  String ?_photoUrl = "empty";

  saveContact(BuildContext context) async {
    if (_firstName.isNotEmpty &&
        _lastName.isNotEmpty &&
        _phone.isNotEmpty &&
        _email.isNotEmpty &&
        _address.isNotEmpty) {
      Contact contact = Contact(this._firstName, this._lastName, this._phone,
          this._email, this._address, this._photoUrl!);

      await _databaseReference.push().set(contact.toJson());
      navigateToLastScreen(context);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Field required"),
              content: Text("All fields are required"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }
  late File imageFile;
  Future pickImage() async {
    PickedFile? file = await ImagePicker().getImage(
        source: ImageSource.gallery, maxHeight: 200.0, maxWidth: 200.0);
    String fileName = basename(file!.path);
    if (file != null) {
        imageFile = File(file.path);
    }
    uploadImage(imageFile, fileName);
  }

  void uploadImage(File file, String fileName) async {
    // Reference storageReference =
    //     FirebaseStorage.instance.ref().child(fileName);
    //     storageReference.putFile(file).then((firebaseFile) async {
    //       var downloadUrl = await firebaseFile.ref.getDownloadURL();
    //       setState(() {
    //         _photoUrl = downloadUrl;
    //       });
    //     });
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(fileName);
    UploadTask uploadTask = ref.putFile(file);
    uploadTask.then((res) async{
      var downloadUrl = await res.ref.getDownloadURL();
      setState(() {
        _photoUrl = downloadUrl;
      });
    });
  }

  navigateToLastScreen(context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add contact"),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: GestureDetector(
                  onTap: () {
                    this.pickImage();
                  },
                  child: Center(
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: (_photoUrl == "empty")
                                ? AssetImage("assets/logo.png")
                                : NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBlGbErakRHzC9ylkGeH_H_Tkh4EpjGzpKrQ&usqp=CAU") as ImageProvider,
                          )),
                    ),
                  ),
                ),
              ),
              //first name
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _firstName = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              //last name
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _lastName = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              //phone
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _phone = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              //email
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              //address
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _address = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              //save
              Container(
                padding: EdgeInsets.only(top: 20.0),
                child: RaisedButton(
                  padding: EdgeInsets.fromLTRB(100, 20, 100, 20),
                  onPressed: () {
                    saveContact(context);
                  },
                  color: Colors.red,
                  child: Text("Save",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
