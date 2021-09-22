import 'package:coffeeproject/shared/auth.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _testKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  String newBalanceText = 'abcde';
  double balance = 0.0;
  Map<String, dynamic>? data;

  String productName = 'Bag abc';
  double productPrice = 99.00;
  String date = '13-03-99';
  String time = '13:30';
  String address = '101010, bbbbbb';
  String owner = 'ownerName';
  var test2;

  //reading profile
  @override
  void initState() {
    super.initState();
    _auth.userItemRead().then((value) {
      data = value.data();
      setState(() {
        owner = data!['userName'];
        balance = data!['balance'];

        //newBalanceText = 'New Balance: ${data!['balance']}';
        print('read users done');
      });
    });
    _auth.readFififi().then((value) {
      data = value.data();
      test2 = data!['orders'];
      setState(() {
        // List.from(value.data!['orders']).forEach((element) {
        //   data = value.data();
        //   test.add(data!);
        // });
        //secTestArray = testArray;
        //print(secTestArray);
        //test2 = data!['orders'];
        //test2 = data!['orders'].toString();
        // test2 = jsonEncode(test!['37af6b56-b1e6-4cfd-9087-05e8503deef5']);
        //print(test2);
      });
    });
    print('read orders done');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: _testKey,
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Text(productName),
                        Text('RM $productPrice'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15.0),
                // TextFormField(
                //   decoration: textFormFieldDecoration.copyWith(hintText: 'Item Price'),
                //   validator: (val) => val!.isEmpty ? 'Please enter a new price.' : null,
                //   onChanged: ((val) {
                //     setState(() {
                //       productPrice = double.parse(val.toString());
                //     });
                //   }),
                // ),
                ElevatedButton(
                  onPressed: () async {
                    if (_testKey.currentState!.validate()) {
                      await _auth.makeOrder(productName, productPrice, date,
                          time, address, owner);
                      await _auth.userBalanceSubtract(balance, productPrice);
                      print('buy done');
                    }
                  },
                  child: Text('Buy'),
                ),
                ElevatedButton(
                  child: Text('Delete'),
                  onPressed: () async {
                    // await _auth.userItemRead().then((value) {
                    //   data = value.data();
                    //   setState(() {
                    //     newBalanceText = 'New Balance: ${data!['balance']}';
                    //   });
                    // });
                    await _auth.deleteFiFi();
                    print('delete done');
                  },
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: test2.length,
                      itemBuilder: (context, index) {
                        return Card(
                            child: ListTile(
                          title: Text(test2[index]['Product']),
                          subtitle: Text(test2[index]['Price']),
                        ));
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
