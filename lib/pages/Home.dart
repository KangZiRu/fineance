import 'package:fineance/pages/Components/TransactionHistoryTile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_state/global_state.dart';
import 'package:fineance/globals/network.dart';
import 'package:fineance/helpers/CurrencyFormatter.dart';
import 'package:fineance/models/Transaction.dart';
import 'package:fineance/models/UserSummary.dart';
import 'package:fineance/services/NetworkService.dart';
import 'package:fineance/stores/User.dart';
import 'package:fineance/globals/colors.dart';
import 'Components/SideBar.dart';


class HomePage extends StatefulWidget {
  const HomePage({ Key key }) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

void setTransactionOnHomePage(List<Transaction> transactions) {
  _HomePageState.userSummary.transactions = transactions;
}


class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  static UserSummary userSummary;

  _getUserSummary() {
    debugPrint("aaaaa");
    NetworkService.get(
      baseUrl + "/api/account/summary",
      success: (Map<String, dynamic> json) {
        setState(() {
          userSummary = UserSummary.fromJson(json);
        });

        if (store["user"].username == null) {
          User user = User.fromJson(json);
          store["user"] = user;
        }
      }
    );
  }

  @override
  void initState() {
    super.initState();

    _getUserSummary();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Fineance', style: TextStyle(color: FineanceColor.matBlue700)),
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: FineanceColor.matBlue700),
      ),
      drawer: new SideBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.only(right: 15),
                color: FineanceColor.matBlue700,
                child: Column(
                  children: <Widget>[
                    Text("Your balance", style: TextStyle(
                      color: Colors.white,
                      fontSize: 20
                    ),),
                    SizedBox(height: 10),
                    Text(userSummary == null ? "Rp 0" : formatCurrency(nominal: store["user"].balance), style: TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                    ),)
                  ],
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                alignment: Alignment(1, 0),
              )
            ),
            flex: 36
          ),
          Expanded(
            child: Container(
              child: Column(
                children: <Widget>[
                  Text("Latest transactions", style: TextStyle(fontSize: 18),),
                  (userSummary == null
                    ? Text("Loading...")
                    : Expanded(child: new ListView.builder(
                      itemCount: userSummary.transactions.length,
                      itemBuilder: (context, index) {
                        Transaction transaction = userSummary.transactions[index];
                        return new TransactionHistoryTile(
                          transaction: transaction,
                          isLastIndex: userSummary.transactions.length - 1 == index,
                        );
                      },
                    ),)
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
              alignment: Alignment(-1, 0),
              padding: EdgeInsets.only(left: 15, top: 24, right: 15),
            ),
            flex: 100,
          )
        ],
      )
    );
  }
}

