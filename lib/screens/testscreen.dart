import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeproject/shared/auth.dart';
import 'package:coffeeproject/shared/constants.dart';
import 'package:coffeeproject/shared/loading.dart';
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
  String testName = 'a';
  double testPrice = 0.0;

  //loads balance whenever screen starts
  @override
  void initState() {
    super.initState();
    setState(() => loading = true);
    _auth.userItemRead().then((value) {
      data = value.data();
      setState(() {
        loading = false;
        balance = data!['balance'];
        print('Initial balance read done. #initState #testscreen.dart');
      });
    });
  }

  //perform manual refresh on balance
  void manualRefresh() {
    setState(() => loading = true);
    _auth.userItemRead().then((value) {
      data = value.data();
      setState(() {
        loading = false;
        balance = data!['balance'];
        print('Balance reload done. #manualRefresh #testScreen.dart');
      });
    });
  }

  //buy product
  void purchaseClick(String name, double price) async {
    setState(() => loading = true);
    dynamic result = await _auth.makeOrder(name, price);
    dynamic result2 = await _auth.userBalanceSubtract(balance, price);
    if (result == null && result2 == null) {
      setState(() => loading = false);
      manualRefresh();
      print('Purchased done. #purchaseClick #testScreen.dart');
    } else {
      print('Failed to purchase.');
      setState(() => loading = false);
    }
  }

  //delete product 
  void deleteClick(String docID) async 
  {
    setState(() => loading = true);
    dynamic result = await _auth.deleteProduct(docID);
    
    if(result == null)
    {
      setState(() => loading = false);
      print('Deleted successfully.');
    }
    else
    {
      setState(() => loading = false);
      print('Failed to delete.');
    }
  }

  //clear fields
  void clearFields() {
    setState(() {
      name.clear();
      price.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Products')
                .limit(12)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              return GridView.builder(
                physics: ScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                //controls how the items are distributed 
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemBuilder: (context, index) {

                  var abc = snapshot.data!.docs[index].get('Product');
                  var bcd = snapshot.data!.docs[index].get('Price');
                  var deletionID = snapshot.data!.docs[index].reference.id.toString();

                  return Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          purchaseClick(abc, bcd);
                        },
                        onLongPress: () async {
                          deleteClick(deletionID);
                        },
                        child: Card(
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 180.0,
                                width: 180.0,
                                child: Text(
                                    snapshot.data!.docs[index].get('Product')),
                              ),
                              Text(snapshot.data!.docs[index]
                                  .get('Price')
                                  .toString()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: loading
                ? Loading()
                : Form(
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
                              dynamic result = await _auth.addProduct(
                                  productName, productPrice);
                              if (result == null) {
                                setState(() => loading = false);
                                print('Added new product');
                                clearFields();
                              } else {
                                setState(() => loading = false);
                                print('Add new product failed');
                              }
                            }
                          },
                          child: Text('Create Product'),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}


// loading
//         ? Loading()
//         : Scaffold(
//             body: SingleChildScrollView(
//               child: Container(
//                 padding: EdgeInsets.all(15.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Products'),
//                     SizedBox(height: 15.0),
//                     Row(
//                       children: [
//                         Expanded(
//                           flex: 5,
//                           child: InkWell(
//                             onTap: () {
//                               purchaseClick();
//                             },
//                             child: Card(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(15.0)),
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     width: 150.0,
//                                     height: 150.0,
//                                     child: Center(
//                                       child: Text(
//                                         testName,
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     width: 50.0,
//                                     height: 50.0,
//                                     child: Center(child: Text('RM: $testPrice')),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 5,
//                           child: InkWell(
//                             onTap: () {
//                               purchaseClick();
//                             },
//                             child: Card(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(15.0)),
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     width: 150.0,
//                                     height: 150.0,
//                                     child: Center(
//                                       child: Text(
//                                         testName,
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     width: 50.0,
//                                     height: 50.0,
//                                     child: Center(child: Text('RM: $testPrice')),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 10.0),
//                     Form(
//                       key: _testKey,
//                       child: Column(
//                         children: [
//                           TextFormField(
//                             decoration: textFormFieldDecoration.copyWith(
//                                 hintText: 'Product Name'),
//                             validator: ((val) =>
//                                 val!.isEmpty ? 'Please enter something' : null),
//                             onChanged: ((val) {
//                               setState(() {
//                                 productName = val;
//                               });
//                             }),
//                           ),
//                           SizedBox(height: 15.0),
//                           TextFormField(
//                             inputFormatters: [
//                               // FilteringTextInputFormatter.digitsOnly
//                               FilteringTextInputFormatter.allow(
//                                   RegExp(r'^(\d+)?\.?\d{0,2}'))
//                             ],
//                             decoration: textFormFieldDecoration.copyWith(
//                                 hintText: 'Product Price'),
//                             validator: ((val) =>
//                                 val!.isEmpty ? 'Please enter price.' : null),
//                             onChanged: ((val) {
//                               setState(() {
//                                 productPrice = double.parse(val);
//                               });
//                             }),
//                           ),
//                           SizedBox(height: 15.0),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               ElevatedButton(
//                                 onPressed: () async {
//                                   if (_testKey.currentState!.validate()) {
//                                     // await _auth.makeOrder(productName, productPrice,
//                                     //     date, time, address, owner);
//                                     setState(() => loading = true);
//                                     dynamic result = await _auth.addProduct(
//                                         productName, productPrice);
//                                     if (result == null) {
//                                       setState(() => loading = false);
//                                       print('Added new product');
//                                     }
//                                     // dynamic result = await _auth.makeOrder(
//                                     //     productName, productPrice);
//                                     // dynamic result2 =
//                                     //     await _auth.userBalanceSubtract(
//                                     //         balance, productPrice);
//                                     // if (result == null && result2 == null) {
//                                     //   setState(() => loading = false);
//                                     // } else {
//                                     //   print('buy done');
//                                     //   setState(() => loading = false);
//                                     // }
//                                   }
//                                 },
//                                 child: Text('Create Product'),
//                               ),
//                               // SizedBox(width: 10.0),
//                               // ElevatedButton(
//                               //   child: Text('Delete'),
//                               //   onPressed: () async {
//                               //     await _auth.deleteFields(test, productName,
//                               //         productPrice.toString());
//                               //     print('delete done');
//                               //   },
//                               // ),
//                             ],
//                           ),
//                           // Expanded(
//                           //   child: ListView.builder(
//                           //       itemCount: test2.length,
//                           //       itemBuilder: (context, index) {
//                           //         return InkWell(
//                           //           onTap: () async {
//                           //             await _auth.deleteFields(test, productName,
//                           //                 productPrice.toString());
//                           //             print('delete done');
//                           //           },
//                           //           child: Card(
//                           //               child: ListTile(
//                           //             title: Text(test2[index]['ID']),
//                           //             // title: Text(test2[index]['Product']),
//                           //             subtitle: Text('Total Amount : ' +
//                           //                 test2[index]['Price']),
//                           //           )),
//                           //         );
//                           //       }),
//                           // ),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           );
