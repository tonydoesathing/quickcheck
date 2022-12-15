abstract class AuthenticationRepository {
  Future<String> getUrl();

  Future<String> getToken();

  Future<String?> login(String username, String password);
}
