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

  String shipmentError = '';

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

    //received order
    void receivedOrder(bool shipped, bool received) async {
      if (statusKey == 'false') {
        setState(() => shipmentError = 'Error. The item is not shipped yet.');
        print('$shipmentError #shipmentdetails.dart');
      } else {
        await _auth.receivedShipmentFields(shipped);

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
                Text('Ordered Item Name : $productKey'),
                Text('Total amount : $priceKey'),
                Text('Quantity: $quantityKey'),
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
                Text(shipmentError,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                    )),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  receivedOrder(true, true);
                },
                child: Text('Confirm Received Shipment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
