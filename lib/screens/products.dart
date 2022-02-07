import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeproject/shared/auth.dart';
import 'package:coffeeproject/shared/loading.dart';
import 'package:flutter/material.dart';

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
  String address = '';

  //loads address whenever screen starts
  @override
  void initState() {
    super.initState();
    setState(() => loading = true);
    _auth.userItemRead().then((value) {
      data = value.data();
      setState(() {
        loading = false;
        address = '${data!['street-name']}, ${data!['city']}, ${data!['state']}, ${data!['postcode'].toString()}';
        print('Initial address read done. #initState #products.dart');
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Products')
          .snapshots(),
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

            final Map<String, String> productDetailsMap = {
              'image': imageData,
              'product': productData,
              'price': priceData.toString(),
              'inventory': inventoryData.toString(),
              'ID': productIDData,
              'address': address,
            };
            
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/productdetails', arguments: productDetailsMap);
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
                      Text(productData),
                      Text(priceData.toString()),
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