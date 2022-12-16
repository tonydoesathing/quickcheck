abstract class AuthenticationRepository {
  set url(String url) {}

  Future<String?> getUrl();

  Future<String?> getToken();

  Future<String?> login(String username, String password);
}
