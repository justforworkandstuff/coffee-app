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
  Future userRegister(String email, String password, int orders,
      String userName, int phoneNo, String image, String street, String city, String state, int postcode) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? customUser = result.user;

      double balance = double.parse(0.00.toStringAsFixed(2));
      await DatabaseService(uid: result.user!.uid)
          .newUserData(balance, orders, userName, phoneNo, image, street, city, state, postcode);
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
  // Future userBalanceSubtract(double balance, double price) async {
  //   try {
  //     return await DatabaseService(uid: _auth.currentUser!.uid)
  //         .minusBalance(balance, price);
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

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
  Future userPhoneUpdate(int? phoneNo) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .updatePhoneNo(phoneNo);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //updating user street
  Future userStreetUpdate(String? street) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .updateStreet(street);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //updating user State
  Future userStateUpdate(String? state) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .updateState(state);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //updating user city
  Future userCityUpdate(String? city) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .updateCity(city);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //updating user address
  Future userPostCodeUpdate(int? postcode) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .updatePostCode(postcode);
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
      String productID, bool shipped, String address, String image) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid).placeOrder(
          productName, productPrice, quantity, productID, shipped, address, image);
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
      String address,
      String image,
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
          address,
          image,
          );
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //received item
  Future receivedShipmentFields(String productID, String productName, double productPrice,
  String id, int quantity, String ordered, String address, String image) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .receivedShipment(productID, productName, productPrice, id, quantity, ordered, address, image);
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

}
