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
  String? productIDKey;
  String? productKey;
  String? priceKey;
  String? quantityKey;
  String? createdAtKey;
  String? balanceKey;

  //delete order
  void deleteOrder(
      String id,
      String productName,
      double balance,
      double productPrice,
      String ordered,
      int quantity,
      String productID,
      bool shipped,
      bool received, 
      ) async {
    await _auth.deleteOrderFields(
        id, productName, productPrice, ordered, quantity, productID, shipped);
    await _auth.cartAmountReturn(productPrice);

    Navigator.pop(context);
    print('Cancel order done. #deleteOrder #orderDetails.dart');
  }

  @override
  Widget build(BuildContext context) {
    final todo =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    idKey = todo['id'];
    priceKey = todo['price'];
    productIDKey = todo['product-ID'];
    productKey = todo['product'];
    quantityKey = todo['quantity'];
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
              Text('Quantity: $quantityKey'),
              Text('Ordered at: $createdAtKey'),
              ElevatedButton(
                onPressed: () async {
                  deleteOrder(
                      idKey!,
                      productKey!,
                      double.parse(balanceKey!),
                      double.parse(priceKey!),
                      createdAtKey!,
                      int.parse(quantityKey!),
                      productIDKey!,
                      false,
                      false,
                      );
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
