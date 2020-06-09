import 'package:fineance/helpers/PubSub.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_state/flutter_import.dart';
import 'package:fineance/globals/colors.dart';
import 'package:fineance/globals/network.dart';
import 'package:fineance/helpers/CurrencyFormatter.dart';
import 'package:fineance/models/Source.dart';
import 'package:fineance/pages/Components/SideBar.dart';
import 'package:fineance/services/NetworkService.dart';
import 'package:global_state/global_state.dart';


class SourcePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SourcePage();
  }
}


class _SourcePage extends State<SourcePage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Source> availableSources = new List();
  List<Source> sources = new List();

  _SourcePage() {
    debugPrint("MEONPGOMEFMWFKWMDLKQWM");
    EventManager.of("source");
    EventManager.on("added", (Map<String, dynamic> json) {
      availableSources.removeWhere((source) => source.id == json["source_id"] as String);
      json["source"]["balance"] = json["balance"];
      Source source = Source.fromJson(json["source"]);
      var _stemp = sources.map((item) => item).toList();
      _stemp.add(source);

      setState(() {
        sources = _stemp;
      });
      store["user"].sources = sources;
      store["user"].balance += int.parse(json["balance"]);
    });
  }


  fetchSources() {
    print(baseUrl + "/api/user_source/summary");
    NetworkService.get(
      baseUrl + "/api/user_source/summary",
      success: (Map<String, dynamic> json) {
        print(json);
        setState(() {
          availableSources = (json["available_sources"] as List).map((item) => Source.fromJson(item)).toList();
          sources = (json["sources"] as List).map((item) => Source.fromJson(item)).toList();
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
  }

  @override
  void dispose() {
    super.dispose();
    EventManager.of("source");
    EventManager.clearEvents();
  }

  Future<Null> showModal(context) async {
    if (availableSources.length == 0) {
      return Future<Null>(() {});
    }
    
    return showDialog<Null>(
      context: context,
      builder: (context) => AddModal(sources: availableSources,)
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
                    Text("Sources", style: TextStyle(fontSize: 28)),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        showModal(context);
                      },
                      padding: EdgeInsets.all(8),
                      color: availableSources.length > 0 ? FineanceColor.matBlue700 : Color.fromARGB(120, 10, 10, 10),
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ],
            )
          ),
          Container(
            child: Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
                child: ListView.builder(
                  itemCount: sources.length,
                  itemBuilder: (context, index) {
                    Source source = sources[index];
                    bool isLastIndex = sources.length - 1 == index;
                    Color borderColor = Color.fromARGB(200, 200, 200, 200);
                    
                    return new Container(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: <Widget>[
                          Image.network(
                            baseUrl + "/res/u/source/logo/" + source.logo,
                            height: 48,
                            width: 48
                          ),
                          SizedBox(width: 10,),
                          Container(
                            height: 42,
                            child: Column(
                              children: <Widget>[
                                Text(source.source, style: TextStyle(
                                  fontSize: 18
                                )),
                                Text(formatCurrency(nominal: source.balance), style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(120, 10, 10, 10)
                                ))
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            )
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        border: isLastIndex
                                  ? Border.all(color: borderColor)
                                  : Border(
                                      left: BorderSide(color: borderColor),
                                      top: BorderSide(color: borderColor),
                                      right: BorderSide(color: borderColor),
                                    )
                      ),
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
  TextEditingController nominalController = new TextEditingController();

  _AddModal({this.sources});

  @override
  void initState() {
    super.initState();

    if (sources.length > 0) {
      sourceController = sources[0].id;
    }
  }

  void submit() {
    Map<String, dynamic> body = new Map();
    body["source_id"] = sourceController;
    body["initial_balance"] = nominalController.text;
    
    NetworkService.post(
      baseUrl + "/api/user_source",
      body: body,
      success: (Map<String, dynamic> json) {
        if (json["status"] as bool) {
          print(json["status"]);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          EventManager.of("source");
          EventManager.fire("added", data: json["data"]);
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
          formatCurrency(nominal: int.parse(nominalController.text));
        
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
      title: Text("Add source"),
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
              Text("Initial balance", style: TextStyle(
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
