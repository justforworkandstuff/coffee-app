import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeproject/shared/auth.dart';
import 'package:coffeeproject/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final _auth = AuthService();
  bool loading = false;
  Map<String, dynamic>? data;

  //data to be loaded
  String productData = '';
  double priceData = 0;
  String imageData = '';
  int inventoryData = 0;
  String productIDData = '';
  String addressData = '';
  int ratingsData = 0;
  num productRatingData = 0.0;

  //loads address whenever screen starts
  @override
  void initState() {
    super.initState();
    setState(() => loading = true);
    _auth.userItemRead().then((value) {
      data = value.data();
      setState(() {
        loading = false;
        addressData =
            '${data!['street-name']}, ${data!['city']}, ${data!['state']}, ${data!['postcode'].toString()}';
        print('Initial address read done. #initState #products.dart');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('Products').snapshots(),
            builder: (context, snapshots) {
              if (!snapshots.hasData) {
                return CircularProgressIndicator();
              }

              return GridView.builder(
                itemCount: snapshots.data!.docs.length,
                //controls how the items are distributed
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemBuilder: (context, index) {
                  productData = snapshots.data!.docs[index].get('Product');
                  priceData = snapshots.data!.docs[index].get('Price');
                  imageData = snapshots.data!.docs[index].get('image');
                  inventoryData = snapshots.data!.docs[index].get('inventory');
                  productIDData = snapshots.data!.docs[index].id;
                  ratingsData = snapshots.data!.docs[index].get('ratings');
                  productRatingData =
                      snapshots.data!.docs[index].get('productRating');

                  final Map<String, String> productDetailsMap = {
                    'image': imageData,
                    'product': productData,
                    'price': priceData.toString(),
                    'inventory': inventoryData.toString(),
                    'ID': productIDData,
                    'address': addressData,
                    'ratings': ratingsData.toString(),
                    'productRating': productRatingData.toString(),
                  };

                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/productdetails',
                          arguments: productDetailsMap);
                      // .then((_) => manualRefresh());
                    },
                    child: Card(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Container(
                        width: 180.0,
                        height: 180.0,
                        child: Column(
                          children: [
                            Container(
                              width: 100.0,
                              height: 100.0,
                              child: Image(
                                alignment: Alignment.center,
                                image: NetworkImage(imageData),
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                            Text(
                              productData,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(priceData.toString()),
                            RatingBar.builder(
                              allowHalfRating: true,
                              itemSize: 30.0,
                              initialRating: productRatingData / ratingsData,
                              ignoreGestures: true,
                              onRatingUpdate: (double value) => null,
                              itemBuilder: (BuildContext context, int index) {
                                return Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                );
                              },
                            ),
                            Text('($ratingsData)'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
  }
}
