import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:quickcheck/data/repository/authentification_repository.dart';

class NetworkedAuthenticationRepository extends AuthenticationRepository {
  String? url;

  String? token;

  NetworkedAuthenticationRepository({this.url, this.token});

  @override
  Future<String?> getUrl() async {
    return url;
  }

  @override
  Future<String?> getToken() async {
    return token;
  }

  @override
  Future<String?> login(String username, String password) async {
    Response response = await http.post(
      Uri.parse('${url}auth/api-token-auth/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );
    if (response.statusCode != 200 || response.body == '400') {
      return null;
    }
    token = jsonDecode(response.body)['token'];
    return token;
  }

  @override
  Future<void> logout() async {
    // send logout request to server

    // nullify token
    token = null;
  }

  @override
  Future<void> tryToken() async {
    Response response = await http.get(Uri.parse('${url}api/classes/'),
        headers: <String, String>{'Authorization': 'Token $token'});
    if (response.statusCode == 401) {
      throw TokenFailedException(
          "Received status code of ${response.statusCode} with body of ${response.body}",
          token ?? "-1");
    }
  }
}
