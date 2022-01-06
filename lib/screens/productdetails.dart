import 'package:coffeeproject/shared/auth.dart';
import 'package:flutter/material.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({Key? key}) : super(key: key);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final _auth = AuthService();

  //map data
  String? imageKey;
  String? productKey;
  String? priceKey;
  String? inventoryKey;
  String? productIDKey;
  String? addressKey;

  //quantity data
  int quantityCounter = 0;
  String quantityError = '';
  double totalAmount = 0.0;

  //buy product
  void purchaseClick(String name, double price, int quantity, String productID,
      bool shipped, bool received, String address) async {
    await _auth
        .makeOrder(name, price, quantity, productID, shipped, address)
        .whenComplete(() {
      print('Purchased done. #purchaseClick #productdetails.dart');
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final selectedProductData =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    imageKey = selectedProductData['image'];
    productKey = selectedProductData['product'];
    priceKey = selectedProductData['price'];
    inventoryKey = selectedProductData['inventory'];
    productIDKey = selectedProductData['ID'];
    addressKey = selectedProductData['address'];

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              //white box stuff
              Container(
                margin: EdgeInsets.only(top: size.height * 0.25),
                padding: EdgeInsets.only(
                  top: size.height * 0.12,
                  left: 15.0,
                  right: 15.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                // in box stuff
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Quantity:'),
                        SizedBox(width: 15.0),
                        // Text('${inventoryKey!}  in stock'),
                        (int.parse(inventoryKey!) <= 0)
                            ? Text(
                                inventoryKey!,
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              )
                            : Text(inventoryKey!),
                        SizedBox(width: 10.0),
                        Text(' in stock')
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            if (quantityCounter > 0) {
                              setState(() => quantityCounter--);
                            }
                          },
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          '$quantityCounter',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(width: 10.0),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            if (quantityCounter < int.parse(inventoryKey!)) {
                              setState(() => quantityCounter++);
                            }
                          },
                        ),
                      ],
                    ),
                    Text(
                      quantityError,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              //stuffs on top
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // product stuff
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      top: 10.0,
                    ),
                    child: Text(
                      productKey!,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                  // price stuff
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Price\n',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'RM ${priceKey!}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 15.0),
                      //image stuff
                      Expanded(
                        child: Image(
                          image: Image.network(imageKey!).image,
                          fit: BoxFit.fitHeight,
                          height: 150.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              child: Text('Add to Orders'),
              onPressed: () {
                if (quantityCounter > 0) {
                  totalAmount = double.parse(priceKey!) * quantityCounter;
                  purchaseClick(productKey!, totalAmount, quantityCounter,
                      productIDKey!, false, false, addressKey!);
                } else {
                  setState(
                      () => quantityError = 'You need to select a quantity.');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
