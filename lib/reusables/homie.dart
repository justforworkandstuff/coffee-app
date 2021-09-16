import 'package:coffeeproject/reusables/orderselection.dart';
import 'package:flutter/material.dart';

class HomePagie extends StatelessWidget {

  final Color color;

  HomePagie({required this.color});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: color,
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Order Now'),
            SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/signin');
                      // Navigator.pushReplacementNamed(context, '/signin');
                    },
                    child: OrderCards(img: 'assets/123.jpg', text: 'QR Order'),
                  ),
                ),
                Expanded(
                  child: OrderCards(img: 'assets/333.jpg', text: 'Pickup'),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/delivery');
                    },
                    child: OrderCards(img: 'assets/555.jpg', text: 'Delivery'),
                  ),
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
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(height: 25.0),
            Text('Whats New'),
            SizedBox(height: 15.0),
            Container(
              height: 150.0,
              child: Card(
                elevation: 5.0,
                child: Image(
                  image: AssetImage('assets/new.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
