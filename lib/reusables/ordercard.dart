import 'package:coffeeproject/models/order.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  // final CustomUserData user;
  final Order orderItem;
  final int orderNo;

  OrderCard({required this.orderItem, required this.orderNo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Card(
        child: ListTile(
          onTap: () {
            Navigator.pushNamed(context, '/orderdetails');
          },
          title: Text('Order $orderNo'),
          subtitle: Text('Product Price: ${orderItem.productPrice}'),
        ),
      ),
    );
  }
}
