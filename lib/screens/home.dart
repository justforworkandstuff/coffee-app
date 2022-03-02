import 'package:coffeeproject/main.dart';
import 'package:coffeeproject/screens/homie.dart';
import 'package:coffeeproject/models/user.dart';
import 'package:coffeeproject/screens/orders.dart';
import 'package:coffeeproject/screens/products.dart';
import 'package:coffeeproject/shared/auth.dart';
import 'package:coffeeproject/shared/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  // final BottomNavigationBar btmNavBar =
  //     btmNavBarKey.currentWidget as BottomNavigationBar;

  int _selectedIndex = 0;
  List<Widget> _pageList = [
    HomePagie(),
    Products(),
    Orders(),
    Wrapper(),
  ];

  //bottom navigation bar items
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //final userStatus = Provider.of<CustomUser?>(context);

    return StreamProvider<CustomUser?>.value(
      initialData: null,
      value: _auth.streamUser,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Gigi Coffee'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _auth.userSignOut();
                // btmNavBar.onTap!(0);
              },
            )
          ],
        ),
        body: _pageList[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          key: btmNavBarKey,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.pink,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Products'),
            BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
