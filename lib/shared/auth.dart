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

  //subtracting balance for orders
  Future userBalanceSubtract(double balance, double price) async {
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
  Future userImageAdd(String image) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid).addImage(image);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //updating user phoneNo
  Future userPhoneUpdate(int phoneNo) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .updatePhoneNo(phoneNo);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //updating user address
  Future userAddressUpdate(String address) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .updateAddress(address);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////
  //// Orders
  ////////////////////////////////////////////////////////////////////////////////////

  //buying order items
  Future makeOrder(String productName, double productPrice, int quantity,
      String productID, bool shipped) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid).placeOrder(
          productName, productPrice, quantity, productID, shipped);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //read order fields
  Future readOrderFields() async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid).readOrder();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //delete order
  Future deleteOrderFields(
      String id,
      String productName,
      double productPrice,
      String ordered,
      int quantity,
      String productID,
      bool shipped,
      ) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid).deleteOrder(
          id,
          productName,
          productPrice,
          ordered,
          quantity,
          productID,
          shipped,
          );
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //received item
  Future receivedShipmentFields(bool shipped) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .receivedShipment(shipped);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //subtracts cartAmount after cancelling order
  Future cartAmountReturn(double productPrice) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .cartSubtraction(productPrice);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //checkout all cart orders and cart amount
  Future cartCheckOutAll(
      double cartAmount, List<Map<String, dynamic>> cartList) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .cartCheckOut(cartAmount, cartList);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  /////////////////////////////////////////////////////////////////////////////
  //Productsssssssssssssssssss
  /////////////////////////////////////////////////////////////////////////////

  //input new product
  Future addProduct(
      String productName, double productPrice, String image) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .newProduct(productName, productPrice, image);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //delete specific product
  Future deleteProduct(String docID) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .removeProduct(docID);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
