import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_state/flutter_import.dart';
import 'package:intl/intl.dart';
import 'package:fineance/models/Transaction.dart';
import 'package:fineance/helpers/CurrencyFormatter.dart';
import 'package:fineance/globals/network.dart';


class TransactionHistoryTile extends StatelessWidget {
  final Transaction transaction;
  final bool isLastIndex;

  TransactionHistoryTile({
    this.transaction,
    this.isLastIndex
  });

  
  @override
  Widget build(BuildContext context) {
    Color borderColor = Color.fromARGB(200, 200, 200, 200);

    int nominal = transaction.nominal;
    Color color;
    if (transaction.type == TransactionType.IN) {
      color = Colors.green;
    } else {
      nominal = -nominal;
      color = Colors.red;
    }
    
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Image.network(
            baseUrl + "/res/u/source/logo/" + transaction.source.logo,
            height: 48,
            width: 48
          ),
          SizedBox(width: 10,),
          Container(
            height: 42,
            child: Column(
              children: <Widget>[
                Text(transaction.title, style: TextStyle(
                  fontSize: 18
                )),
                Text(transaction.source.source, style: TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(120, 10, 10, 10)
                ))
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            )
          ),
          Spacer(flex: 1),
          Container(
            height: 42,
            child: Column(
              children: <Widget>[
                Text(DateFormat("dd/MM/yyyy ").format(transaction.dateTime), style: TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(120, 80, 80, 80)
                )),
                Text(
                  formatCurrency(nominal: nominal),
                  style: TextStyle(
                    color: color,
                    fontSize: 16
                  )
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            )
          )
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
  }
}