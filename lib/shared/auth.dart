import 'package:coffeeproject/models/order.dart';
import 'package:coffeeproject/models/user.dart';
import 'package:coffeeproject/shared/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  //map Firebase User class to model User class
  CustomUser? _userFromFirebase(User? user) {
    return user != null ? CustomUser(userID: user.uid) : null;
  }

  // auth change user stream
  Stream<CustomUser?> get streamUser {
    return _auth.authStateChanges().map((_userFromFirebase));
    // .map((User? user) => _userFromFirebaseUser(user));
  }

  //sign in w/ email and pass
  Future userSignIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? customUser = result.user;

      return _userFromFirebase(customUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //register w/ email and pass
  Future userRegister(String email, String password, String address, int orders,
      String userName, int phoneNo, String image) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? customUser = result.user;

      double balance = double.parse(0.00.toStringAsFixed(2));
      await DatabaseService(uid: result.user!.uid)
          .newUserData(balance, address, orders, userName, phoneNo, image);
      return _userFromFirebase(customUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign out method
  Future userSignOut() async {
    try {
      if (_auth.currentUser != null) {
        return await _auth.signOut().then(
            (value) => Fluttertoast.showToast(msg: 'Sign out successfully'));
      } else {
        Fluttertoast.showToast(msg: 'You need to login first.');
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //adding balance
  Future userBalanceAdd(double balance, double reloadAmount) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .updateBalance(balance, reloadAmount);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //subtracting balance
  Future userBalanceSubtract(
      double balance, double price) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .minusBalance(balance, price);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //reading user items
  Future userItemRead() async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid).readUsers();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  
  //adding userImage
  Future userImageAdd(String image) async
  {
    try
    {
      return await DatabaseService(uid: _auth.currentUser!.uid).userImageAdd(image);
    }
    catch(e)
    {
      print(e.toString());
      return null;
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////
  //// Orders
  ////////////////////////////////////////////////////////////////////////////////////

  //map Firebase User class to model Order class
  Order? _orderFromFirebase(User? user) {
    return user != null
        ? Order(
            productName: '',
            productPrice: 0.0,
            date: '',
            time: '',
            address: '',
            owner: '',
          )
        : null;
  }

  // auth change user stream
  Stream<Order?> get streamOrder {
    return _auth.authStateChanges().map((_orderFromFirebase));
    // .map((User? user) => _userFromFirebaseUser(user));
  }

  //reading order items
  Future orderItemRead() async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid).readOrders();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //buying order items
  Future makeOrder(String productName, double productPrice, String date,
      String time, String address, String owner) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .placeOrder(productName, productPrice, date, time, address, owner);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
