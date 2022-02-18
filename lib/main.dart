import 'package:coffeeproject/screens/historydetails.dart';
import 'package:coffeeproject/screens/home.dart';
import 'package:coffeeproject/screens/orderdetails.dart';
import 'package:coffeeproject/screens/productdetails.dart';
import 'package:coffeeproject/screens/shipmentdetails.dart';
import 'package:coffeeproject/screens/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

GlobalKey btmNavBarKey = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/home': (context) => const Home(),
        '/signin': (context) => const SignIn(),
        '/orderdetails': (context) => const OrderDetails(),
        '/productdetails': (context) => const ProductDetails(),
        '/shipmentdetails': (context) => const ShipmentDetails(),
        '/historydetails': (context) => const HistoryDetails(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Sample CoffeeApp Demo',
      home: Home(),
    );
  }
}
