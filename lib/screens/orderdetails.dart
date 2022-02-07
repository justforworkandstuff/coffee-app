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
  String? imageKey;
  String? addressKey;

  //checkout one order
  void checkOutOneOrder(
    String id,
    String productName,
    double balance,
    double productPrice,
    String ordered,
    int quantity,
    String productID,
    bool shipped,
    String address,
    String image,
  ) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: (balance > productPrice)
                ? Text('Are you sure you want to check out this order?')
                : Text('You have insufficient balance.\nPlease reload first.'),
            actions: [
              (balance > productPrice)
                  ? MaterialButton(
                      child: Text('Confirm'),
                      onPressed: () async {
                        await _auth.cartCheckOutOne(
                            productID,
                            productName,
                            productPrice,
                            id,
                            quantity,
                            ordered,
                            address,
                            image);
                        Navigator.pop(context);
                        print(
                            'Checkout one order done. #checkOutOneOrder #orderDetails.dart');
                            Navigator.pop(context);
                      },
                    )
                  : MaterialButton(
                      onPressed: null,
                      child: Text('Confirm'),
                    ),
              MaterialButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  //cancel order
  void cancelOrder(
    String id,
    String productName,
    double balance,
    double productPrice,
    String ordered,
    int quantity,
    String productID,
    bool shipped,
    String address,
    String image,
  ) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Cancellation'),
            content: Text('Are you sure you want to cancel this order?'),
            actions: [
              MaterialButton(
                child: Text('Confirm'),
                onPressed: () async {
                  await _auth.deleteOrderFields(id, productName, productPrice,
                      ordered, quantity, productID, shipped, address, image);
                  Navigator.pop(context);
                  print('Cancel order done. #cancelOrder #orderDetails.dart');
                  Navigator.pop(context);
                },
              ),
              MaterialButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context)),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final selectedOrderData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    idKey = selectedOrderData['id'];
    priceKey = selectedOrderData['price'];
    productIDKey = selectedOrderData['product-ID'];
    productKey = selectedOrderData['product'];
    quantityKey = selectedOrderData['quantity'];
    createdAtKey = selectedOrderData['timestamp'];
    balanceKey = selectedOrderData['balance'];
    imageKey = selectedOrderData['image'];
    addressKey = selectedOrderData['address'];

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(title: Text('Order Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              //top box stuff
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
                              '$createdAtKey',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.0),
                  ],
                ),
              ),
              // bottom box stuff
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
                      'Receiving Address',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      children: [
                        Icon(Icons.location_pin),
                        SizedBox(width: 15.0),
                        Flexible(
                          child: Text(
                            '$addressKey',
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
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        //checkout one
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  checkOutOneOrder(
                    idKey!,
                    productKey!,
                    double.parse(balanceKey!),
                    double.parse(priceKey!),
                    createdAtKey!,
                    int.parse(quantityKey!),
                    productIDKey!,
                    false,
                    addressKey!,
                    imageKey!,
                  );
                },
                child: Text('Checkout This Order'),
              ),
            ),
          ],
        ),
        //cancel
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  cancelOrder(
                    idKey!,
                    productKey!,
                    double.parse(balanceKey!),
                    double.parse(priceKey!),
                    createdAtKey!,
                    int.parse(quantityKey!),
                    productIDKey!,
                    false,
                    addressKey!,
                    imageKey!,
                  );
                },
                child: Text('Cancel This Order'),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
