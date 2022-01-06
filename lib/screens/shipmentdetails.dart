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
  String? addressKey;
  String? imageKey;

  @override
  Widget build(BuildContext context) {
    final selectedShipmentData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    idKey = selectedShipmentData['id'];
    priceKey = selectedShipmentData['price'];
    productIDKey = selectedShipmentData['product-ID'];
    productKey = selectedShipmentData['product'];
    quantityKey = selectedShipmentData['quantity'];
    statusKey = selectedShipmentData['status'];
    orderedKey = selectedShipmentData['ordered'];
    addressKey = selectedShipmentData['address'];
    imageKey = selectedShipmentData['image'];

    //received order
    void receivedOrder(
        String productID,
        String productName,
        double productPrice,
        String id,
        int quantity,
        String ordered,
        String address) async {
      if (statusKey == 'true') {
        await _auth.receivedShipmentFields(productID, productName, productPrice,
            id, quantity, ordered, address);

        Navigator.pop(context);
        print('Received shipment done. #receivedOrder #shipmentdetails.dart');
      }
    }

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(title: Text('Shipment Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              //top box
              Container(
                margin: EdgeInsets.only(top: 20.0),
                padding: EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 3.0,
                            ),
                          ),
                          child: Image(
                            image: Image.network(imageKey!).image,
                            fit: BoxFit.fitHeight,
                            height: 80.0,
                          ),
                        ),
                        SizedBox(width: 15.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$productKey',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'RM',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Text(
                                  '$priceKey',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: 25.0,
                              ),
                              child: Text(
                                'Quantity: $quantityKey',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      children: [
                        Text(
                          'Order ID: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '$idKey',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.0),
                    Row(children: [
                      Text(
                        'Product ID: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$productIDKey',
                          ),
                        ),
                      ),
                    ]),
                    SizedBox(height: 15.0),
                    Row(
                      children: [
                        Text(
                          'Ordered At: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '$orderedKey',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      children: [
                        Text(
                          'Address: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '$addressKey',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.0),
                  ],
                ),
              ),
              // bottom box
              Container(
                margin: EdgeInsets.only(top: 20.0),
                padding: EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipment Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      children: [
                        Icon(Icons.local_shipping),
                        SizedBox(width: 15.0),
                        Flexible(
                          child: (statusKey == 'false')
                              ? Text(
                                  'Your shipment is currently still in-process. Please check back again later.',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : Text(
                                  'Your shipment has arrived. Please confirm after you have received your shipment.',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.0),
                  ],
                ),
              ),
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
                          addressKey!);
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
    );
  }
}
