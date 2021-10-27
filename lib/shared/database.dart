import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  //collection reference
  final userList = FirebaseFirestore.instance.collection('User');
  final orderList = FirebaseFirestore.instance.collection('Orders');
  final productList = FirebaseFirestore.instance.collection('Products');

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
      'orderID': uid + 'ORDERID',
    }).then((value) async {
      String orderID = uid + 'ORDERID';
      await orderList.doc(orderID).set({
        'owner': uid,
        'orders': [],
        'cartAmount': 0.0
      });
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

  //update user Phone No
  Future updatePhoneNo(int phoneNo) async
  {
    return await userList.doc(uid).update({
      'phoneNo': phoneNo
    });
  }

  //update user address 
  Future updateAddress(String address) async
  {
    return await userList.doc(uid).update({
      'address': address
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
    return await userList.doc(uid).get();
  }

  //add user image
  Future addImage(String image) async {
    return await userList.doc(uid).update({
      'image': image,
    });
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// Orders
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  var uuid = Uuid();

  //buy items
  Future placeOrder(String productName, double productPrice) async {
    return await orderList.doc(uid + 'ORDERID').update({
      'orders': FieldValue.arrayUnion([
        {
          'Product': '$productName',
          'Price': '$productPrice',
          'ID': uuid.v4(),
          'Timestamp': DateTime.now().toString().substring(0, 16),
        }
      ]),
      'cartAmount': FieldValue.increment(productPrice),
    }).then((value) async {
      await userList.doc(uid).update({
        'orders': FieldValue.increment(1),
      });
    });
  }

  //read fields
  Future readOrder() async {
    return await orderList.doc(uid + 'ORDERID').get();
  }

  //delete fields
  Future deleteOrder(String id, String productName, double productPrice,
      String createdAt) async {
    return await orderList.doc(uid + 'ORDERID').update({
      'orders': FieldValue.arrayRemove([
        {
          'Product': productName,
          'Price': productPrice.toString(),
          'ID': id,
          'Timestamp': createdAt,
        }
      ]),
    }).then((value) async {
      await userList.doc(uid).update({
        'orders': FieldValue.increment(-1),
      });
    });
  }

  //return cartAmount afer cancelling orders
  Future cartSubtraction(double productPrice) async {
    return await orderList.doc(uid + 'ORDERID').update({
      'cartAmount': FieldValue.increment(-productPrice),
    });
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// Products
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  // admin input new product
  Future newProduct(String productName, double productPrice, String image) async {
    return await productList
        .doc()
        .set({'Product': productName, 'Price': productPrice,'image': image});
  }

  //admin delete specific product 
  Future removeProduct(String docID) async
  {
    return await productList.doc(docID).delete();
  }
}
