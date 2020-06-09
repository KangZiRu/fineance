class Source {
  final String id;
  final String source;
  int balance;
  final String logo;

  Source({this.id, this.source, this.balance, this.logo});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json["source_id"] as String,
      source: json["source"] as String,
      balance: json["balance"] == null ? 0 : int.parse(json["balance"]),
      logo: json["logo"] as String
    );
  }
}