import 'package:coffeeproject/shared/auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({Key? key}) : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final AuthService _auth = AuthService();
  bool isSampleDetails = false;
  String? idKey;
  String? productKey;
  String? priceKey;
  String? createdAtKey;

  //delete order
  void deleteOrder(String id, String productName, String productPrice,
      String createdAt) async {
    dynamic result =
        await _auth.deleteFields(id, productName, productPrice, createdAt);
    if (result == null) {
      Navigator.pop(context);
      print('Cancel order done.');
    } else {
      Fluttertoast.showToast(
          msg: 'Something went wrong. Order is not canceled');
      print('Can\'t cancel order.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final todo =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    idKey = todo['id'];
    priceKey = todo['price'];
    productKey = todo['product'];
    createdAtKey = todo['timestamp'];

    if (idKey == 'Sample-ID') {
      setState(() => isSampleDetails = true);
    }

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
                onPressed: isSampleDetails
                    ? null
                    : () async {
                        deleteOrder(
                            idKey!, productKey!, priceKey!, createdAtKey!);
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
