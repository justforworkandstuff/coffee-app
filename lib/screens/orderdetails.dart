import 'package:flutter/material.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({Key? key}) : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Order Details')),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12.0),
                        title: Text('Product Name $index'),
                        trailing: Text('Image'),
                        subtitle: Text('Product Price\nDate Time'),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
