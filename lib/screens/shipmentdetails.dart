import 'package:coffeeproject/shared/auth.dart';
import 'package:flutter/material.dart';

class ShipmentDetails extends StatefulWidget {
  const ShipmentDetails({Key? key}) : super(key: key);

  @override
  _ShipmentDetailsState createState() => _ShipmentDetailsState();
}

class _ShipmentDetailsState extends State<ShipmentDetails> {
  final AuthService _auth = AuthService();
  String? idKey;
  String? productIDKey;
  String? productKey;
  String? priceKey;
  String? quantityKey;
  String? shipmentKey;
  String? statusKey;
  String? orderedKey;


  @override
  Widget build(BuildContext context) {
    final todo =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    idKey = todo['id'];
    priceKey = todo['price'];
    productIDKey = todo['product-ID'];
    productKey = todo['product'];
    quantityKey = todo['quantity'];
    statusKey = todo['status'];
    orderedKey = todo['ordered'];

    //received order
    void receivedOrder(String productID, String productName,
        double productPrice, String id, int quantity, String ordered) async {
      if (statusKey == 'true') {
        await _auth.receivedShipmentFields(
            productID, productName, productPrice, id, quantity, ordered);

        Navigator.pop(context);
        print('Received shipment done. #receivedOrder #shipmentdetails.dart');
      }
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Shipment Details')),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SHIPMENT ID : $idKey'),
                Text('Product ID: $productIDKey'),
                Text('Ordered Item Name : $productKey'),
                Text('Total amount : $priceKey'),
                Text('Quantity: $quantityKey'),
                Text('Ordered: $orderedKey'),
                Text(
                    statusKey == 'true'
                        ? 'Shipped status: Already shipped, please confirm.'
                        : 'Shipped status: Not shipped.',
                    style: statusKey == 'true'
                        ? TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                          )
                        : TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                          )),
                SizedBox(height: 15.0),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Row(
          children: [
            Expanded(
              child: statusKey.toString() == 'true'
                  ? ElevatedButton(
                      onPressed: () async {
                        receivedOrder(
                          productIDKey!,
                          productKey!,
                          double.parse(priceKey!),
                          idKey!,
                          int.parse(quantityKey!),
                          orderedKey!,
                        );
                      },
                      child: Text('Confirm Received Shipment'),
                    )
                  : ElevatedButton(
                      onPressed: null,
                      child: Text('Confirm Received Shipment'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
