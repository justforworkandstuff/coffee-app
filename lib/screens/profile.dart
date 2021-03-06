import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  //initState and manualRefresh
  Map<String, dynamic>? data;
  String userCurrentImage = '';
  //double balance = 0.0;

  //createReloadDialog
  double reloadAmount = 0.0;

  //createEditDialog
  String? street;
  String? city;
  String? state;
  int? postcode;
  int? phoneNo;

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
                  } else if (val.startsWith('0')) {
                    return '0 must not be starting digit.';
                  }
                },
                onChanged: (val) {
                  if (int.parse(val) != initialNumber) {
                    setState(() => phoneNo = int.parse(val));
                  }
                },
              ),
            ),
            actions: [
              MaterialButton(
                  onPressed: () async {
                    if (_validationkey.currentState!.validate()) {
                      if (phoneNo == null) {
                        await _auth.userPhoneUpdate(initialNumber);
                        print('update phone done #createEditPhoneDialog');
                        Navigator.pop(context);
                      } else {
                        await _auth.userPhoneUpdate(phoneNo);
                        print('update phone done #createEditPhoneDialog');
                        Navigator.pop(context);
                      }
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

  // user details street edit dialog
  void createEditStreetDialog(BuildContext context, String initialAddress) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Edit'),
            content: Form(
              key: _validationkey,
              child: TextFormField(
                maxLength: 50,
                maxLines: 2,
                initialValue: initialAddress,
                decoration:
                    textFormFieldDecoration.copyWith(hintText: 'Street'),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter your street.' : null,
                onChanged: (val) {
                  if (val != initialAddress) {
                    setState(() => street = val);
                  }
                },
              ),
            ),
            actions: [
              MaterialButton(
                  onPressed: () async {
                    if (_validationkey.currentState!.validate()) {
                      if (street == null) {
                        await _auth.userStreetUpdate(
                          initialAddress,
                        );
                        print('no street updated #createEditStreetDialog');
                        Navigator.pop(context);
                      } else {
                        await _auth.userStreetUpdate(street);
                        print('update street done #createEditStreetDialog');
                        Navigator.pop(context);
                      }
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

  // user details city edit dialog
  void createEditCityDialog(BuildContext context, String initialCity) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Edit'),
            content: Form(
              key: _validationkey,
              child: TextFormField(
                maxLength: 15,
                maxLines: 1,
                initialValue: initialCity,
                decoration: textFormFieldDecoration.copyWith(hintText: 'City'),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter your city.' : null,
                onChanged: (val) {
                  if (val != initialCity) {
                    setState(() => city = val);
                  }
                },
              ),
            ),
            actions: [
              MaterialButton(
                  onPressed: () async {
                    if (_validationkey.currentState!.validate()) {
                      if (city == null) {
                        await _auth.userCityUpdate(initialCity);
                        print('no city updated #createEditCityDialog');
                        Navigator.pop(context);
                      } else {
                        await _auth.userCityUpdate(city);
                        print('update city done #createEditCityDialog');
                        Navigator.pop(context);
                      }
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

  // user details state edit dialog
  void createEditStateDialog(BuildContext context, String initialState) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Edit'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Form(
                  key: _validationkey,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: initialState,
                    items: states.map((val) {
                      return DropdownMenuItem(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: (newVal) {
                      setState(() => initialState = newVal!);
                    },
                  ),
                );
              },
            ),
            actions: [
              MaterialButton(
                  onPressed: () async {
                    if (_validationkey.currentState!.validate()) {
                      if (state == null) {
                        await _auth.userStateUpdate(initialState);
                        print('no state updated #createEditStateDialog');
                        Navigator.pop(context);
                      } else {
                        await _auth.userStateUpdate(state);
                        print('update state done #createEditStateDialog');
                        Navigator.pop(context);
                      }
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

  // user details postcode edit dialog
  void createEditPostCodeDialog(BuildContext context, int initialPostCode) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Edit'),
            content: Form(
              key: _validationkey,
              child:
                  //postcode
                  TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                maxLength: 5,
                maxLines: 1,
                initialValue: initialPostCode.toString(),
                decoration:
                    textFormFieldDecoration.copyWith(hintText: 'Post Code'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please enter your post code';
                  } else if (val.startsWith('0')) {
                    return '0 must not be starting digit.';
                  } else if (val.length < 5) {
                    return 'Minimum length = 5';
                  }
                },
                onChanged: (val) {
                  if (int.parse(val) != initialPostCode) {
                    setState(() => postcode = int.parse(val));
                  }
                },
              ),
            ),
            actions: [
              MaterialButton(
                  onPressed: () async {
                    if (_validationkey.currentState!.validate()) {
                      if (postcode == null) {
                        await _auth.userPostCodeUpdate(initialPostCode);
                        print('no postcode updated #createEditPostCodeDialog');
                        Navigator.pop(context);
                      } else {
                        await _auth.userPostCodeUpdate(postcode);
                        print('update postcode done #createEditPostCodeDialog');
                        Navigator.pop(context);
                      }
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
                      removeImage();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ));
  }

  //remove image
  void removeImage() async {
    try {
      if (userCurrentImage != '') {
        FirebaseStorage.instance.refFromURL(userCurrentImage).delete();
        setState(() {
          userCurrentImage = '';
        });
        dynamic result = await _auth.userImageAdd(userCurrentImage);

        if (result == null) {
          Fluttertoast.showToast(msg: 'User image removed successfully.');
        } else {
          Fluttertoast.showToast(msg: 'Something went wrong..');
        }
      } else {
        Fluttertoast.showToast(msg: emptyImage);
        print(emptyImage);
      }
    } catch (e) {
      print(e.toString());
    }
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
        await uploadFile(image!);
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
      dynamic result = await _auth.userImageAdd(url);

      //removes the user image when a new image is uploaded
      if (userCurrentImage != '') {
        FirebaseStorage.instance.refFromURL(userCurrentImage).delete();
      }

      if (result == null) {
        Fluttertoast.showToast(msg: 'Image added successfully');
        manualRefresh();
      } else {

        Fluttertoast.showToast(msg: 'Image add error. Please try again.');
      }
    });
    return url;
  }

  //reading profile
  @override
  void initState() {
    super.initState();
    _auth.userItemRead().then((value) {
      data = value.data();
      setState(() {
        // balance = data!['balance'];
        userCurrentImage = data!['image'];
        print('Initial read userImage done #initState #profile.dart');
      });
    });
  }

  //manual refresh
  void manualRefresh() {
    _auth.userItemRead().then((value) {
      data = value.data();
      setState(() {
        userCurrentImage = data!['image'];
        print('Refresh userImage done #manualRefresh');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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

                //address
                // final List<Map<String, dynamic>> addressList =
                //     (userMap['address'] as List)
                //         .map((e) => e as Map<String, dynamic>)
                //         .toList();

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
                                foregroundImage: NetworkImage(userMap['image']),
                                radius: 50.0,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    Image.asset('assets/useravatar.png').image,
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
                                  Expanded(flex: 5, child: Text('Balance:')),
                                  Expanded(
                                      flex: 5,
                                      child: Text('RM ${userMap['balance']}')),
                                ],
                              ),
                              SizedBox(height: 15.0),
                              ElevatedButton.icon(
                                  onPressed: () {
                                    createReloadDialog(
                                        context, userMap['balance']);
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
                        //street stuffs
                        Card(
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(children: [
                              Expanded(
                                flex: 1,
                                child: Icon(Icons.edit_road),
                              ),
                              SizedBox(width: 10.0),
                              Expanded(
                                flex: 4,
                                child: Text('Street:'),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(userMap['street-name']),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    createEditStreetDialog(
                                        context, userMap['street-name']);
                                  },
                                ),
                              ),
                            ]),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        //city stuffs
                        Card(
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(children: [
                              Expanded(
                                flex: 1,
                                child: Icon(Icons.location_city),
                              ),
                              SizedBox(width: 10.0),
                              Expanded(
                                flex: 4,
                                child: Text('City:'),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(userMap['city']),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    createEditCityDialog(
                                        context, userMap['city']);
                                  },
                                ),
                              ),
                            ]),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        //state stuffs
                        Card(
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(children: [
                              Expanded(
                                flex: 1,
                                child: Icon(Icons.flag),
                              ),
                              SizedBox(width: 10.0),
                              Expanded(
                                flex: 4,
                                child: Text('State:'),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(userMap['state']),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    createEditStateDialog(
                                        context, userMap['state']);
                                  },
                                ),
                              ),
                            ]),
                          ),
                        ),
                        //postcode stuffs
                        Card(
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(children: [
                              Expanded(
                                flex: 1,
                                child: Icon(Icons.local_post_office),
                              ),
                              SizedBox(width: 10.0),
                              Expanded(
                                flex: 4,
                                child: Text('Post Code:'),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(userMap['postcode'].toString()),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    createEditPostCodeDialog(
                                        context, userMap['postcode']);
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
