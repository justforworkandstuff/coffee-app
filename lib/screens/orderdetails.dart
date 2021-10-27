import 'package:coffeeproject/shared/auth.dart';
import 'package:flutter/material.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({Key? key}) : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final AuthService _auth = AuthService();
  String? idKey;
  String? productKey;
  String? priceKey;
  String? createdAtKey;
  String? balanceKey;

  //delete order
  void deleteOrder(String id, String productName, double balance,
      double productPrice, String createdAt) async {
    await _auth.deleteOrderFields(id, productName, productPrice, createdAt);
    await _auth.cartAmountReturn(productPrice);

    Navigator.pop(context);
    print('Cancel order done. #deleteOrder #orderDetails.dart');
    // if (result == null && result2 == null) {
    //   Navigator.pop(context);
    //   print('Cancel order done.');
    // } else {
    //   Fluttertoast.showToast(
    //       msg: 'Something went wrong. Order is not canceled');
    //   print('Can\'t cancel order.');
    // }
  }

  @override
  Widget build(BuildContext context) {
    final todo =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    idKey = todo['id'];
    priceKey = todo['price'];
    productKey = todo['product'];
    createdAtKey = todo['timestamp'];
    balanceKey = todo['balance'];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Order Details')),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ORDER ID : $idKey'),
              Text('Ordered Item Name : $productKey'),
              Text('Total amount : $priceKey'),
              Text('Ordered at: $createdAtKey'),
              ElevatedButton(
                onPressed: () async {
                  deleteOrder(idKey!, productKey!, double.parse(balanceKey!),
                      double.parse(priceKey!), createdAtKey!);
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
