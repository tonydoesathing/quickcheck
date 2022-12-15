class AuthenticationRepository {
  final String url;

  final String token;

  const AuthenticationRepository({required this.url, required this.token});

  Future<String> getUrl() async {
    return url;
  }

  Future<String> getToken() async {
    return url;
  }
}
