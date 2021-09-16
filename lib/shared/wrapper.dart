import 'package:coffeeproject/models/user.dart';
import 'package:coffeeproject/screens/profile.dart';
import 'package:coffeeproject/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final userStatus = Provider.of<CustomUser?>(context);

    if(userStatus == null)
    {
      return SignIn();
    }
    else
    {
      return Profile();
    }

  }
}