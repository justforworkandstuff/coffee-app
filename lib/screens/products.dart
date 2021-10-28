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
  double balance = 0.0;

  //loads balance whenever screen starts
  @override
  void initState() {
    super.initState();
    setState(() => loading = true);
    _auth.userItemRead().then((value) {
      data = value.data();
      setState(() {
        loading = false;
        balance = data!['balance'];
        print('Initial balance read done. #initState #products.dart');
      });
    });
  }

  //perform manual refresh on balance
  void manualRefresh() {
    setState(() => loading = true);
    _auth.userItemRead().then((value) {
      data = value.data();
      setState(() {
        loading = false;
        balance = data!['balance'];
        print('Balance reload done. #manualRefresh #products.dart');
      });
    });
  }

  //buy product
  void purchaseClick(String name, double price) async {
    setState(() => loading = true);
    await _auth.makeOrder(name, price).whenComplete(() {
      setState(() => loading = false);
      manualRefresh();
      print('Purchased done. #purchaseClick #products.dart');
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
            String productData = snapshots.data!.docs[index].get('Product');
            double priceData = snapshots.data!.docs[index].get('Price');
            String imageData = snapshots.data!.docs[index].get('image');

            return Card(
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
                        image: NetworkImage(imageData),
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Text(productData),
                    Text(priceData.toString()),
                    ElevatedButton(
                        onPressed: () {
                          purchaseClick(productData, priceData);
                        },
                        child: Text('Add to Orders'))
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
