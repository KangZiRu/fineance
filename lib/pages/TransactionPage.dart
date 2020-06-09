import 'package:fineance/helpers/PubSub.dart';
import 'package:fineance/pages/Components/TransactionHistoryTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_state/flutter_import.dart';
import 'package:fineance/globals/colors.dart';
import 'package:fineance/globals/network.dart';
import 'package:fineance/helpers/CurrencyFormatter.dart';
import 'package:fineance/models/Source.dart';
import 'package:fineance/models/Transaction.dart';
import 'package:fineance/pages/Components/SideBar.dart';
import 'package:fineance/services/NetworkService.dart';
import 'package:global_state/global_state.dart';


class TransactionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TransactionPage();
  }
}


class _TransactionPage extends State<TransactionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Source> sources = new List();
  List<Transaction> transactions = new List();
  String sourceController = "ALL";
  String typeController = "ALL";

  _TransactionPage() {
    EventManager.of("transaction");
    EventManager.on("added", fetchTransactions);
  }

  fetchTransactions() {
    debugPrint(baseUrl + "/api/transaction?source_id=" + sourceController + "&type=" + typeController,);
    
    NetworkService.get(
      baseUrl + "/api/transaction?source_id=" + sourceController + "&type=" + typeController,
      success: (List<dynamic> json) {
        setState(() {
          transactions =
            json.map((item) => Transaction.fromJson(item as Map<String, dynamic>)).toList();
        });
      }
    );
  }

  fetchSources() {
    print(baseUrl + "/api/source");
    NetworkService.get(
      baseUrl + "/api/source",
      success: (List<dynamic> json) {
        print(json);
        setState(() {
          sources = json.map((item) => Source.fromJson(item)).toList();
        });
      },
      error: (response) {
        debugPrint(response.body);
      }
    );
  }

  @override
  void initState() {
    super.initState();

    fetchSources();
    fetchTransactions();
  }

  @override
  void dispose() {
    super.dispose();
    EventManager.of("transaction");
    EventManager.clearEvents();
  }

  Future<Null> showModal(context) async {
    return showDialog<Null>(
      context: context,
      builder: (context) => AddModal(sources: sources,)
    );
  }
  
  @override
  Widget build(BuildContext context) {
    var transactionOptions =
      sources.map((item) {
        return DropdownMenuItem<String>(
          child: Text(item.source),
          value: item.id
        );
      }).toList();

    transactionOptions.insert(0, DropdownMenuItem<String>(
      child: Text("All"),
      value: "ALL"
    ));
    

    
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
          Container(
            padding: EdgeInsets.only(top: 8, bottom: 10, left: 20, right: 20),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text("Transactions", style: TextStyle(fontSize: 28)),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        showModal(context);
                      },
                      padding: EdgeInsets.all(8),
                      color: FineanceColor.matBlue700,
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                Row(
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          Text("Source", style: TextStyle(
                            fontSize: 12
                          )),
                          DropdownButton<String>(
                            isDense: true,
                            items: transactionOptions,
                            value: sourceController,
                            onChanged: (String val) {
                              setState(() {
                                sourceController = val;
                                fetchTransactions();
                              });
                            },
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      )
                    ),
                    Spacer(),
                    Column(
                      children: <Widget>[
                        Text("Type", style: TextStyle(
                          fontSize: 12
                        )),
                        DropdownButton<String>(
                          items: [
                            DropdownMenuItem(
                              value: "ALL",
                              child: Text("All")
                            ),
                            DropdownMenuItem(
                              value: "IN",
                              child: Text("IN")
                            ),
                            DropdownMenuItem(
                              value: "OUT",
                              child: Text("OUT")
                            ),
                          ],
                          isDense: true,
                          onChanged: (String val) {
                            setState(() {
                              typeController = val;
                              fetchTransactions();
                            });
                          },
                          value: typeController
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ],
                )
              ],
            )
          ),
          Container(
            child: Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    Transaction transaction = transactions[index];
                    return new TransactionHistoryTile(
                      transaction: transaction,
                      isLastIndex: transactions.length - 1 == index,
                    );
                  },
                ),
              )
            ),
          ),
        ],
      )
    );
  }

}


class AddModal extends StatefulWidget {
  final List<Source> sources;
  
  AddModal({this.sources});
  
  @override
  State<StatefulWidget> createState() {
    return _AddModal(sources: sources);
  }
}

class _AddModal extends State<AddModal> {
  List<Source> sources;
  String sourceController;
  String typeController;
  TextEditingController nominalController = new TextEditingController();
  TextEditingController titleController = new TextEditingController();

  _AddModal({this.sources});

  @override
  void initState() {
    super.initState();

    typeController = "IN";
    if (sources.length > 0) {
      sourceController = sources[0].id;
    }
  }

  void submit() {
    Map<String, dynamic> body = new Map();
    body["source_id"] = sourceController;
    body["type"] = typeController;
    body["nominal"] = nominalController.text;
    body["title"] = titleController.text;

    NetworkService.post(
      baseUrl + "/api/transaction",
      body: body,
      success: (Map<String, dynamic> json) {
        if (json["status"] as bool) {
          print(json["status"]);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          EventManager.of("transaction");
          EventManager.fire("added");

          if (body["type"] == "IN") {
            store["user"].balance += int.parse(body["nominal"]);

            for (Source source in store["user"].sources) {
              if (source.id == body["source_id"]) {
                source.balance += body["nominal"];
                break;
              }
            }
          } else {
            store["user"].balance -= int.parse(body["nominal"]);

            for (Source source in store["user"].sources) {
              if (source.id == body["source_id"]) {
                source.balance -= body["nominal"];
                break;
              }
            }
          }
        }
      },
      error: (response) {
        debugPrint(response.body);
      }
    );
  }

  void submitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String source =
          sources.firstWhere((source) => source.id == sourceController).source;
        String nominal =
          formatCurrency(nominal: int.parse(nominalController.text) * (typeController == "IN" ? 1 : -1));
        
        return AlertDialog(
          title: Text("Confirmation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text("Source", style: TextStyle(
                    fontSize: 12
                  )),
                  Text(source),
                ],
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              SizedBox(height: 18),
              Column(
                children: <Widget>[
                  Text("Nominal", style: TextStyle(
                    fontSize: 12
                  )),
                  Text(nominal)
                ],
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              SizedBox(height: 18),
              Column(
                children: <Widget>[
                  Text("Title", style: TextStyle(
                    fontSize: 12
                  )),
                  Text(titleController.text)
                ],
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("CONFIRM"),
              onPressed: submit,
            ),
          ],
        );
      }
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add transaction"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text("Source", style: TextStyle(
                fontSize: 12
              )),
              DropdownButton<String>(
                isDense: true,
                items: sources.map((item) {
                  return DropdownMenuItem<String>(
                    child: Text(item.source),
                    value: item.id
                  );
                }).toList(),
                value: sourceController,
                onChanged: (String val) {
                  setState(() {
                    sourceController = val;
                  });
                },
              )
            ],
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          SizedBox(height: 18),
          Column(
            children: <Widget>[
              Text("Type", style: TextStyle(
                fontSize: 12
              )),
              DropdownButton<String>(
                items: [
                  DropdownMenuItem(
                    value: "IN",
                    child: Text("IN")
                  ),
                  DropdownMenuItem(
                    value: "OUT",
                    child: Text("OUT")
                  ),
                ],
                isDense: true,
                onChanged: (String val) {
                  setState(() {
                    typeController = val;
                  });
                },
                value: typeController
              )
            ],
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          SizedBox(height: 18),
          Column(
            children: <Widget>[
              Text("Nominal", style: TextStyle(
                fontSize: 12
              )),
              TextFormField(
                controller: nominalController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
              )
            ],
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          SizedBox(height: 18),
          Column(
            children: <Widget>[
              Text("Title", style: TextStyle(
                fontSize: 12
              )),
              TextFormField(
                controller: titleController,
              )
            ],
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("CLOSE"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("SUBMIT"),
          onPressed: submitConfirmation,
        ),
      ],
    );
  }
}
