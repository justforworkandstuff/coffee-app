import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:coffeeproject/shared/auth.dart';
import 'package:coffeeproject/shared/constants.dart';
import 'package:coffeeproject/shared/loading.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  bool loading = false;
  Map<String, dynamic>? data;
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();

  //init state loading to get user balance
  double balance = 0.0;

  //dummy data for admin add new product
  String productName = 'Sample Product Name';
  double productPrice = 0.0;

  //catches the data loaded for the product stream
  // String testName = 'a';
  // double testPrice = 0.0;

  //uploads image
  File? image;
  String productImage = '';
  final FirebaseStorage storage = FirebaseStorage.instance;
  bool isEmpty = true;
  String url = '';

  // //loads balance whenever screen starts
  // @override
  // void initState() {
  //   super.initState();
  //   setState(() => loading = true);
  //   _auth.userItemRead().then((value) {
  //     data = value.data();
  //     setState(() {
  //       loading = false;
  //       balance = data!['balance'];
  //       print('Initial balance read done. #initState #testscreen.dart');
  //     });
  //   });
  // }

  // //perform manual refresh on balance
  // void manualRefresh() {
  //   setState(() => loading = true);
  //   _auth.userItemRead().then((value) {
  //     data = value.data();
  //     setState(() {
  //       loading = false;
  //       balance = data!['balance'];
  //       print('Balance reload done. #manualRefresh #testScreen.dart');
  //     });
  //   });
  // }

  // //buy product
  // void purchaseClick(String name, double price) async {
  //   setState(() => loading = true);
  //   dynamic result = await _auth.makeOrder(name, price);
  //   dynamic result2 = await _auth.userBalanceSubtract(balance, price);
  //   if (result == null && result2 == null) {
  //     setState(() => loading = false);
  //     // manualRefresh();
  //     print('Purchased done. #purchaseClick #testScreen.dart');
  //   } else {
  //     print('Failed to purchase.');
  //     setState(() => loading = false);
  //   }
  // }

  // //delete product
  // void deleteClick(String docID) async {
  //   setState(() => loading = true);
  //   dynamic result = await _auth.deleteProduct(docID);

  //   if (result == null) {
  //     setState(() => loading = false);
  //     print('Deleted successfully.');
  //   } else {
  //     setState(() => loading = false);
  //     print('Failed to delete.');
  //   }
  // }

  //clear fields
  void clearFields() {
    setState(() {
      name.clear();
      price.clear();
      isEmpty = true;
    });
  }

  // profile avatar selection dialog
  void showPickedOptionsDialog(BuildContext context) {
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
                      //removeImage();
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
          isEmpty = false;
        });
        // await uploadFile(image!);
      } else if (pickedImaged == null) return;
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  //uploading image to firebase storage
  Future uploadFile(File _theImage) async {
    setState(() => loading = true);
    if (image == null) return;

    final String fileName = basename(image!.path);
    Reference ref = storage
        .ref()
        .child('productImage/$fileName' + DateTime.now().toString());
    UploadTask uploadTask = ref.putFile(_theImage);

    String abc = await (await uploadTask).ref.getDownloadURL();
    setState(() => url = abc);
    // uploadTask.then((value) async {
    //   String abc = await value.ref.getDownloadURL();
    //   setState(() => url = abc);
    // });
    // uploadTask.whenComplete(() async {
    //   String abc = await ref.getDownloadURL();
    //   setState(() {
    //     url = abc;
    //   });
    //   // url = await (await uploadTask).ref.getDownloadURL();
    //   // dynamic result = await _auth.productImageAdd(url);

    //   // if (result == null) {
    //   //   setState(() => loading = false);
    //   //   Fluttertoast.showToast(msg: 'Image added successfully');
    //   //   // manualRefresh();
    //   // } else {
    //   //   setState(() => loading = false);
    //   //   Fluttertoast.showToast(msg: 'Image add error. Please try again.');
    //   // }
    // });
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: loading
            ? Loading()
            : Column(
                children: [
                  CircleAvatar(
                    radius: 55.0,
                    backgroundColor: Colors.green[300],
                    child: InkWell(
                      onTap: () {
                        showPickedOptionsDialog(context);
                      },
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundColor: Colors.white,
                        foregroundImage:
                            isEmpty ? null : Image.file(image!).image,
                        backgroundImage:
                            Image.asset('assets/useravatar.png').image,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: name,
                          decoration: textFormFieldDecoration.copyWith(
                              hintText: 'Product Name'),
                          validator: ((val) =>
                              val!.isEmpty ? 'Please enter something' : null),
                          onChanged: ((val) {
                            setState(() {
                              productName = val;
                            });
                          }),
                        ),
                        SizedBox(height: 15.0),
                        TextFormField(
                          controller: price,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^(\d+)?\.?\d{0,2}'))
                          ],
                          decoration: textFormFieldDecoration.copyWith(
                              hintText: 'Product Price'),
                          validator: ((val) =>
                              val!.isEmpty ? 'Please enter price.' : null),
                          onChanged: ((val) {
                            setState(() {
                              productPrice = double.parse(val);
                            });
                          }),
                        ),
                        SizedBox(height: 15.0),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => loading = true);
                              dynamic result = await uploadFile(image!);
                              dynamic result2 = await _auth.addProduct(
                                  productName, productPrice, url);
                              if (result == null && result2 == null) {
                                setState(() => loading = false);
                                print('Add new product failed');
                                clearFields();
                              } else {
                                setState(() => loading = false);
                                print('Added new product');
                                clearFields();
                              }
                            }
                          },
                          child: Text('Create Product'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// / StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('Products')
//                 .limit(12)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return CircularProgressIndicator();
//               }

//               return GridView.builder(
//                 shrinkWrap: true,
//                 physics: ScrollPhysics(),
//                 itemCount: snapshot.data!.docs.length,
//                 //controls how the items are distributed
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                 ),
//                 itemBuilder: (context, index) {

//                   var abc = snapshot.data!.docs[index].get('Product');
//                   var bcd = snapshot.data!.docs[index].get('Price');
//                   var deletionID = snapshot.data!.docs[index].reference.id.toString();

//                   return Column(
//                     children: [
//                       InkWell(
//                         onTap: () async {
//                           purchaseClick(abc, bcd);
//                         },
//                         onLongPress: () async {
//                           deleteClick(deletionID);
//                         },
//                         child: Card(
//                           elevation: 10.0,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0)),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 height: 180.0,
//                                 width: 180.0,
//                                 child: Text(
//                                     snapshot.data!.docs[index].get('Product')),
//                               ),
//                               Text(snapshot.data!.docs[index]
//                                   .get('Price')
//                                   .toString()),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//           ),
