import 'package:coffeeproject/models/user.dart';
import 'package:coffeeproject/screens/delivery.dart';
import 'package:coffeeproject/screens/home.dart';
import 'package:coffeeproject/screens/orderdetails.dart';
import 'package:coffeeproject/screens/signin.dart';
import 'package:coffeeproject/shared/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<CustomUser?>.value(
        initialData: null,
        value: AuthService().streamUser,
        child: MaterialApp(
          routes: {
            '/home': (context) => const Home(),
            '/delivery': (context) => const Delivery(),
            '/signin': (context) => const SignIn(),
            '/orderdetails': (context) => const OrderDetails(),
          },
          debugShowCheckedModeBanner: false,
          title: 'Sample CoffeeApp Demo',
          home: Home(),
        ));
  }
}
