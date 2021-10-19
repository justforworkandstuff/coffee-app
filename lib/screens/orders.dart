import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeproject/reusables/ordercard.dart';
import 'package:coffeeproject/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  // final AuthService _auth = AuthService();
  final _user = FirebaseAuth.instance;
  Map<String, dynamic>? data;
  var orderList;
  bool loading = false;
  String sampleID = 'Sample-ID';
  String sampleProduct = 'Sample Product';
  String samplePrice = '0.0';
  String sampleTime = '01/01/0000';
  bool isSampleData = false;

  DropdownMenuItem<String> orderMenu(String value) =>
      DropdownMenuItem(child: Text(value), value: value);

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Orders')
                .doc(_user.currentUser!.uid + 'ORDERID')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              final DocumentSnapshot? something = snapshot.data;
              final Map<String, dynamic> abc =
                  something!.data() as Map<String, dynamic>;

              final List<Map<String, dynamic>> someList =
                  (abc['orders'] as List)
                      .map((value) => value as Map<String, dynamic>)
                      .toList();

              return Container(
                padding: EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(
                          'Orders',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ]),
                    SizedBox(height: 10.0),
                    Divider(height: 10.0, color: Colors.black),
                    Expanded(
                        child: ListView.builder(
                      itemCount: someList.length,
                      itemBuilder: (context, index) {
                        return OrderCard(
                                id: someList[index]['ID'] ?? sampleID,
                                orderAmount:
                                    someList[index]['Price'] ?? samplePrice,
                                productName:
                                    someList[index]['Product'] ?? sampleProduct,
                                createdAt:
                                    someList[index]['Timestamp'] ?? sampleTime,
                              );
                      },
                    ))
                  ],
                ),
              );
            },
          );
  }
}

// loading
//         ? Loading()
//         : Container(
//             padding: EdgeInsets.all(25.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(children: [
//                   Expanded(
//                     child: Text(
//                       'Orders',
//                       style: TextStyle(
//                         fontSize: 30.0,
//                         fontWeight: FontWeight.bold,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                     flex: 6,
//                   ),
//                   SizedBox(width: 10.0),
//                   Expanded(
//                     flex: 2,
//                     child: IconButton(
//                       icon: Icon(Icons.refresh),
//                       onPressed: () => manualRefresh(),
//                     ),
//                   ),
//                   Expanded(
//                     child: DropdownButton<String>(
//                       onChanged: (newValue) {
//                         setState(() => initialValue = newValue!);
//                       },
//                       value: initialValue,
//                       items: items.map(orderMenu).toList(),
//                       underline: Container(
//                         height: 2,
//                         color: Colors.pinkAccent,
//                       ),
//                     ),
//                     flex: 2,
//                   ),
//                 ]),
//                 SizedBox(height: 10.0),
//                 Divider(height: 10.0, color: Colors.black),
//                 Expanded(
//                     child: ListView.builder(
//                   itemCount: orderList.length,
//                   itemBuilder: (context, index) {
//                     return OrderCard(
//                       id: orderList[index]['ID'] ?? sampleID,
//                       orderAmount: orderList[index]['Price'] ?? samplePrice,
//                       productName: orderList[index]['Product'] ?? sampleProduct,
//                       createdAt: orderList[index]['Timestamp'] ?? sampleTime,
//                     );
//                   },
//                 ))
//               ],
//             ),
//           );