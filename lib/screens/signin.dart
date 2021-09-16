import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:coffeeproject/shared/auth.dart';
import 'package:coffeeproject/shared/constants.dart';
import 'package:coffeeproject/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  bool loading = false;
  String error = '';
  bool toggleSignIn = true;
  bool toggleRegister = false;

  String email = '';
  String password = '';
  String userName = '';
  String address = '';
  int orders = 0;
  int phoneNo = 000 - 0000000;
  File? image;
  FirebaseStorage storage = FirebaseStorage.instance;
  String userCurrentImage = '';
  // String screenTitle = 'Sign In';
  bool screenTitle = true;
  String screenText = '';

  //register/signin toggle
  void showRegister() {
    setState(() {
      screenTitle = !screenTitle;
      toggleSignIn = !toggleSignIn;
      toggleRegister = !toggleRegister;
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

  //clear all fields when pressed
  void clearFields() {
    setState(() {
      image = null;
      _formKey.currentState!.reset();
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
      _phoneController.clear();
      _addressController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
                title: Text(screenTitle == true
                    ? screenText = 'Sign In'
                    : screenText = 'Register')),
            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                child: Container(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Visibility(
                          visible: toggleRegister,
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
                                      : Image.asset('assets/useravatar.png')),
                            ),
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Visibility(
                          visible: toggleSignIn,
                          child: TextFormField(
                            controller: _emailController,
                            decoration: textFormFieldDecoration.copyWith(
                                hintText: 'Email'),
                            validator: (val) =>
                                val!.isEmpty ? 'Please enter a email' : null,
                            onChanged: ((val) {
                              setState(() {
                                email = val;
                              });
                            }),
                          ),
                        ),
                        Visibility(
                          visible: toggleRegister,
                          child: TextFormField(
                            controller: _emailController,
                            decoration: textFormFieldDecoration.copyWith(
                                hintText: 'Register your Email'),
                            validator: (val) =>
                                val!.isEmpty ? 'Please enter a email' : null,
                            onChanged: ((val) {
                              setState(() {
                                email = val;
                              });
                            }),
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Visibility(
                          visible: toggleSignIn,
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: textFormFieldDecoration.copyWith(
                                hintText: 'Password'),
                            validator: (val) => val!.length < 6
                                ? 'Please enter at least 6 characters'
                                : null,
                            obscureText: true,
                            onChanged: ((val) {
                              setState(() {
                                password = val;
                              });
                            }),
                          ),
                        ),
                        Visibility(
                          visible: toggleRegister,
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: textFormFieldDecoration.copyWith(
                                hintText: 'Register your password'),
                            validator: (val) => val!.length < 6
                                ? 'Please enter at least 6 characters'
                                : null,
                            obscureText: true,
                            onChanged: ((val) {
                              setState(() {
                                password = val;
                              });
                            }),
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Visibility(
                          visible: toggleRegister,
                          child: TextFormField(
                            controller: _nameController,
                            decoration: textFormFieldDecoration.copyWith(
                                hintText: 'Register your name.'),
                            validator: (val) =>
                                val!.isEmpty ? 'Please enter your name.' : null,
                            onChanged: ((val) {
                              setState(() {
                                userName = val;
                              });
                            }),
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Visibility(
                          visible: toggleRegister,
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: textFormFieldDecoration.copyWith(
                                hintText: 'Register your phone number.'),
                            validator: (val) => val!.isEmpty
                                ? 'Please enter your phone number.'
                                : null,
                            onChanged: ((val) {
                              setState(() {
                                phoneNo = int.parse(val.toString());
                              });
                            }),
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Visibility(
                          visible: toggleRegister,
                          child: TextFormField(
                            controller: _addressController,
                            decoration: textFormFieldDecoration.copyWith(
                                hintText: 'Register your address.'),
                            validator: (val) => val!.isEmpty
                                ? 'Please enter your address.'
                                : null,
                            onChanged: ((val) {
                              setState(() {
                                address = val;
                              });
                            }),
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Visibility(
                          visible: toggleSignIn,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => loading = true);
                                dynamic result =
                                    await _auth.userSignIn(email, password);
                                if (result == null) {
                                  setState(() {
                                    error = 'Please enter a valid email.';
                                    loading = false;
                                  });
                                } else {
                                  Fluttertoast.showToast(
                                    msg: 'Login succssfully.',
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                  setState(() => loading = false);
                                }
                              }
                            },
                            child: Text('Log in'),
                          ),
                        ),
                        Visibility(
                          visible: toggleRegister,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => loading = true);
                                dynamic result = await _auth.userRegister(
                                    email,
                                    password,
                                    address,
                                    orders,
                                    userName,
                                    phoneNo,
                                    '');
                                await uploadFile(image!);
                                if (result == null) {
                                  setState(() {
                                    error =
                                        'Please enter a valid email./Email has already been used!';
                                    loading = false;
                                  });
                                } else {
                                  Fluttertoast.showToast(
                                    msg: 'Register succssfully.',
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                  setState(() => loading = false);
                                }
                              }
                            },
                            child: Text('Register'),
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Visibility(
                          visible: toggleSignIn,
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.pushNamed(context, '/register');
                              showRegister();
                              clearFields();
                            },
                            child: RichText(
                              text: TextSpan(
                                text: 'Don\'t have an account yet? ',
                                style: TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                      text: 'Click here',
                                      style: TextStyle(
                                        color: Colors.blueAccent[700],
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: toggleRegister,
                          child: GestureDetector(
                            onTap: () {
                              showRegister();
                              clearFields();
                            },
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                      text: 'Click here',
                                      style: TextStyle(
                                        color: Colors.blue[400],
                                      )),
                                ],
                              ),
                            ),
                            // Text('Already have an account? Click here'),
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Text(
                          error,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
