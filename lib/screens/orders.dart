import 'package:coffeeproject/reusables/ordercard.dart';
import 'package:coffeeproject/shared/auth.dart';
import 'package:coffeeproject/shared/loading.dart';
import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final AuthService _auth = AuthService();
  var items = ['Latest', 'Oldest'];
  String initialValue = 'Latest';
  double balance = 0.0;
  Map<String, dynamic>? data;
  var orderList;
  bool loading = false;

  DropdownMenuItem<String> orderMenu(String value) =>
      DropdownMenuItem(child: Text(value), value: value);

  @override
  void initState() {
    super.initState();
    setState(() => loading = true);
    _auth.readFields().then((value) {
      data = value.data();
      orderList = data!['orders'];
      setState(() {
        loading = false;
        print('Read orders done');
        // test2 = orderList![0]['ID'];
        // print(test2);
      });
    });
  }

  //manual refresh
  void manualRefresh() {
    setState(() => loading = true);
    _auth.readFields().then((value) {
      data = value.data();
      orderList = data!['orders'];
      setState(() {
        loading = false;
        print('Read orders done');
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return loading
        ? Loading()
        : Container(
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
                    flex: 6,
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    flex: 2,
                    child: IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () => manualRefresh(),
                    ),
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      onChanged: (newValue) {
                        setState(() => initialValue = newValue!);
                      },
                      value: initialValue,
                      items: items.map(orderMenu).toList(),
                      underline: Container(
                        height: 2,
                        color: Colors.pinkAccent,
                      ),
                    ),
                    flex: 2,
                  ),
                ]),
                SizedBox(height: 10.0),
                Divider(height: 10.0, color: Colors.black),
                Expanded(
                    child: ListView.builder(
                  itemCount: orderList.length,
                  itemBuilder: (context, index) {
                    return OrderCard(
                      id: orderList[index]['ID'],
                      orderAmount: orderList[index]['Price'],
                      productName: orderList[index]['Product'],
                    );
                    // return Card(
                    //     child: ListTile(
                    //   title: Text(test2[index]['ID']),
                    //   subtitle: Text('Total Amount : ' + test2[index]['Price']),
                    // ));
                  },
                ))
              ],
            ),
          );
  }
}
