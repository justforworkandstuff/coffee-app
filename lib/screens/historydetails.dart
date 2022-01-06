import 'package:flutter/material.dart';

class HistoryDetails extends StatelessWidget {
  const HistoryDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    String? idKey;
    String? priceKey;
    String? productIDKey; 
    String? productKey;
    String? quantityKey;
    String? receivedTimeKey;
    String? addressKey;
    String? imageKey;

    final selectedHistoryData = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    idKey = selectedHistoryData['id'];
    priceKey = selectedHistoryData['price'];
    productIDKey = selectedHistoryData['product-ID'];
    productKey = selectedHistoryData['product'];
    quantityKey = selectedHistoryData['quantity'];
    receivedTimeKey = selectedHistoryData['timestamp'];
    addressKey = selectedHistoryData['address'];
    imageKey = selectedHistoryData['image'];
    

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Text('History Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Received At: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '$receivedTimeKey',
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
                      'Rate The Product',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      children: [
                        Text('Not available yet ')
                      ],
                    ),
                    SizedBox(height: 25.0),
                  ],
                ),
              ),
              // Text('Past order ID: $idKey'),
              // Text('Product ID: $productIDKey'),
              // Text('Product: $productKey'),
              // Text('Price: $priceKey'),
              // Text('Quantity: $quantityKey'),
              // Text('Received on: $timestampKey'),
            ],
          ),
        ),
      ),
    );
  }
}
