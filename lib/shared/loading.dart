import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitFadingCube(
              size: 50.0,
              color: Colors.black,
            ),
            SizedBox(height: 35.0),
            Text('User data pending...'),
          ],
        ),
      
    );
  }
}
