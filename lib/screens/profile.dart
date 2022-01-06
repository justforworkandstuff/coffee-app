import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeproject/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  //services and keys
  final FirebaseStorage storage = FirebaseStorage.instance;
  final _validationkey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  final _user = FirebaseAuth.instance;
  bool loading = false;

  //initState and manualRefresh
  //Map<String, dynamic>? data;
  //String userCurrentImage = '';
  //double balance = 0.0;

  //createReloadDialog
  double reloadAmount = 0.0;

  //createEditDialog
  int phoneNo = 000;
  String address = '';

  //uploadFile, removeImage, loadPicker
  File? image;
  String emptyImage = 'The current image is already empty.';

  // reload dialog
  void createReloadDialog(BuildContext context, double balance) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Reload'),
            content: Form(
              key: _validationkey,
              child: TextFormField(
                initialValue: 0.00.toString(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^(\d+)?\.?\d{0,2}'))
                ],
                decoration:
                    textFormFieldDecoration.copyWith(hintText: 'Reload Amount'),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter an amount.' : null,
                onChanged: (val) {
                  setState(() => reloadAmount = double.parse(val.toString()));
                },
              ),
            ),
            actions: [
              MaterialButton(
                  onPressed: () async {
                    if (_validationkey.currentState!.validate()) {
                      await _auth.userBalanceAdd(balance, reloadAmount);

                      print('reload done #createReloadDialog');
                      Navigator.pop(context);
                      // manualRefresh();
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

  // user details phone edit dialog
  void createEditPhoneDialog(BuildContext context, int initialNumber) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit'),
            content: Form(
              key: _validationkey,
              child: TextFormField(
                initialValue: initialNumber.toString(),
                maxLength: 9,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration:
                    textFormFieldDecoration.copyWith(hintText: 'Phone number'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please enter your phone number';
                  } else if (val.length < 9) {
                    return 'Minimum length = 9.';
                  } else {
                    return null;
                  }
                },
                onChanged: (val) {
                  setState(() => phoneNo = int.parse(val));
                },
              ),
            ),
            actions: [
              MaterialButton(
                  onPressed: () async {
                    if (_validationkey.currentState!.validate()) {
                      await _auth.userPhoneUpdate(phoneNo);
                      print('update phone done #createEditPhoneDialog');
                      Navigator.pop(context);
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

  // user details address edit dialog
  void createEditAddressDialog(BuildContext context, String initialAddress) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit'),
            content: Form(
              key: _validationkey,
              child: TextFormField(
                maxLength: 100,
                maxLines: 3,
                initialValue: initialAddress,
                decoration:
                    textFormFieldDecoration.copyWith(hintText: 'Address'),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter your address.' : null,
                onChanged: (val) {
                  setState(() => address = val);
                },
              ),
            ),
            actions: [
              MaterialButton(
                  onPressed: () async {
                    if (_validationkey.currentState!.validate()) {
                      await _auth.userAddressUpdate(address);
                      print('update address done #createEditAddressDialog');
                      Navigator.pop(context);
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
                  ListTile(
                    title: Text('Remove picture'),
                    onTap: () {
                      // removeImage();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ));
  }

  //remove image
  // void removeImage() async {
  //   try {
  //     if (userCurrentImage != '') {
  //       FirebaseStorage.instance.refFromURL(userCurrentImage).delete();
  //       setState(() {
  //         loading = true;
  //         userCurrentImage = '';
  //       });
  //       dynamic result = await _auth.userImageAdd(userCurrentImage);

  //       if (result == null) {
  //         Fluttertoast.showToast(msg: 'User image removed successfully.');
  //         setState(() => loading = false);
  //       } else {
  //         Fluttertoast.showToast(msg: 'Something went wrong..');
  //         setState(() => loading = false);
  //       }
  //     } else {
  //       Fluttertoast.showToast(msg: emptyImage);
  //       print(emptyImage);
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  //image picker
  void loadPicker(ImageSource source) async {
    try {
      final pickedImaged =
          await ImagePicker().pickImage(source: source, maxWidth: 1920);
      if (pickedImaged != null) {
        setState(() {
          image = File(pickedImaged.path);
        });
        await uploadFile(image!);
      } else if (pickedImaged == null) return;
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  //uploading image to firebase storage
  Future uploadFile(File _theImage) async {
    setState(() => loading = true);
    var url;
    if (image == null) return;

    final String fileName = basename(image!.path);
    Reference ref = storage.ref().child('userImage/$fileName');
    UploadTask uploadTask = ref.putFile(_theImage);
    uploadTask.whenComplete(() async {
      url = await ref.getDownloadURL();
      dynamic result = await _auth.userImageAdd(url);
      // if (userCurrentImage != '') {
      //   FirebaseStorage.instance.refFromURL(userCurrentImage).delete();
      // }

      if (result == null) {
        setState(() => loading = false);
        Fluttertoast.showToast(msg: 'Image added successfully');
        // manualRefresh();
      } else {
        setState(() => loading = false);
        Fluttertoast.showToast(msg: 'Image add error. Please try again.');
      }
    });
    return url;
  }

  //reading profile
  // @override
  // void initState() {
  //   super.initState();
  //   setState(() => loading = true);
  //   _auth.userItemRead().then((value) {
  //     data = value.data();
  //     setState(() {
  //       loading = false;
  //       balance = data!['balance'];
  //       userCurrentImage = data!['image'];
  //       print('Initial read userImage done #initState #profile.dart');
  //     });
  //   });
  // }

  //manual refresh
  // void manualRefresh() {
  //   setState(() => loading = true);
  //   _auth.userItemRead().then((value) {
  //     data = value.data();
  //     setState(() {
  //       loading = false;
  //       balance = data!['balance'];
  //       userCurrentImage = data!['image'];
  //       print('Refresh userImage done #manualRefresh');
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : SingleChildScrollView(
            child: Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(25.0),
                child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('User')
                        .doc(_user.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }

                      final DocumentSnapshot? userSnapshot = snapshot.data;
                      final Map<String, dynamic> userMap =
                          userSnapshot!.data() as Map<String, dynamic>;

                      return Column(
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
                                      foregroundImage:
                                          NetworkImage(userMap['image']),
                                      radius: 50.0,
                                      backgroundColor: Colors.white,
                                      backgroundImage:
                                          Image.asset('assets/useravatar.png')
                                              .image,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 25.0),
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(flex: 5, child: Text('Name:')),
                                        Text('  '),
                                        Expanded(
                                            flex: 5,
                                            child: Text(userMap['userName'])),
                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                            flex: 5, child: Text('Balance:')),
                                        Expanded(
                                            flex: 5,
                                            child: Text(
                                                'RM ${userMap['balance']}')),
                                      ],
                                    ),
                                    SizedBox(height: 15.0),
                                    ElevatedButton.icon(
                                        onPressed: () {
                                          createReloadDialog(context, userMap['balance']);
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
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.phone),
                                      ),
                                      SizedBox(width: 10.0),
                                      Expanded(
                                        flex: 4,
                                        child: Text('Phone No:'),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          userMap['phoneNo'].toString(),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            createEditPhoneDialog(
                                                context, userMap['phoneNo']);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Icon(Icons.home),
                                        ),
                                        SizedBox(width: 10.0),
                                        Expanded(
                                          flex: 4,
                                          child: Text('Address:'),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            userMap['address'],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              createEditAddressDialog(
                                                  context, userMap['address']);
                                            },
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 25.0),
                          Text(
                              'Current number of orders: ${userMap['orders'].toString()}'),
                        ],
                      );
                    })),
          );
  }
}
