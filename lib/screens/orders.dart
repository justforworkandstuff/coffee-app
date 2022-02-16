import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeproject/main.dart';
import 'package:coffeeproject/models/user.dart';
import 'package:coffeeproject/shared/auth.dart';
import 'package:coffeeproject/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final AuthService _auth = AuthService();
  final BottomNavigationBar btmNavBar =
      btmNavBarKey.currentWidget as BottomNavigationBar;
  Map<String, dynamic>? data;
  var orderList;
  bool loading = false;
  bool isOrder = true;
  bool isShipped = false;
  String userAddress = '';
  int selectedIndex = 0;
  num balance = 0.0;
  Map<String, dynamic>? data2;
  Map<String, dynamic> ratingValue = {};

  //checkout stuff
  List<Map<String, dynamic>> checkOutCart = [];

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
        userAddress =
            '${data!['street-name']}, ${data!['city']}, ${data!['state']}, ${data!['postcode'].toString()}';
        print('Initial read balance and address done #initState #orders.dart');
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
        userAddress =
            '${data!['street-name']}, ${data!['city']}, ${data!['state']}, ${data!['postcode'].toString()}';
        print(
            'Manual refresh balance and address done #manualRefresh #orders.dart');
      });
    });
  }

  //checkout all orders
  void checkOut(BuildContext context, double cartAmount,
      List<Map<String, dynamic>> finalOrderList) async {
    await _auth.cartCheckOutAll(cartAmount, finalOrderList);
    print('Check out successful. #checkOut #orders.dart');
    Navigator.pop(context);
  }

  //confirm checkout dialog
  void confirmCheckOutDialog(BuildContext context, double cartAmount) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm'),
            content: Container(
              height: 200.0,
              child: Column(
                children: [
                  Center(
                    child: (cartAmount < balance)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your delivery address is:\n'),
                              InkWell(
                                onTap: () {
                                  btmNavBar.onTap!(3);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  '$userAddress >\n',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current balance: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('RM$balance'),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cart Amount: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('RM$cartAmount\n'),
                                ],
                              ),
                              Text('Are you sure you want to check out?'),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('You have insufficient balance.\n\n'),
                              InkWell(
                                onTap: () {
                                  btmNavBar.onTap!(3);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Go to reload balance >',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
                            ],
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              (cartAmount < balance)
                  ? MaterialButton(
                      child: Text('Confirm'),
                      onPressed: () {
                        checkOut(context, cartAmount, checkOutCart);
                        manualRefresh();
                      })
                  : MaterialButton(
                      onPressed: null,
                      child: Text('Confirm'),
                    ),
              MaterialButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  //update rating
  void updateRating(String productID,
      String productImage,
      String productName,
      double productPrice,
      String id,
      int quantity,
      String received,
      String address,
      double ratingAmt) async {
    await _auth.orderRatingUpdate(productID, productImage, productName, productPrice, id, quantity, received, address, ratingAmt);
    print('Rating updated successfully. #updateRating #orders.dart');
  }

  @override
  Widget build(BuildContext context) {
    var _user = Provider.of<CustomUser?>(context);

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
              } else {
                final DocumentSnapshot? dataSnapshot = snapshot.data;
                final Map<String, dynamic> dataMap =
                    dataSnapshot!.data() as Map<String, dynamic>;

                String crtAmt = dataSnapshot['cartAmount'].toStringAsFixed(2);
                double crtAmtConverted = double.parse(crtAmt);

                //orders
                final List<Map<String, dynamic>> orderList =
                    (dataMap['cart'] as List)
                        .map((value) => value as Map<String, dynamic>)
                        .toList();
                checkOutCart = orderList;

                //shipments
                final List<Map<String, dynamic>> shipmentList =
                    (dataMap['shipment'] as List)
                        .map((e) => e as Map<String, dynamic>)
                        .toList();

                //history
                final List<Map<String, dynamic>> historyList =
                    (dataMap['history'] as List)
                        .map((e) => e as Map<String, dynamic>)
                        .toList();

                return DefaultTabController(
                    length: 3,
                    child: Scaffold(
                      appBar: TabBar(
                        onTap: (int index) =>
                            setState(() => selectedIndex = index),
                        tabs: [
                          Tab(
                              icon: Icon(Icons.shopping_cart,
                                  color: Colors.black)),
                          Tab(
                              icon: Icon(Icons.local_shipping,
                                  color: Colors.black)),
                          Tab(icon: Icon(Icons.history, color: Colors.black)),
                        ],
                      ),
                      body: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TabBarView(
                          children: [
                            /// order tab /////////////////////////
                            Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 15.0),
                                  child: Text('Current Cart Amount: $crtAmt'),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: orderList.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.only(top: 10.0),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                final Map<String, String>
                                                    orderMap = {
                                                  'id': orderList[index]['ID'],
                                                  'price': orderList[index]
                                                      ['Price'],
                                                  'product-ID': orderList[index]
                                                      ['Product-ID'],
                                                  'product': orderList[index]
                                                      ['Product'],
                                                  'quantity': orderList[index]
                                                      ['Quantity'],
                                                  'timestamp': orderList[index]
                                                      ['Ordered'],
                                                  'balance': balance.toString(),
                                                  'image': orderList[index]
                                                      ['Product-Image'],
                                                  'address': userAddress,
                                                };
                                                Navigator.pushNamed(
                                                    context, '/orderdetails',
                                                    arguments: orderMap);
                                                // .then((_) => manualRefresh());
                                              },
                                              // listtile of each order
                                              child: Container(
                                                height: 80.0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        // image
                                                        Expanded(
                                                          flex: 2,
                                                          child: Container(
                                                            height: 70.0,
                                                            width: 70.0,
                                                            child: Image.network(
                                                                orderList[index]
                                                                    [
                                                                    'Product-Image']),
                                                          ),
                                                        ),
                                                        SizedBox(width: 15.0),
                                                        // name and price
                                                        Expanded(
                                                          flex: 4,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        orderList[index]
                                                                            [
                                                                            'Product'],
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              35.0),
                                                                      Text(orderList[
                                                                              index]
                                                                          [
                                                                          'Price']),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        // date time
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                              orderList[index]
                                                                  ['Ordered']),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                            //shipment tab ///////////////////////////////////////
                            ListView.builder(
                              itemCount: shipmentList.length,
                              itemBuilder: (context, index) {
                                isShipped = shipmentList[index]['Shipped'];

                                return Padding(
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        final Map<String, String> shipMap = {
                                          'id': shipmentList[index]['ID'],
                                          'price': shipmentList[index]['Price'],
                                          'product-ID': shipmentList[index]
                                              ['Product-ID'],
                                          'product': shipmentList[index]
                                              ['Product'],
                                          'quantity': shipmentList[index]
                                              ['Quantity'],
                                          'status': shipmentList[index]
                                                  ['Shipped']
                                              .toString(),
                                          'ordered': shipmentList[index]
                                              ['Ordered'],
                                          'address': userAddress,
                                          'image': shipmentList[index]
                                              ['Product-Image'],
                                        };
                                        Navigator.pushNamed(
                                            context, '/shipmentdetails',
                                            arguments: shipMap);
                                        // .then((_) => manualRefresh());
                                      },
                                      child: Container(
                                        height: 80.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    height: 70.0,
                                                    width: 70.0,
                                                    child: Image.network(
                                                        shipmentList[index]
                                                            ['Product-Image']),
                                                  ),
                                                ),
                                                SizedBox(width: 15.0),
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                shipmentList[
                                                                        index]
                                                                    ['Product'],
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 35.0),
                                                              Text(shipmentList[
                                                                      index]
                                                                  ['Price']),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: isShipped
                                                      ? Text(
                                                          'Status: Shipped',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      : Text(
                                                          'Status: Not shipped',
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            //history tab ///////////////////////////////////////
                            ListView.builder(
                              itemCount: historyList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        final Map<String, String> historyMap = {
                                          'id': historyList[index]['ID'],
                                          'price': historyList[index]['Price'],
                                          'product-ID': historyList[index]
                                              ['Product-ID'],
                                          'product': historyList[index]
                                              ['Product'],
                                          'quantity': historyList[index]
                                              ['Quantity'],
                                          'timestamp': historyList[index]
                                              ['Received'],
                                          'address': userAddress,
                                          'image': historyList[index]
                                              ['Product-Image'],
                                          'rating': historyList[index]['rating'].toString(), 
                                        };

                                        ratingValue = await Navigator.pushNamed(
                                                context, '/historydetails',
                                                arguments: historyMap) as Map<String, dynamic>;

                                        print(ratingValue['rating']);
                                        print(ratingValue['rated']);

                                        if(ratingValue['rated'] == true)
                                        {
                                          Fluttertoast.showToast(msg: 'You have rated the product!');
                                          updateRating(
                                            ratingValue['productID'],
                                            ratingValue['productImage'],
                                            ratingValue['productName'],
                                            double.parse(ratingValue['productPrice']),
                                            ratingValue['id'],
                                            int.parse(ratingValue['quantity']),
                                            ratingValue['received'],
                                            ratingValue['address'],
                                            ratingValue['rating'],
                                            );
                                        }
                                      },
                                      child: Container(
                                        height: 80.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    height: 70.0,
                                                    width: 70.0,
                                                    child: Image.network(
                                                        historyList[index]
                                                            ['Product-Image']),
                                                  ),
                                                ),
                                                SizedBox(width: 15.0),
                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                historyList[
                                                                        index]
                                                                    ['Product'],
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 35.0),
                                                              Text(historyList[
                                                                      index]
                                                                  ['Price']),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    'Received: ${historyList[index]['Received']}',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      bottomNavigationBar: selectedIndex == 0
                          ? Row(
                              children: [
                                Expanded(
                                  child: crtAmtConverted > 0.0
                                      ? ElevatedButton(
                                          onPressed: () {
                                            confirmCheckOutDialog(
                                                context, crtAmtConverted);
                                          },
                                          child: Text('Check Out All Orders'))
                                      : ElevatedButton(
                                          onPressed: null,
                                          child: Text('Check Out All Orders')),
                                ),
                              ],
                            )
                          : null,
                    ));
              }
            });
  }
}
