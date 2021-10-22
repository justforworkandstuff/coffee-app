import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  // final CustomUserData user;
  // final Order orderItem;
  // final int orderNo;
  final String id;
  final String orderAmount;
  final String productName;
  final String createdAt;
  final double balance;

  OrderCard(
      {required this.id, required this.orderAmount, required this.productName, required this.createdAt, required this.balance});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> orderMap = {
      'id': id,
      'price': orderAmount,
      'product': productName,
      'timestamp': createdAt,
      'balance': balance.toString(),
    };

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Card(
        child: ListTile(
          onTap: () {
            Navigator.pushNamed(context, '/orderdetails', arguments: orderMap);
          },
          title: Text('Order ID: \n\n $id'),
          subtitle: Text('Ordered: $createdAt'),
          // subtitle: Text('Total Amount : $orderAmount'),
        ),
      ),
    );
  }
}
