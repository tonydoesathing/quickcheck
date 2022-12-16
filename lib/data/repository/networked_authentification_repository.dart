import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:quickcheck/data/repository/authentification_repository.dart';

class NetworkedAuthenticationRepository extends AuthenticationRepository {
  final String url;

  String? token;

  NetworkedAuthenticationRepository({required this.url, this.token});

  @override
  Future<String> getUrl() async {
    return url;
  }

  @override
  Future<String> getToken() async {
    return token!;
  }

  @override
  Future<String?> login(String username, String password) async {
    Response response = await http.post(
      Uri.parse('${url}auth/api-token-auth/'),
      body: {
        "username": username,
        "password": password,
      },
    );
    if (response.statusCode != 201) {
      return null;
    }
    token = jsonDecode(response.body);
    return token;
  }
}
