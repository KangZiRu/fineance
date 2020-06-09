import 'package:fineance/pages/SignupPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fineance/globals/colors.dart';
import 'package:fineance/globals/network.dart';
import 'package:fineance/models/LoginResponse.dart';
import 'package:fineance/services/NetworkService.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';


class LoginPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  var userIdController = new TextEditingController();
  var passwordController = new TextEditingController();
  String userIdError;
  String passwordError;
  bool isKeyboardVisible;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    isKeyboardVisible = KeyboardVisibilityNotification().isKeyboardVisible;

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() {
          isKeyboardVisible = visible;
        });
        debugPrint("Keyboard state" + visible.toString());
      }
    );
  }
  
  onSubmit() async {
    if (userIdController.text.isEmpty) {
      setState(() {
        userIdError = "User ID cannot be empty!";
      });
      return;
    }
    
    Map<String, dynamic> body = new Map();
    body["userid"] = userIdController.text;
    body["password"] = passwordController.text;

    setState(() {
      isLoading = true;
    });
    
    NetworkService.post(
      baseUrl + "/api/auth/login",
      body: body,
      always: (bool isSuccess) {
        setState(() {
          isLoading = false;
          if (!isSuccess) {
            userIdError = null;
            passwordError = null;
          }
        });
      },
      success: (Map<String, dynamic> json) async {
        LoginResponse res = LoginResponse.fromJson(json);

        if (!res.status) {
          setState(() {
            if (res.message.startsWith("User")) {
              userIdError = res.message;
              passwordError = null;
            } else {
              passwordError = res.message;
              userIdError = null;
            }
          });
          
          return;
        }
        
        var prefs = await SharedPreferences.getInstance();
        prefs.setString("username", res.username);
        prefs.setString("token", res.token);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    );
  }
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(0, 0, 0, 0),
      statusBarIconBrightness: Brightness.dark
    ));
    
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.only(
                  right: 15,
                  bottom: 40
                ),
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Image.asset("assets/images/logo.png", height: 60, width: 60),
                    SizedBox(height: 16,),
                    isKeyboardVisible
                      ? Column(children: <Widget>[
                          Text("FINEANCE", style: TextStyle(
                            fontSize: 24,
                          )),
                          Text("WELCOME", style: TextStyle(
                            fontSize: 12,
                          ))
                        ])
                      : Column(children: <Widget>[
                          Text("FINEANCE", style: TextStyle(
                            fontSize: 40,
                          )),
                          SizedBox(height: 20),
                          Text("WELCOME", style: TextStyle(
                            fontSize: 20,
                          )),
                        ]),
                  ],
                  mainAxisAlignment: MainAxisAlignment.end
                ),
                alignment: Alignment(0, 0),
              )
            ),
            flex: 2
          ),
          Expanded(child: Center(child: Container(
            color: FineanceColor.matBlue700,
            child: Stack(children: <Widget>[
              (
                isLoading
                  ? Positioned(
                    top: 0,
                    left: (MediaQuery.of(context).size.width / 2) - 55,
                    child: CircularProgressIndicator()
                  )
                  : Container()
              ),
              Column(children: <Widget>[
                SizedBox(height: isKeyboardVisible ? 0 : 80),
                TextField(
                  controller: userIdController,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: new BorderSide(color: Color.fromARGB(100, 255, 255, 255))
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: new BorderSide(color: Colors.white)
                    ),
                    fillColor: Colors.white,
                    hintText: "username",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(120, 255, 255, 255)
                    ),
                    errorText: userIdError
                  ),
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  
                ),
                SizedBox(height: userIdError == null ? 20 : 0),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: new BorderSide(color: Color.fromARGB(100, 255, 255, 255))
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: new BorderSide(color: Colors.white)
                    ),
                    fillColor: Colors.white,
                    hintText: "password",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(120, 255, 255, 255)
                    ),
                    errorText: passwordError
                  ),
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: passwordError == null ? 50 : 30),
                ButtonTheme(
                  minWidth: 500,
                  child: RaisedButton(
                    child: Text("LOGIN", style: TextStyle(color: FineanceColor.matBlue700)),
                    onPressed: onSubmit,
                    color: Colors.white,
                    elevation: 0,
                  )
                ),
                ButtonTheme(
                  minWidth: 500,
                  child: RaisedButton(
                    child: Text("Don't have an account? Signup here!", style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupPage()));
                    },
                    color: FineanceColor.matBlue700,
                    elevation: 0,
                    focusElevation: 0,
                    highlightElevation: 0,
                    hoverElevation: 0,
                  )
                )
              ],
            ),]),
            padding: EdgeInsets.only(top: 10, right: 30, left: 30),
          ),), flex: 3)
        ],
      )
    );
  }

}
