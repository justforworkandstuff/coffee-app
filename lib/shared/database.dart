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
  Future newUserData(
      double balance,
      int orders,
      String userName,
      int phoneNo,
      String image,
      String street,
      String city,
      String state,
      int postcode) async {
    return await userList.doc(uid).set({
      'balance': balance,
      'orders': orders,
      'userName': userName,
      'phoneNo': phoneNo,
      'image': image,
      'orderID': uid + 'ORDERID',
      'street-name': street,
      'city': city,
      'state': state,
      'postcode': postcode
    }).then((value) async {
      String orderID = uid + 'ORDERID';
      await orderList.doc(orderID).set({
        'owner': uid,
        'cart': [],
        'shipment': [],
        'history': [],
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
  Future updatePhoneNo(int? phoneNo) async {
    return await userList.doc(uid).update({'phoneNo': phoneNo});
  }

  //update user street
  Future updateStreet(String? street) async {
    return await userList.doc(uid).update(
      {
        'street-name': street,
      },
    );
  }

  //update user state
  Future updateState(String? state) async {
    return await userList.doc(uid).update(
      {
        'state': state,
      },
    );
  }

  //update user city
  Future updateCity(String? city) async {
    return await userList.doc(uid).update(
      {
        'city': city,
      },
    );
  }

  //update user postcode
  Future updatePostCode(int? postcode) async {
    return await userList.doc(uid).update(
      {
        'postcode': postcode,
      },
    );
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

  //read order fields in orderList
  Future readOrder() async {
    return await orderList.doc(uid + 'ORDERID').get();
  }

  var uuid = Uuid();

  //place order
  Future placeOrder(
      String productName,
      double productPrice,
      int quantity,
      String productID,
      bool shipped,
      String address,
      String productImage) async {
    return await orderList
        .doc(uid + 'ORDERID')
        .update({
          'cart': FieldValue.arrayUnion([
            {
              'Product-ID': productID,
              'Product-Image': productImage,
              'Product': productName,
              'Price': productPrice.toStringAsFixed(2),
              'ID': uuid.v4(),
              'Quantity': quantity.toString(),
              'Ordered': DateTime.now().toString().substring(0, 16),
              'Shipped': shipped,
              'Address': address,
            }
          ]),
          'cartAmount': FieldValue.increment(
              double.parse(productPrice.toStringAsFixed(2))),
        })
        .whenComplete(() => productList.doc(productID).update({
              'inventory': FieldValue.increment(-quantity),
            }))
        .then((value) async {
          await userList.doc(uid).update({
            'orders': FieldValue.increment(1),
          });
        });
  }

  //delete single order field
  Future deleteOrder(
      String id,
      String productName,
      double productPrice,
      String ordered,
      int quantity,
      String productID,
      bool shipped,
      String address,
      String productImage) async {
    return await orderList
        .doc(uid + 'ORDERID')
        .update({
          'cart': FieldValue.arrayRemove([
            {
              'Product-ID': productID,
              'Product-Image': productImage,
              'Product': productName,
              'Price': productPrice.toStringAsFixed(2),
              'ID': id,
              'Quantity': quantity.toString(),
              'Ordered': ordered,
              'Shipped': shipped,
              'Address': address,
            }
          ]),
          'cartAmount': FieldValue.increment(
              -double.parse(productPrice.toStringAsFixed(2))),
        })
        .whenComplete(() => productList.doc(productID).update({
              'inventory': FieldValue.increment(quantity),
            }))
        .then((value) async {
          await userList.doc(uid).update({
            'orders': FieldValue.increment(-1),
          });
        });
  }

  //received item
  Future receivedShipment(
      String productID,
      String productName,
      double productPrice,
      String id,
      int quantity,
      String ordered,
      String address,
      String productImage) async {
    return await orderList.doc(uid + 'ORDERID').update({
      'history': FieldValue.arrayUnion([
        {
          'Product-ID': productID,
          'Product-Image': productImage,
          'Product': productName,
          'Price': productPrice.toStringAsFixed(2),
          'ID': id,
          'Quantity': quantity.toString(),
          'Received': DateTime.now().toString().substring(0, 16),
          'Address': address,
        }
      ]),
    }).then((value) async {
      await orderList.doc(uid + 'ORDERID').update({
        'shipment': FieldValue.arrayRemove([
          {
            'Product-ID': productID,
            'ID': id,
            'Ordered': ordered,
            'Price': productPrice.toStringAsFixed(2),
            'Product': productName,
            'Product-Image': productImage,
            'Quantity': quantity.toString(),
            'Shipped': true,
            'Address': address,
          }
        ]),
      });
    });
  }

  //check out all cart orders
  Future cartCheckOut(
      double cartAmount, List<Map<String, dynamic>> cartList) async {
    return await orderList.doc(uid + 'ORDERID').update({
      'cartAmount':
          FieldValue.increment(-double.parse(cartAmount.toStringAsFixed(2))),
      'cart': [],
      'shipment': FieldValue.arrayUnion(cartList),
    }).then((value) async {
      await userList.doc(uid).update({
        'balance':
            FieldValue.increment(-double.parse(cartAmount.toStringAsFixed(2))),
        'orders': 0,
      });
    });
  }

  //check out one cart order
  Future cartCheckOutOne(
      String productID,
      String productName,
      double productPrice,
      String id,
      int quantity,
      String ordered,
      String address,
      String productImage) async {
    return await orderList.doc(uid + 'ORDERID').update({
      'cartAmount':
          FieldValue.increment(-double.parse(productPrice.toStringAsFixed(2))),
      'cart': FieldValue.arrayRemove([
        {
          'Product-ID': productID,
          'Product-Image': productImage,
          'Product': productName,
          'Price': productPrice.toStringAsFixed(2),
          'ID': id,
          'Quantity': quantity.toString(),
          'Ordered': ordered,
          'Shipped': false,
          'Address': address,
        }
      ]),
      'shipment': FieldValue.arrayUnion([
        {
          'Product-ID': productID,
          'ID': id,
          'Ordered': ordered,
          'Price': productPrice.toStringAsFixed(2),
          'Product': productName,
          'Product-Image': productImage,
          'Quantity': quantity.toString(),
          'Shipped': false,
          'Address': address,
        }
      ]),
    }).then((value) async {
      await userList.doc(uid).update({
        'balance': FieldValue.increment(
            -double.parse(productPrice.toStringAsFixed(2))),
        'orders': FieldValue.increment(-1),
      });
    });
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// Products
  ////////////////////////////////////////////////////////////////////////////////////////////////////

}
