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
  String productData = '';
  double priceData = 0.0;
  String imageData = '';
  int inventoryData = 0;
  String productIDData = '';

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
            };
            
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/productdetails', arguments: productDetailsMap)
                .then((_) => manualRefresh());
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


// Container(
//                 padding: const EdgeInsets.symmetric(vertical: 15.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       height: 30.0,
//                       child: ListView.builder(
//                           scrollDirection: Axis.horizontal,
//                           itemCount: categories.length,
//                           itemBuilder: (context, index) {
//                             return GestureDetector(
//                               onTap: () {
//                                 setState(() => selectedIndex = index);  
//                               },
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 15.0),
//                                 child: Column(
//                                   children: [
//                                     Text(
//                                       categories[index],
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         color: selectedIndex == index ? Colors.black : Colors.grey,
//                                       ),
//                                     ),
//                                     Container(
//                                       height: 2.0,
//                                       width: 30.0,
//                                       color: selectedIndex == index ? Colors.black : Colors.transparent,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           }),
//                     ),