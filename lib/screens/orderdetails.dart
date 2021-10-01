import 'package:coffeeproject/shared/auth.dart';
import 'package:flutter/material.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({Key? key}) : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final todo =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final idKey = todo['id'];
    final priceKey = todo['price'];
    final productKey = todo['product'];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Order Details')),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ORDER ID : ' + idKey!),
              Text('Ordered Item Name : ' + productKey!),
              Text('Total amount : ' + priceKey!),
              ElevatedButton(
                onPressed: () async {
                  _auth.deleteFields(idKey, productKey, priceKey);
                  Navigator.pop(context);
                  print('Cancel order done.');
                },
                child: Text('Cancel Order'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
