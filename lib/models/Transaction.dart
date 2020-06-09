import 'Source.dart';

enum TransactionType {
  IN,
  OUT
}

class Transaction {
  final int id;
  final Source source;
  final DateTime dateTime;
  final String title;
  final TransactionType type;
  final int nominal;

  Transaction({this.id, this.source, this.dateTime, this.nominal, this.title, this.type});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    String transactionType = 'TransactionType.' + json["type"];
    
    return Transaction(
      id: json["id"],
      source: Source.fromJson(json["source"]),
      dateTime: DateTime.parse(json["dateTime"] as String),
      nominal: int.parse(json["nominal"]),
      title: json["title"] as String,
      type: TransactionType.values.firstWhere(
        (f) => f.toString() == transactionType,
        orElse: null
      )
    );
  }
}
