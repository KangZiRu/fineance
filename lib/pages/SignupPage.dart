import 'package:fineance/pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fineance/globals/colors.dart';
import 'package:fineance/globals/network.dart';
import 'package:fineance/services/NetworkService.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';


class SignupPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _SignupPage();
  }
}

class _SignupPage extends State<SignupPage> {
  var userIdController = new TextEditingController();
  var userNameController = new TextEditingController();
  var passwordController = new TextEditingController();
  var repasswordController = new TextEditingController();
  String userIdError;
  String userNameError;
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

  bool validation() {
    if (userIdController.text.isEmpty) {
      setState(() {
        userIdError = "User ID cannot be empty!";
        userNameError = null;
        passwordError = null;
      });
      return false;
    }

    if (userIdController.text.length < 6) {
      setState(() {
        userIdError = "Username should be at least 6 characters!";
        userNameError = null;
        passwordError = null;
      });

      return false;
    }

    if ( ! userIdController.text.contains(new RegExp(r"[a-zA-Z0-9\_\.]+"))) {
      setState(() {
        userIdError = "Username should only contains alphanumerics, underscores, and periods!";
        userNameError = null;
        passwordError = null;
      });

      return false;
    }

    if (userNameController.text.isEmpty) {
      setState(() {
        userNameError = "Name cannot be empty!";
        userIdError = null;
        passwordError = null;
      });
      return false;
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        passwordError = "Passowrd cannot be empty";
        userNameError = null;
        userIdError = null;
      });

      return false;
    }

    if (passwordController.text.length < 3) {
      setState(() {
        passwordError = "Password should be at least 6 characters!";
        userNameError = null;
        userIdError = null;
      });

      return false;
    }

    if (passwordController.text != repasswordController.text) {
      setState(() {
        passwordError = "Passwords should be match!";
        userNameError = null;
        userIdError = null;
      });

      return false;
    }

    return true;
  }
  
  onSubmit() async {
    if (!validation()) {
      return;
    }
    
    Map<String, dynamic> body = new Map();
    body["username"] = userIdController.text;
    body["password"] = passwordController.text;
    body["name"] = userNameController.text;

    print(baseUrl + "/api/auth/signup");

    setState(() {
      isLoading = true;
    });

    debugPrint(baseUrl + "/api/auth/signup");
    
    NetworkService.post(
      baseUrl + "/api/auth/signup",
      body: body,
      always: (bool isSuccess) {
        debugPrint("well!!");
        setState(() {
          isLoading = false;
          if (!isSuccess) {
            userIdError = null;
            passwordError = null;
          }
        });
      },
      error: (response) {
        debugPrint(response.body);
      },
      success: (Map<String, dynamic> json) {
        if (!json["status"]) {
          if (json["message"].startsWith("Username")) {
            setState(() {
              userIdError = json["message"];
              passwordError = null;
            });
          }
          return;
        }

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
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
                  bottom: 0
                ),
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    isKeyboardVisible
                      ? Column(children: <Widget>[
                          Text("FINEANCE", style: TextStyle(
                            fontSize: 22,
                          )),
                          Text("SIGNUP", style: TextStyle(
                            fontSize: 12,
                          ))
                        ])
                      : Column(children: <Widget>[
                          Image.asset("assets/images/logo.png", height: 60, width: 60),
                          SizedBox(height: 16),
                          Text("FINEANCE", style: TextStyle(
                            fontSize: 40,
                          )),
                          SizedBox(height: 20),
                          Text("SIGNUP", style: TextStyle(
                            fontSize: 20,
                          )),
                        ]),
                  ],
                  mainAxisAlignment: MainAxisAlignment.end
                ),
                alignment: Alignment(0, 0),
              )
            ),
            flex: isKeyboardVisible ? 1 : 2
          ),
          Expanded(child: Center(child: Container(
            color: Colors.white,
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
                      hintText: "username",
                      errorText: userIdError
                    ),
                    cursorColor: FineanceColor.matBlue700,
                    style: TextStyle(color: FineanceColor.matBlue700),
                    
                  ),
                  SizedBox(height: userIdError == null ? 20 : 0),
                  TextField(
                    controller: userNameController,
                    decoration: InputDecoration(
                      hintText: "name",
                      errorText: userNameError
                    ),
                    cursorColor: FineanceColor.matBlue700,
                    style: TextStyle(color: FineanceColor.matBlue700),
                    
                  ),
                  SizedBox(height: userNameError == null ? 20 : 0),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "password",
                      errorText: passwordError
                    ),
                    cursorColor: FineanceColor.matBlue700,
                    style: TextStyle(color: FineanceColor.matBlue700),
                  ),
                  SizedBox(height: passwordError == null ? 20 : 0),
                  TextField(
                    controller: repasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "retype your password",
                      errorText: passwordError
                    ),
                    cursorColor: FineanceColor.matBlue700,
                    style: TextStyle(color: FineanceColor.matBlue700),
                  ),
                  SizedBox(height: passwordError == null ? 50 : 30),
                  ButtonTheme(
                    minWidth: 500,
                    child: RaisedButton(
                      child: Text("SIGNUP", style: TextStyle(color: Colors.white)),
                      onPressed: onSubmit,
                      color: FineanceColor.matBlue700,
                      elevation: 0,
                    )
                  ),
                  ButtonTheme(
                    minWidth: 500,
                    child: RaisedButton(
                      child: Text("Already have an account? Login here!", style: TextStyle(color: FineanceColor.matBlue700)),
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                      color: Colors.white,
                      elevation: 0,
                      focusElevation: 0,
                      highlightElevation: 0,
                      hoverElevation: 0,
                    )
                  )
                ],
              ),
            ]),
            padding: EdgeInsets.only(top: 10, right: 30, left: 30),
          ),), flex: isKeyboardVisible ? 6 : 4)
        ],
      )
    );
  }

}
