import 'package:fineance/models/Source.dart';
import 'package:fineance/models/Transaction.dart';


class UserSummary {
  final String username;
  final String name;
  int balance;
  List<Transaction> transactions;
  List<Source> sources;

  UserSummary({this.username, this.name, this.balance, this.transactions});

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      username: json["username"] as String,
      name: json["name"] as String,
      balance: int.parse(json["balance"]),
      transactions: (json["transactions"] as Iterable)
          .map((model) => Transaction.fromJson(model))
          .toList(),
    );
  }
}
