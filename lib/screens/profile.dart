import 'dart:io';
import 'package:coffeeproject/shared/loading.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:coffeeproject/shared/auth.dart';
import 'package:coffeeproject/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _validationkey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  Map<String, dynamic>? data;

  String name = '';
  String userID = '';
  int phoneNo = 0;
  String address = '';
  double balance = 0.0;
  double reloadAmount = 0.0;
  String userDD = '';
  File? image;
  var sample = AssetImage('assets/useravatar.png');
  FirebaseStorage storage = FirebaseStorage.instance;
  String userCurrentImage = '';
  bool loading = false;
  int orders = 0;

  // reload dialog
  void createAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Reload'),
            content: Form(
              key: _validationkey,
              child: TextFormField(
                initialValue: 0.00.toString(),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))],
                decoration:
                    textFormFieldDecoration.copyWith(hintText: 'Reload Amount'),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter an amount.' : null,
                onChanged: (val) {
                  setState(() {
                    reloadAmount = double.parse(val.toString());
                  });
                },
              ),
            ),
            actions: [
              MaterialButton(
                  onPressed: () async {
                    if (_validationkey.currentState!.validate()) {
                      await _auth.userBalanceAdd(balance, reloadAmount);
                      print('reload done');
                      Navigator.pop(context);
                      manualRefresh();
                    }
                  },
                  child: Text('Confirm')),
              MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
            ],
          );
        });
  }

  // profile avatar selection dialog
  void _showPickedOptionsDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Pick an image'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Pick from gallery'),
                    onTap: () {
                      loadPicker(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text('Take a picture'),
                    onTap: () {
                      loadPicker(ImageSource.camera);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ));
  }

  //image picker
  void loadPicker(ImageSource source) async {
    try {
      final pickedImaged =
          await ImagePicker().pickImage(source: source, maxWidth: 1920);
      if (pickedImaged != null) {
        setState(() {
          image = File(pickedImaged.path);
        });
        uploadFile(image!);
      } else if (pickedImaged == null) return;
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  //uploading image to firebase storage
  Future uploadFile(File _theImage) async {
    var url;
    if (image == null) return;

    final String fileName = basename(image!.path);
    Reference ref = storage.ref().child('userImage/$fileName');
    UploadTask uploadTask = ref.putFile(_theImage);
    uploadTask.whenComplete(() async {
      url = await ref.getDownloadURL();
      _auth.userImageAdd(url);
    });
    return url;
  }

  //reading profile
  @override
  void initState() {
    super.initState();
    setState(() => loading = true);
    _auth.userItemRead().then((value) {
      data = value.data();
      setState(() {
        loading = false;
        name = data!['userName'];
        balance = data!['balance'];
        phoneNo = data!['phoneNo'];
        address = data!['address'];
        userCurrentImage = data!['image'];
        orders = data!['orders'];
        print('update done');
      });
    });
  }

  //manual refresh
  void manualRefresh() {
    setState(() => loading = true);
    setState(() => loading = true);
    _auth.userItemRead().then((value) {
      data = value.data();
      setState(() {
        loading = false;
        name = data!['userName'];
        balance = data!['balance'];
        phoneNo = data!['phoneNo'];
        address = data!['address'];
        userCurrentImage = data!['image'];
        print('update done');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : SingleChildScrollView(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(25.0),
              child: Column(
                children: [
                  //top row 
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: CircleAvatar(
                          radius: 55.0,
                          backgroundColor: Colors.green[300],
                          child: InkWell(
                            onTap: () {
                              _showPickedOptionsDialog(context);
                            },
                            child: CircleAvatar(
                              radius: 50.0,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                  child: image != null
                                      ? Image.file(
                                          image!,
                                          fit: BoxFit.fill,
                                        )
                                      : Image.network(
                                          userCurrentImage,
                                          fit: BoxFit.fill,
                                        )),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 25.0),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(flex: 5, child: Text('Name:')),
                                Text('  '),
                                Expanded(flex: 5, child: Text(name)),
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(flex: 5, child: Text('Balance:')),
                                Text('RM '),
                                Expanded(
                                    flex: 5, child: Text(balance.toString())),
                              ],
                            ),
                            SizedBox(height: 15.0),
                            ElevatedButton.icon(
                                onPressed: () {
                                  createAlertDialog(context);
                                },
                                icon: Icon(Icons.money),
                                label: Text('Top up')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25.0),
                  //middle row
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Profile Details',
                        style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(height: 10.0, color: Colors.black),
                      SizedBox(height: 5.0),
                      Card(
                        elevation: 10.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(flex: 1, child: Icon(Icons.phone)),
                                SizedBox(width: 10.0),
                                Expanded(flex: 4, child: Text('Phone No:')),
                                Flexible(
                                    flex: 5, child: Text(phoneNo.toString())),
                              ]),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Card(
                        elevation: 10.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(flex: 1, child: Icon(Icons.home)),
                                SizedBox(width: 10.0),
                                Expanded(flex: 4, child: Text('Address:')),
                                Flexible(flex: 5, child: Text(address)),
                              ]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25.0),
                  Text('Current number of orders: ${orders.toString()}'),
                ],
              ),
            ),
          );
  }
}
