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
  final _testKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  String newBalanceText = 'abcde';
  double balance = 0.0;
  Map<String, dynamic>? data;
  bool loading = false;

  String productName = 'Bag abc';
  double productPrice = 99.00;
  // String date = '13-03-99';
  // String time = '13:30';
  // String address = '101010, bbbbbb';
  // String owner = 'ownerName';
  var test2;
  var test;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceContoller = TextEditingController();

  //reading profile
  @override
  void initState() {
    super.initState();
    setState(() => loading = true);
    _auth.readFields().then((value) {
      data = value.data();
      test2 = data!['orders'];
      setState(() {
        test = test2![0]['ID'];
        loading = false; 
        print('read orders done');
      });
    });
  }

  void clearFields() {
    _testKey.currentState!.reset();
    nameController.clear();
    priceContoller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            body: Center(
              child: Container(
                padding: EdgeInsets.all(15.0),
                child: Form(
                  key: _testKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
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
                        controller: priceContoller,
                        inputFormatters: [
                          // FilteringTextInputFormatter.digitsOnly
                          FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (_testKey.currentState!.validate()) {
                                // await _auth.makeOrder(productName, productPrice,
                                //     date, time, address, owner);
                                setState(() => loading = true);
                                dynamic result = await _auth.makeOrder(
                                    productName, productPrice);
                                dynamic result2 = await _auth
                                    .userBalanceSubtract(balance, productPrice);
                                if (result == null && result2 == null) {
                                  setState(() => loading = false);
                                } else {
                                  print('buy done');
                                  clearFields();
                                  setState(() => loading = false);
                                }
                              }
                            },
                            child: Text('Buy'),
                          ),
                          SizedBox(width: 10.0),
                          ElevatedButton(
                            child: Text('Delete'),
                            onPressed: () async {
                              await _auth.deleteFields(
                                  test, productName, productPrice.toString());
                              print('delete done');
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: test2.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () async {
                                  await _auth.deleteFields(test, productName,
                                      productPrice.toString());
                                  print('delete done');
                                },
                                child: Card(
                                    child: ListTile(
                                  title: Text(test2[index]['ID']),
                                  // title: Text(test2[index]['Product']),
                                  subtitle: Text('Total Amount : ' +
                                      test2[index]['Price']),
                                )),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
