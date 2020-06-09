import 'package:fineance/pages/SplashScreenPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_state/global_state.dart';
// import 'package:fineance/pages/LoginPage.dart';
// import 'package:fineance/pages/TransactionPage.dart';
import 'package:fineance/stores/User.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() {
    store["user"] = new User();
  }
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Color.fromARGB(0, 0, 0, 0),
      statusBarIconBrightness: Brightness.light
    ));
    
    return MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(
        fontFamily: 'Exo2'
      ),
      home: SplashScreenPage()
    );
  }
}