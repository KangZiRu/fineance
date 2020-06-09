import 'package:fineance/models/Source.dart';


class User {
  String username;
  String name;
  List<Source> sources = new List();
  int balance;

  User({this.username, this.name, this.sources, this.balance});

  factory User.fromJson(Map<String, dynamic> json) {
    return new User(
      username: json["username"] as String,
      name: json["name"] as String,
      balance: int.parse(json["balance"]),
      sources: (json["sources"] as List).map((item) => Source.fromJson(item)).toList(),
    );
  }
}