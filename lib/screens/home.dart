import 'package:coffeeproject/reusables/homie.dart';
import 'package:coffeeproject/models/order.dart';
import 'package:coffeeproject/models/user.dart';
import 'package:coffeeproject/screens/orders.dart';
import 'package:coffeeproject/screens/testscreen.dart';
import 'package:coffeeproject/shared/auth.dart';
import 'package:coffeeproject/shared/database.dart';
import 'package:coffeeproject/shared/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();

  int _selectedIndex = 0;
  List<Widget> _pageList = [
    HomePagie(color: Colors.blue),
    Orders(),
    Wrapper(),
    TestScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userStatus = Provider.of<CustomUser?>(context);

    return StreamProvider<List<Order>?>.value(
      initialData: null,
      // value: AuthService().streamUser,
      value: DatabaseService(uid: userStatus!.userID).orderListener,
      child: Scaffold(
        // key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Gigi Coffee'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _auth.userSignOut();
              },
            )
          ],
        ),
        // body: IndexedStack(
        //   index: _selectedIndex,
        //   children: _pageList,
        // ),
        body: _pageList[_selectedIndex],
        // body: ListView.builder(
        //   itemCount: _pageList.length,
        //   itemBuilder: (context, index) {
        //     return OrderCard();
        //   },
        // ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.pink,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Test'),
          ],
        ),
      ),
    );
  }
}
