// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:quickcheck/data/repository/authentification_repository.dart';
import 'package:quickcheck/data/repository/cache_repository.dart';

/// static reference to endpoint
/// future: load from file
const endpointURL = "https://quickcheck.dev/";

/// The BLoC responsible for the [LoginPage]
class LoginPageBloc extends Bloc<LoginPageEvent, LoginPageState> {
  /// authentication repository
  final AuthenticationRepository _authenticationRepository;

  /// cache repository
  final CacheRepository _cacheRepository;

  LoginPageBloc(this._authenticationRepository, this._cacheRepository)
      : super(const LoadingLoginCache()) {
    // on load, try and login using cached token
    on<LoginFromCacheEvent>((event, emit) async {
      // display loading state
      emit(const LoadingLoginCache());
      // fetch token from cache
      String? token = await _cacheRepository.getRecord("token") as String?;

      if (token == null) {
        // proceed to standard login page
        emit(const DisplayLoginPage("", ""));
      } else {
        // try and login
        _authenticationRepository.url = endpointURL;
        _authenticationRepository.token = token;
        try {
          // test out the token
          await _authenticationRepository.tryToken();
        } catch (e) {
          // display login page
          emit(const DisplayLoginPage("", ""));
          if (e is TokenFailedException) {
            // couldn't login with the token, so reset and ask for credentials
            _cacheRepository.putRecord("token", null);
          } else {
            // show error
            emit(LoginPageError("", "",
                title: "An Error has Occurred", body: e.toString()));
          }

          return;
        }
        // success
        emit(const LoginPageLoggedIn());
      }
    });

    on<LoginEvent>((event, emit) async {
      // display loading
      emit(LoadingLoginPage(event.username, event.password));
      // check to make sure there's a username
      if (event.username.isEmpty) {
        emit(LoginPageError(event.username, event.password,
            title: "Username Required", body: "Please enter a username"));
        return;
      }
      // check to make sure there's a password
      if (event.password.isEmpty) {
        emit(LoginPageError(event.username, event.password,
            title: "Password Required", body: "Please enter a password"));
        return;
      }

      // try to login
      String? token;
      try {
        _authenticationRepository.url = endpointURL;
        token = await _authenticationRepository.login(
            event.username, event.password);
        if (token == null) {
          // failed to get a token
          emit(LoginPageError(event.username, event.password,
              title: "Invalid Request",
              body:
                  "Could not connect to server or username/password was incorrect"));
        } else {
          // success
          // save token to cache
          _cacheRepository.putRecord("token", token);
          emit(const LoginPageLoggedIn());
        }
      } catch (E) {
        emit(LoginPageError(event.username, event.password,
            title: "An Error has Occurred", body: E.toString()));
      }
    });
  }
}

abstract class LoginPageEvent extends Equatable {
  const LoginPageEvent();

  @override
  List<Object?> get props => [];
}

/// Try and login from the cached token
class LoginFromCacheEvent extends LoginPageEvent {}

/// Try and login from given [username] and [password]
class LoginEvent extends LoginPageEvent {
  final String username;
  final String password;

  /// Try and login from given [username] and [password]
  const LoginEvent(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}

abstract class LoginPageState extends Equatable {
  final String username;
  final String password;

  const LoginPageState(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}

/// Successfully logged in
class LoginPageLoggedIn extends LoginPageState {
  /// Successfully logged in
  const LoginPageLoggedIn() : super("", "");
}

/// Loading on the login page
class LoadingLoginPage extends LoginPageState {
  /// Loading on the login page
  const LoadingLoginPage(super.username, super.password);
}

/// Display the login page
class DisplayLoginPage extends LoginPageState {
  /// Display the login page
  const DisplayLoginPage(super.username, super.password);
}

/// Display a loading symbol without login page
class LoadingLoginCache extends LoginPageState {
  /// Display a loading symbol without login page
  const LoadingLoginCache() : super("", "");
}

/// Display an error alert with given [title] and [body]
class LoginPageError extends LoginPageState {
  final String title;
  final String body;

  /// Display an error alert with given [title] and [body]
  const LoginPageError(
    super.username,
    super.password, {
    required this.title,
    required this.body,
  });

  @override
  List<Object?> get props => [username, password, title, body];
}
