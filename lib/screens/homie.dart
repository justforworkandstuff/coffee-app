import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeproject/shared/auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePagie extends StatefulWidget {
  const HomePagie({Key? key}) : super(key: key);

  @override
  _HomePagieState createState() => _HomePagieState();
}

class _HomePagieState extends State<HomePagie> {
  //variables
  int selectedIndex = 0;
  final carouselController = CarouselController();
  List<dynamic> sliderList = [];
  final _auth = AuthService();
  Map<String, dynamic>? data;
  late String address;

  Widget buildImageCard(String urlImage, int index, String product,
          int quantity, String productID, double price, String address) =>
      Container(
        color: Colors.grey,
        margin: EdgeInsets.symmetric(horizontal: 12.0),
        child: Card(
          child: InkWell(
            onTap: () {
              final Map<String, String> productDetailsMap = {
                'image': urlImage,
                'product': product,
                'price': price.toString(),
                'inventory': quantity.toString(),
                'ID': productID,
                'address': address
              };

              Navigator.pushNamed(context, '/productdetails',
                  arguments: productDetailsMap);
            },
            child: Card(
              child: Column(
                children: [
                  Expanded(
                    flex: 9,
                    child: Image(
                      image: NetworkImage(urlImage),
                      fit: BoxFit.fill,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('$product+$index'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

   //loads address whenever screen starts
  @override
  void initState() {
    super.initState();
    _auth.userItemRead().then((value) {
      data = value.data();
      setState(() {
        address = '${data!['street-name']}, ${data!['city']}, ${data!['state']}, ${data!['postcode'].toString()}';
        print('Initial address read done. #initState #homie.dart');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Products')
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        sliderList = snapshot.data!.docs.toList();

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('What\'s New'),
                SizedBox(height: 15.0),
                Column(
                  children: [
                    //carousel slider and buttons
                    Row(
                      children: [
                        //left button
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () => carouselController.previousPage(),
                            child: Icon(Icons.arrow_left),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: CarouselSlider.builder(
                            carouselController: carouselController,
                            itemCount: snapshot.data!.docs.length,
                            options: CarouselOptions(
                              height: 200.0,
                              autoPlay: true,
                              enlargeCenterPage: true,
                              viewportFraction: 1,
                              autoPlayInterval: Duration(seconds: 3),
                              onPageChanged: (index, reason) =>
                                  setState(() => selectedIndex = index),
                            ),
                            itemBuilder: (context, itemIndex, pageViewIndex) {
                              final image =
                                  snapshot.data!.docs[itemIndex].get('image');
                              final product =
                                  snapshot.data!.docs[itemIndex].get('Product');
                              final quantity = snapshot.data!.docs[itemIndex]
                                  .get('inventory');
                              final productID =
                                  snapshot.data!.docs[itemIndex].id;
                              final price =
                                  snapshot.data!.docs[itemIndex].get('Price');

                              return buildImageCard(image, itemIndex, product,
                                  quantity, productID, price, address);
                            },
                          ),
                        ),
                        //right button
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () => carouselController.nextPage(),
                            child: Icon(Icons.arrow_right),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.0),
                    //dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: sliderList.map(
                        (image) {
                          int index = sliderList.indexOf(image);
                          return InkWell(
                            onTap: () =>
                                carouselController.animateToPage(index),
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectedIndex == index
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 25.0),
                Text('Invite Friends'),
                SizedBox(height: 15.0),
                Container(
                  height: 150.0,
                  child: Card(
                    elevation: 5.0,
                    child: Image(
                      image: AssetImage('assets/invite.webp'),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
