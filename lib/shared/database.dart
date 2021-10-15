import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeproject/models/user.dart';
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
        'productName': 'productName',
        'productPrice': 0.00,
        'date': 'date',
        'time': 'time',
        'address': 'address',
        'owner': 'owner',
        'orders': FieldValue.arrayUnion([
          {
            'Product': 'Product X',
            'Price': '0.00',
            'ID': 'TestID',
            'Timestamp': '',
          },
        ])
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
    return await userList.doc(uid).get();
  }

  //add user image
  Future userImageAdd(String image) async {
    return await userList.doc(uid).update({
      'image': image,
    });
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

  var uuid = Uuid();

  //buy items
  Future placeOrder(String productName, double productPrice) async {
    return await orderList.doc(uid + 'ORDERID').update({
      // '${uuid.v4()}': [{'Product': '$productName', 'Price': '$productPrice'}],
      // 'orders.${uuid.v4()}': FieldValue.arrayUnion([
      //   {'Product': '$productName', 'Price': '$productPrice'}
      //   ]),
      // 'orders.${uuid.v4()}': ['Product: $productName', 'Price: $productPrice'],
      // 'orders': [
      //   {'Product': '$productName', 'Price': '$productPrice', 'Date': DateTime.now()}
      // ],
      'orders': FieldValue.arrayUnion([
        {
          'Product': '$productName',
          'Price': '$productPrice',
          'ID': uuid.v4(),
          'Timestamp': DateTime.now().toString().substring(0, 16),
        }
      ]),
      // '${FieldValue.increment(0)}': [{'Product': '$productName', 'Price': '$productPrice'}],
    }).then((value) async {
      await userList.doc(uid).update({
        'orders': FieldValue.increment(1),
      });
    });
  }

  //read fields
  Future readFields() async {
    return await orderList.doc(uid + 'ORDERID').get();
  }

  //delete fields
  Future deleteFields(
      String id, String productName, String productPrice, String createdAt) async {
    return await orderList.doc(uid + 'ORDERID').update({
      // 'orders': FieldValue.delete(),
      'orders': FieldValue.arrayRemove([
        {
          'Product': productName,
          'Price': productPrice,
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

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  /// Products
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  //read products
  Future readProductList() async {
    return await productList.doc().get();
    // var result = await productList.get().then((value) {
    //   value.docs.forEach((element) {
    //     if (element.exists) {
    //           var abcd = element.data()['Product'];
    //           var bcdd = element.data()['Price'];
    //       // print(element.data()['Product']);
    //       // print(element.data()['Price']);
    //     }
    //   });
    // });
    // return result;
  }

  // admin input new product
  Future newProductList(String productName, double productPrice) async {
    return await productList
        .doc()
        .set({'Product': productName, 'Price': productPrice});
  }
}
