class LoginResponse {
  final bool status;
  final String message;
  String username;
  String name;
  String token;

  LoginResponse({this.status, this.message, this.username, this.name, this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json["status"] as bool,
      message: json["message"] as String,
      username: json.containsKey("data") ? json["data"]["username"] : null,
      name: json.containsKey("data") ? json["data"]["name"] : null,
      token: json.containsKey("data") ? json["data"]["token"] : null
    );
  }
}
