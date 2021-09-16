import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeproject/models/order.dart';
import 'package:coffeeproject/models/user.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  //collection reference
  final CollectionReference userList =
      FirebaseFirestore.instance.collection('User');
  final CollectionReference orderList =
      FirebaseFirestore.instance.collection('Orders');
  
  //register new set of user
  Future newUserData(double balance, String address, int orders,
      String userName, int phoneNo, String image) async {
    return await userList.doc(uid).set({
      'balance': balance,
      'address': address,
      'orders': orders,
      'userName': userName,
      'phoneNo': phoneNo,
      'image': image,
    });
  }

  //update new balance #first method
  Future updateBalance(double balance, double reloadAmount) async {
    double newBalance = balance + reloadAmount;
    double abc = double.parse(newBalance.toStringAsFixed(2));

    return await userList.doc(uid).update({
      'balance': abc,
    });
  }

  //subtract balance
  Future minusBalance(double balance, double price) async {
    double newBalance = balance - price;
    double abcde = double.parse(newBalance.toStringAsFixed(2));

    return await userList.doc(uid).update({
      'balance': abcde,
    });
  }

  //reading user Lists
  Future readUsers() async {
    // return userList.doc(uid).snapshots().listen((event) => print(event.data()));
    return userList.doc(uid).get();
  }

  //add user image
  Future userImageAdd(String image) async
  {
    return userList.doc(uid).update({'image': image,});
  }

  //get stream listener for changes in user collection
  Stream<List<CustomUserData>> get streamListener {
    return userList.snapshots().map(_userListFromSnapshots);
  }

  //custom class model list to keep snapshots of stream listener
  List<CustomUserData> _userListFromSnapshots(QuerySnapshot value) {
    return value.docs.map((e) {
      return CustomUserData(balance: e.get('balance') ?? 0.0);
    }).toList();
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// Orders
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  //buy items
  Future placeOrder(String productName, double productPrice, String date,
      String time, String address, String owner) async {
        return await orderList.add({
          'productName': productName,
          'productPrice': productPrice,
          'date': date,
          'time': time,
          'address': address,
          'owner': owner,
        });
      }

  //reading order Lists
  Future readOrders() async {
    return orderList.doc().get();
  }

  //stream listener for changes in orders collection
  Stream<List<Order>> get orderListener {
    return orderList.snapshots().map(_orderListFromSnapshot);
  }

  // cutom class model for orders
  List<Order> _orderListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((value) {
      return Order(
        date: value.get('date'),
        time: value.get('time'),
        address: value.get('address'),
        productName: value.get('productName'),
        owner: value.get('owner'),
        productPrice: value.get('productPrice'),
      );
    }).toList();
  }
}
