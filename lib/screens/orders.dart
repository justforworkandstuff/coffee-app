import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeproject/models/user.dart';
import 'package:coffeeproject/shared/auth.dart';
import 'package:coffeeproject/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final AuthService _auth = AuthService();
  Map<String, dynamic>? data;
  var orderList;
  bool loading = false;
  String sampleID = 'Sample-ID';
  String sampleProduct = 'Sample Product';
  String samplePrice = '0.0';
  String sampleTime = '01/01/0000';
  double balance = 0.0;

  DropdownMenuItem<String> orderMenu(String value) =>
      DropdownMenuItem(child: Text(value), value: value);

  //to get the balance of the user and pass to orderDetails
  @override
  void initState() {
    super.initState();
    setState(() => loading = true);
    _auth.userItemRead().then((value) {
      data = value.data();
      setState(() {
        loading = false;
        balance = data!['balance'];
        print('Initial read balance done #initState #orders.dart');
      });
    });
  }

  //manual refresh
  void manualRefresh() {
    setState(() => loading = true);
    _auth.userItemRead().then((value) {
      data = value.data();
      setState(() {
        loading = false;
        balance = data!['balance'];
        print('Manual refresh balance done #manualRefresh #orders.dart');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<CustomUser?>(context);

    return loading
        ? Loading()
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Orders')
                .doc(user!.userID + 'ORDERID')
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
                        flex: 6,
                        child: Text(
                          'Orders',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('Cart Amount: ${something['cartAmount']}'),
                      ),
                    ]),
                    SizedBox(height: 10.0),
                    Divider(height: 10.0, color: Colors.black),
                    Expanded(
                        child: ListView.builder(
                      itemCount: someList.length,
                      itemBuilder: (context, index) {

                        final Map<String, String> orderMap = {
                          'id': someList[index]['ID'] ?? sampleID,
                          'price': someList[index]['Price'] ?? samplePrice,
                          'product':  someList[index]['Product'] ?? sampleProduct,
                          'timestamp': someList[index]['Timestamp'] ?? sampleTime,
                          'balance': balance.toString(),
                        };

                        return Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Card(
                            child: ListTile(
                              onTap: () async {
                                Navigator.pushNamed(context, '/orderdetails',
                                    arguments: orderMap).then((_) => manualRefresh());
                              },
                              title: Text('Order ID: \n\n ${someList[index]['ID']}'),
                              subtitle: Text('Ordered: ${someList[index]['Timestamp']}'),
                            ),
                          ),
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

