import 'package:fineance/globals/network.dart';
import 'package:fineance/models/Source.dart';
import 'package:fineance/pages/LoginPage.dart';
import 'package:fineance/services/NetworkService.dart';
import 'package:fineance/stores/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_state/global_state.dart';
import 'package:fineance/globals/colors.dart';
import 'package:fineance/helpers/CurrencyFormatter.dart';
import 'package:fineance/pages/Home.dart';
import 'package:fineance/pages/TransactionPage.dart';
import 'package:fineance/pages/SourcePage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              children: <Widget>[
                Image.asset("assets/images/logo.png", width: 42, height: 42),
                Spacer(),
                Text(store["user"].name, style: TextStyle(color: Colors.white, fontSize: 24)),
                Text(
                  formatCurrency(nominal: store["user"].balance) + " from " + store["user"].sources.length.toString() +  " sources",
                  style: TextStyle(color: Colors.white)
                )
              ],
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            decoration: BoxDecoration(
              color: FineanceColor.matBlue700,
            ),
            padding: EdgeInsets.only(bottom: 30, top: 20, left: 15),
          ),
          ListTile(
            title: Text("Home"),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
            }
          ),
          ListTile(
            title: Text("Sources"),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SourcePage()));
            },
          ),
          ListTile(
            title: Text("Transactions"),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TransactionPage()));
            },
          ),
          ListTile(
            title: Text("Logout"),
            onTap: () {
              NetworkService.post(baseUrl + "/api/auth/logout", success: (Map<String, dynamic> json) async {
                var prefs = await SharedPreferences.getInstance();
                prefs.remove("username");
                prefs.remove("token");
                
                store["user"].username = null;
                store["user"].sources = new List<Source>();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              });
            },
          ),
        ],
      )
    );
  }
  
}