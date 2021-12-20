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
    String? timestampKey;

    final selectedHistoryData = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    idKey = selectedHistoryData['id'];
    priceKey = selectedHistoryData['price'];
    productIDKey = selectedHistoryData['product-ID'];
    productKey = selectedHistoryData['product'];
    quantityKey = selectedHistoryData['quantity'];
    timestampKey = selectedHistoryData['timestamp'];
    

    return Scaffold(
      appBar: AppBar(
        title: Text('History Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Past order ID: $idKey'),
            Text('Product ID: $productIDKey'),
            Text('Product: $productKey'),
            Text('Price: $priceKey'),
            Text('Quantity: $quantityKey'),
            Text('Received on: $timestampKey'),
          ],
        ),
      ),
    );
  }
}
