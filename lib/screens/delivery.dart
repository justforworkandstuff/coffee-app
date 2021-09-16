import 'package:flutter/material.dart';

class Delivery extends StatefulWidget {
  const Delivery({Key? key}) : super(key: key);

  @override
  _DeliveryState createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  TextEditingController _controller3 = TextEditingController();

  String? name;
  int? number;
  String? address;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery'),
      ),
        body: Container(
          padding: EdgeInsets.all(25.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                //name field
                TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: 'Name',),
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter your name.' : null,
                  onChanged: (val) {
                    setState(() {
                      name = val;
                    });
                  },
                ),
                SizedBox(height: 10.0),
                //contact number?
                TextFormField(
                  controller: _controller2,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(hintText: 'Number',),
                  validator: (val) => val!.isEmpty? 'Please enter your number.' : null, 
                  onChanged: (val) {
                    setState(() {
                      number = int.parse(val);
                    });
                  },
                ),
                SizedBox(height: 10.0),
                // address
                TextFormField(
                  controller: _controller3,
                  decoration: InputDecoration(hintText: 'Address'),
                  initialValue: null,
                  // decoration: textFormFieldDecoration.copyWith(hintText: 'Email'),
                  validator: (val) => val!.isEmpty ? 'Please enter your address.' : null,
                  onChanged: (val) {
                    setState(() {
                      address = val;
                    });
                  },
                ),
                SizedBox(height: 15.0),
                ElevatedButton(
                  onPressed: () {
                    if(_formKey.currentState!.validate())
                    {
                      setState(() {
                        print('order successfully.');
                        _controller.clear();
                        _controller2.clear();
                        _controller3.clear();
                        FocusScope.of(context).unfocus();
                      });
                    }
                  },
                  child: Text('Confirm'),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
