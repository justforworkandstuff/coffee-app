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

  //return balance after cancelling order
  Future userBalanceReturn(
      double balance, double price) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .returnBalance(balance, price);
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

  //updating user phoneNo
  Future userPhoneUpdate(int phoneNo) async
  {
    try
    {
      return await DatabaseService(uid: _auth.currentUser!.uid).updatePhoneNo(phoneNo);
    }
    catch(e)
    {
      print(e.toString());
      return null; 
    }
  }

  //updating user address
  Future userAddressUpdate(String address) async
  {
    try
    {
      return await DatabaseService(uid: _auth.currentUser!.uid).updateAddress(address);
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

  //buying order items
  Future makeOrder(String productName, double productPrice) async {
    try {
      return await DatabaseService(uid: _auth.currentUser!.uid)
          .placeOrder(productName, productPrice);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //read order fields
  Future readFields() async 
  {
    try
    {
      return await DatabaseService(uid: _auth.currentUser!.uid).readFields();
    }
    catch (e)
    {
      print(e.toString());
      return null;
    }
  }
  
  //delete fields
  Future deleteFields(String id, String productName, double productPrice, String createdAt) async
  {
    try
    {
      return await DatabaseService(uid: _auth.currentUser!.uid).deleteFields(
        id, productName, productPrice, createdAt);
    }
    catch(e)
    {
      print(e.toString());
      return null;
    }
  }

  /////////////////////////////////////////////////////////////////////////////
  //Productsssssssssssssssssss
  /////////////////////////////////////////////////////////////////////////////

  //input new product
  Future addProduct(String productName, double productPrice) async {
    try
    {
      return await DatabaseService(uid: _auth.currentUser!.uid).newProductList(productName, productPrice);
    }
    catch(e)
    {
      print(e.toString());
      return null;
    }
  }

  //delete specific product
  Future deleteProduct(String docID) async 
  {
    try
    {
      return await DatabaseService(uid: _auth.currentUser!.uid).removeProduct(docID);
    }
    catch(e)
    {
      print(e.toString());
      return null;
    }
  }
}
