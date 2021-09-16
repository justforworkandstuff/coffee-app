import 'package:flutter/material.dart';

// ignore: must_be_immutable
class OrderCards extends StatelessWidget {
  String? img;
  String? text;

  OrderCards({required this.img, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 125.0,
      height: 125.0,
      child: Card(
        color: Colors.grey,
        elevation: 5.0,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image(
                  image: AssetImage('$img'),
                  fit: BoxFit.fill,
                ),
              ),
              // Expanded(
              //   child: ClipRRect(
              //       borderRadius: BorderRadius.circular(25.0),
              //       child: Image(image: AssetImage('$img'), fit: BoxFit.contain)),
              // ),
              SizedBox(height: 5.0),
              Text('$text'),
            ],
          ),
        ),
      ),
    );
  }
}
