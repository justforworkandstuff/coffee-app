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
  String userAddress = '';
  int selectedIndex = 0;

  //sample details for product
  String sampleID = 'Sample-ID';
  String sampleProductID = 'Sample-Product-ID';
  String sampleProduct = 'Sample Product';
  String samplePrice = '0.0';
  String sampleQuantity = '0';
  String sampleTime = '01/01/0000';
  double balance = 0.0;
  String productImage = '';
  Map<String, dynamic>? data2;

  //checkout stuff
  List<Map<String, dynamic>> checkOutCart = [];

  DropdownMenuItem<String> orderMenu(String value) =>
      DropdownMenuItem(child: Text(value), value: value);

  //test getproductimage function
  Future readProductImage(String docID) async {
    await _auth.readProductImage(docID).then((value) {
      setState(() => productImage = value.data()['image']);
    });
  }

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
        userAddress = data!['address'];
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
        userAddress = data!['address'];
        print('Manual refresh balance done #manualRefresh #orders.dart');
      });
    });
  }

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
            content: Container(
              height: 100.0,
              child: Column(
                children: [
                  Center(
                    child: (cartAmount < balance)
                        ? Text(
                            'Your delivery address is: \n$userAddress\nAre you sure you want to check out?',
                            maxLines: 5,
                          )
                        : Text('You have insufficient balance.'),
                  ),
                  // Center(child: Text('Are you sure you want to check out?')),
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
                      onTap: (int index) {
                        setState(() => selectedIndex = index);
                      },
                      tabs: [
                        Tab(
                            icon:
                                Icon(Icons.shopping_cart, color: Colors.black)),
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
                          //order tab ///////////////////////////////////////
                          Column(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(top: 15.0),
                                  child: Text(
                                      'Current Cart Amount: ${dataSnapshot['cartAmount'].toString()}')),
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
                                        child: ListTile(
                                          onTap: () async {
                                            await readProductImage(
                                                orderList[index]['Product-ID']);
                                            final Map<String, String> orderMap =
                                                {
                                              'id': orderList[index]['ID'] ??
                                                  sampleID,
                                              'price': orderList[index]
                                                      ['Price'] ??
                                                  samplePrice,
                                              'product-ID': orderList[index]
                                                      ['Product-ID'] ??
                                                  sampleProductID,
                                              'product': orderList[index]
                                                      ['Product'] ??
                                                  sampleProduct,
                                              'quantity': orderList[index]
                                                      ['Quantity'] ??
                                                  sampleQuantity,
                                              'timestamp': orderList[index]
                                                      ['Ordered'] ??
                                                  sampleTime,
                                              'balance': balance.toString(),
                                              'image': productImage,
                                              'address': userAddress,
                                            };
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
                                ),
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
                                  child: ListTile(
                                      onTap: () async {
                                        await readProductImage(
                                            shipmentList[index]['Product-ID']);
                                        final Map<String, String> shipMap = {
                                          'id': shipmentList[index]['ID'] ??
                                              sampleID,
                                          'price': shipmentList[index]
                                                  ['Price'] ??
                                              samplePrice,
                                          'product-ID': shipmentList[index]
                                                  ['Product-ID'] ??
                                              sampleProductID,
                                          'product': shipmentList[index]
                                                  ['Product'] ??
                                              sampleProduct,
                                          'quantity': shipmentList[index]
                                                  ['Quantity'] ??
                                              sampleQuantity,
                                          'status': shipmentList[index]
                                                  ['Shipped']
                                              .toString(),
                                          'ordered': shipmentList[index]
                                              ['Ordered'],
                                          'address': userAddress,
                                          'image': productImage,
                                        };
                                        Navigator.pushNamed(
                                            context, '/shipmentdetails',
                                            arguments: shipMap);
                                        // .then((_) => manualRefresh());
                                      },
                                      title: Text(
                                          'Shipment ID: \n\n ${shipmentList[index]['ID']}\n'),
                                      subtitle: isShipped
                                          ? Text(
                                              'Status: Already shipped, please confirm.',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Text(
                                              'Status: Not shipped',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                            )),
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
                                  child: ListTile(
                                    onTap: () async {
                                      await readProductImage(
                                          historyList[index]['Product-ID']);
                                      final Map<String, String> historyMap = {
                                        'id': historyList[index]['ID'] ??
                                            sampleID,
                                        'price': historyList[index]['Price'] ??
                                            samplePrice,
                                        'product-ID': historyList[index]
                                                ['Product-ID'] ??
                                            sampleProductID,
                                        'product': historyList[index]
                                                ['Product'] ??
                                            sampleProduct,
                                        'quantity': historyList[index]
                                                ['Quantity'] ??
                                            sampleQuantity,
                                        'timestamp': historyList[index]
                                                ['Received'] ??
                                            sampleTime,
                                        'address': userAddress,
                                        'image': productImage,
                                      };

                                      Navigator.pushNamed(
                                          context, '/historydetails',
                                          arguments: historyMap);
                                      // .then((_) => manualRefresh());
                                    },
                                    title: Text(
                                        'History ID: \n\n ${historyList[index]['ID']}\n'),
                                    subtitle: Text(
                                      'Received: ${historyList[index]['Received']}',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
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
                                flex: 5,
                                child: dataSnapshot['cartAmount'] != 0.0
                                    ? ElevatedButton(
                                        onPressed: () {
                                          confirmDialog(context,
                                              dataSnapshot['cartAmount']);
                                        },
                                        child: Text('Check Out All Orders'))
                                    : ElevatedButton(
                                        onPressed: null,
                                        child: Text('Check Out All Orders')),
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              }
            },
          );
  }
}
