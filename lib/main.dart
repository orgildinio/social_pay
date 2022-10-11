import 'package:flutter/material.dart';
import 'package:social_pay/social_pay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    int payingloan;

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
      
        primarySwatch: Colors.blue,
      ),
      home: SocialPay(payloan: payingloan.toDouble(),),
    );
  }
}

