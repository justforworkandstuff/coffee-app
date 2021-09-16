import 'package:coffeeproject/models/order.dart';
import 'package:coffeeproject/reusables/ordercard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  //final AuthService _auth = AuthService();
  var items = ['Latest', 'Oldest'];
  String initialValue = 'Latest';
  double balance = 0.0;

  DropdownMenuItem<String> tester(String value) =>
      DropdownMenuItem(child: Text(value), value: value);

  // void readData()
  // {
  //   _auth.orderItemRead();
  // }

  @override
  Widget build(BuildContext context) {
    final docsList = Provider.of<List<Order>?>(context);

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
              flex: 8,
            ),
            Expanded(
              child: DropdownButton<String>(
                onChanged: (newValue) {
                  setState(() => initialValue = newValue!);
                },
                value: initialValue,
                items: items.map(tester).toList(),
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
                  itemCount: docsList!.length,
                  itemBuilder: (context, index) {
                    return OrderCard(
                      orderNo: index + 1,
                      orderItem: docsList[index],
                    );
                  })),
        ],
      ),
    );
  }
}
