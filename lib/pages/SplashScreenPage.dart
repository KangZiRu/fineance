import 'dart:async';

import 'package:fineance/globals/network.dart';
import 'package:fineance/pages/Home.dart';
import 'package:fineance/pages/LoginPage.dart';
import 'package:fineance/services/NetworkService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _SplashScreenPage();
  }
}


class _SplashScreenPage extends State<SplashScreenPage> {
  _SplashScreenPage() {
    init();
  }

  init() async {
    var prefs = await SharedPreferences.getInstance();
    
    if (prefs.containsKey("username") && prefs.containsKey("token")) {
      String username;
      String token;

      try {
        username = prefs.getString("username");
        token = prefs.getString("token");
      } catch (e) {
        prefs.remove("username");
        prefs.remove("token");
        init();
        return;
      }

      Map<String, dynamic> body = new Map();
      body["username"] = username;
      body["token"] = token;

      NetworkService.post(
        baseUrl + "/api/auth/relogin",
        body: body,
        success: (Map<String, dynamic> json) async {
          if (json["status"] as bool) {
            Timer(Duration(seconds: 1), () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
            });

            prefs.setString("token", json["token"]);
            return;
          }

          Timer(Duration(seconds: 3), () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
          });
        },
        error: (response) {
          debugPrint(response.body);
          Timer(Duration(seconds: 3), () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
          });
        }
      );
    } else {
      Timer(Duration(seconds: 3), () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(0, 0, 0, 0),
      statusBarIconBrightness: Brightness.dark
    ));
    
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            children: <Widget>[
              Image.asset("assets/images/logo.png", height: 60, width: 60),
              SizedBox(height: 16,),
              Text("FINEANCE", style: TextStyle(
                fontSize: 40,
              )),
              SizedBox(height: 20),
              Text("WELCOME", style: TextStyle(
                fontSize: 20,
              )),
            ],
            mainAxisAlignment: MainAxisAlignment.center
          )
        )
      )
    );
  }
}
