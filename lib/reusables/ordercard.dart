import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  // final CustomUserData user;
  // final Order orderItem;
  // final int orderNo;
  final String id;
  final String orderAmount;
  final String productName;

  OrderCard(
      {required this.id, required this.orderAmount, required this.productName});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> testMap = {
      'id': id,
      'price': orderAmount,
      'product': productName,
    };

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Card(
        child: ListTile(
          onTap: () {
            Navigator.pushNamed(context, '/orderdetails', arguments: testMap);
          },
          title: Text('Order ID: \n\n $id'),
          // subtitle: Text('Total Amount : $orderAmount'),
        ),
      ),
    );
  }
}
