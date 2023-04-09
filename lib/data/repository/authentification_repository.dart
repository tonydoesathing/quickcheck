abstract class AuthenticationRepository {
  set url(String url);

  set token(String token);

  /// Returns the stored [url] or null if doesn't exist
  Future<String?> getUrl();

  /// Returns the stored [token] or null if doesn't exist
  Future<String?> getToken();

  /// Tries to login with the given [username] and [password] at the endpoint [url]
  ///
  /// Returns token if successful, null if failed
  Future<String?> login(String username, String password);

  /// Tries to logout
  ///
  /// Throws [LogoutException] if failed
  Future<void> logout();

  /// Tries the stored [token] on the [url]
  ///
  /// Throws [TokenFailedException] if failed
  Future<void> tryToken();
}

/// Error using token
class TokenFailedException implements Exception {
  final Object err;
  final String token;
  const TokenFailedException(this.err, this.token);

  @override
  String toString() {
    return 'Error for token $token: $err';
  }
}

/// Error logging out
class LogoutException implements Exception {
  final Object err;
  const LogoutException(
    this.err,
  );

  @override
  String toString() {
    return '$err';
  }
}
