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
  bool isOrder = true;
  bool isShipped = false;

  //menu bar
  int selectedIndex = 0;
  int theOtherMenu = 1;
  IconData? icon;
  String? text;

  //sample details for product
  String sampleID = 'Sample-ID';
  String sampleProductID = 'Sample-Product-ID';
  String sampleProduct = 'Sample Product';
  String samplePrice = '0.0';
  String sampleQuantity = '0';
  String sampleTime = '01/01/0000';
  double balance = 0.0;

  //checkout stuff
  List<Map<String, dynamic>> checkOutCart = [];

  DropdownMenuItem<String> orderMenu(String value) =>
      DropdownMenuItem(child: Text(value), value: value);

  //when clicked, swap to orders/shipping
  void showShipping() {
    setState(() => isOrder = !isOrder);
  }

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
  // void manualRefresh() {
  //   setState(() => loading = true);
  //   _auth.userItemRead().then((value) {
  //     data = value.data();
  //     setState(() {
  //       loading = false;
  //       balance = data!['balance'];
  //       print('Manual refresh balance done #manualRefresh #orders.dart');
  //     });
  //   });
  // }

  //checkout
  void checkOut(BuildContext context, double cartAmount,
      List<Map<String, dynamic>> finalOrderList) async {
    await _auth.cartCheckOutAll(cartAmount, finalOrderList);
    print('Check out successful.');
    Navigator.pop(context);
  }

  //confirm dialog
  void confirmDialog(BuildContext context, double cartAmount) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm'),
            content: Text('Are you sure you want to check out?'),
            actions: [
              MaterialButton(
                child: Text('Confirm'),
                onPressed: () => checkOut(context, cartAmount, checkOutCart),
              ),
              MaterialButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var _user = Provider.of<CustomUser?>(context);
    Size _size = MediaQuery.of(context).size;

    return loading
        ? Loading()
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Orders')
                .doc(_user!.userID + 'ORDERID')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              final DocumentSnapshot? dataSnapshot = snapshot.data;
              final Map<String, dynamic> dataMap =
                  dataSnapshot!.data() as Map<String, dynamic>;

              //orders
              final List<Map<String, dynamic>> orderList =
                  (dataMap['cart'] as List)
                      .map((value) => value as Map<String, dynamic>)
                      .toList();
              checkOutCart = orderList;
              print(checkOutCart[0]['Price']);

              //shipments
              final List<Map<String, dynamic>> shipmentList =
                  (dataMap['shipment'] as List)
                      .map((e) => e as Map<String, dynamic>)
                      .toList();

              // List<Widget> menuList = [
              //   CartItem(Icons.shopping_cart, 'Cart', orderList, balance),
              //   ShipItem(
              //       Icons.local_shipping, 'Shipment', shipmentList, isShipped),
              // ];

              return Scaffold(
                body: Container(
                  height: _size.height,
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //top menu stuffs
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: InkWell(
                              onTap: () {
                                setState(() => isOrder = true);
                              },
                              child: Container(
                                height: 50.0,
                                width: _size.width,
                                child: Container(
                                  height: 40.0,
                                  width: 120.0,
                                  decoration: BoxDecoration(
                                    color: Colors.pink,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(25.0),
                                      bottomRight: Radius.circular(25.0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.shopping_cart),
                                      SizedBox(width: 10.0),
                                      Text('Cart'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: InkWell(
                              onTap: () {
                                setState(() => isOrder = false);
                              },
                              child: Container(
                                height: 50.0,
                                width: _size.width,
                                child: Container(
                                  height: 40.0,
                                  width: 120.0,
                                  decoration: BoxDecoration(
                                    color: Colors.pink,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(25.0),
                                      bottomRight: Radius.circular(25.0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.local_shipping),
                                      SizedBox(width: 10.0),
                                      Text('Shipment'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      /*
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                icon: Icon(Icons.switch_camera),
                                onPressed: () => showShipping(),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: isOrder
                                  ? Text(
                                      'Orders',
                                      style: TextStyle(
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    )
                                  : Text(
                                      'Shipment',
                                      style: TextStyle(
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                            ),
                            Expanded(
                              flex: 4,
                              child: isOrder
                                  ? Text(
                                      'Cart Amount: ${dataSnapshot['cartAmount']}')
                                  : Text(''),
                            ),*/
                      //   ],
                      // ),

                      SizedBox(height: 10.0),
                      Divider(height: 10.0, color: Colors.black),

                      //order cards
                      Expanded(
                        child: isOrder
                            ? ListView.builder(
                                itemCount: orderList.length,
                                itemBuilder: (context, index) {
                                  final Map<String, String> orderMap = {
                                    'id': orderList[index]['ID'] ?? sampleID,
                                    'price': orderList[index]['Price'] ??
                                        samplePrice,
                                    'product-ID': orderList[index]
                                            ['Product-ID'] ??
                                        sampleProductID,
                                    'product': orderList[index]['Product'] ??
                                        sampleProduct,
                                    'quantity': orderList[index]['Quantity'] ??
                                        sampleQuantity,
                                    'timestamp': orderList[index]['Ordered'] ??
                                        sampleTime,
                                    'balance': balance.toString(),
                                  };

                                  return Padding(
                                    padding: EdgeInsets.only(top: 10.0),
                                    child: Card(
                                      child: ListTile(
                                        onTap: () async {
                                          Navigator.pushNamed(
                                                  context, '/orderdetails',
                                                  arguments: orderMap);
                                              // .then((_) => manualRefresh());
                                        },
                                        title: Text(
                                            'Order ID: \n\n ${orderList[index]['ID']}\n'),
                                        subtitle: Text(
                                            'Ordered: ${orderList[index]['Ordered']}'),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : ListView.builder(
                                itemCount: shipmentList.length,
                                itemBuilder: (context, index) {
                                  final Map<String, String> shipMap = {
                                    'id': shipmentList[index]['ID'] ?? sampleID,
                                    'price': shipmentList[index]['Price'] ??
                                        samplePrice,
                                    'product-ID': shipmentList[index]
                                            ['Product-ID'] ??
                                        sampleProductID,
                                    'product': shipmentList[index]['Product'] ??
                                        sampleProduct,
                                    'quantity': shipmentList[index]
                                            ['Quantity'] ??
                                        sampleQuantity,
                                    'status': shipmentList[index]['Shipped'].toString(),
                                  };

                                  isShipped = shipmentList[index]['Shipped'];

                                  return Padding(
                                    padding: EdgeInsets.only(top: 10.0),
                                    child: Card(
                                      child: ListTile(
                                          onTap: () async {
                                            Navigator.pushNamed(
                                                    context, '/shipmentdetails',
                                                    arguments: shipMap);
                                                // .then((_) => manualRefresh());
                                          },
                                          title: Text(
                                              'Shipment ID: \n\n ${shipmentList[index]['ID']}\n'),
                                          subtitle: isShipped
                                              ? Text(
                                                  'Shipped: Already shipped, please confirm.',
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              : Text(
                                                  'Shipped: Not shipped',
                                                  style: TextStyle(
                                                      color: Colors.red, 
                                                      fontWeight: FontWeight.bold),
                                                )),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: isOrder
                    ? Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: ElevatedButton(
                                onPressed: () {
                                  confirmDialog(
                                      context, dataSnapshot['cartAmount']);
                                },
                                child: Text('Check Out')),
                          ),
                        ],
                      )
                    : null,
              );
            },
          );
  }
}
