// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

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
      // get remember me
      bool? stayLoggedIn =
          await _cacheRepository.getRecord("stayLoggedIn") as bool?;
      // if null, make it false
      stayLoggedIn ??= false;

      if (token == null) {
        // proceed to standard login page
        emit(DisplayLoginPage("", "", stayLoggedIn));
      } else {
        // try and login
        _authenticationRepository.url = endpointURL;
        _authenticationRepository.token = token;
        try {
          // test out the token
          await _authenticationRepository.tryToken();
        } catch (e) {
          // display login page
          emit(DisplayLoginPage("", "", stayLoggedIn));
          if (e is TokenFailedException) {
            // couldn't login with the token, so reset and ask for credentials
            _cacheRepository.putRecord("token", null);
          } else {
            // show error
            emit(LoginPageError("", "", stayLoggedIn,
                title: "An Error has Occurred", body: e.toString()));
          }

          return;
        }
        // try to set analytics user ID to be username
        String? username =
            await _cacheRepository.getRecord("username") as String?;
        if (username != null) {
          await FirebaseAnalytics.instance.setUserId(id: username);
        }

        // success
        emit(const LoginPageLoggedIn());
      }
    });

    on<LoginEvent>((event, emit) async {
      // display loading
      emit(
          LoadingLoginPage(event.username, event.password, state.stayLoggedIn));
      // check to make sure there's a username
      if (event.username.isEmpty) {
        emit(LoginPageError(event.username, event.password, state.stayLoggedIn,
            title: "Username Required", body: "Please enter a username"));
        return;
      }
      // check to make sure there's a password
      if (event.password.isEmpty) {
        emit(LoginPageError(event.username, event.password, state.stayLoggedIn,
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
          emit(LoginPageError(
              event.username, event.password, state.stayLoggedIn,
              title: "Invalid Request",
              body:
                  "Could not connect to server or username/password was incorrect"));
        } else {
          // success
          // save token to cache if supposed to
          if (state.stayLoggedIn) {
            _cacheRepository.putRecord("token", token);
            // save username to cache
            _cacheRepository.putRecord("username", event.username);
          }

          // set analytics id
          await FirebaseAnalytics.instance.setUserId(id: event.username);
          // add analytics event
          await FirebaseAnalytics.instance.logLogin();
          // move to next screen
          emit(const LoginPageLoggedIn());
        }
      } catch (E) {
        emit(LoginPageError(event.username, event.password, state.stayLoggedIn,
            title: "An Error has Occurred", body: E.toString()));
      }
    });

    on<StayLoggedInToggleEvent>(
      (event, emit) async {
        // update cache
        await _cacheRepository.putRecord("stayLoggedIn", event.stayLoggedIn);
        // update display
        emit(DisplayLoginPage(
            event.username, event.password, event.stayLoggedIn));
      },
    );
  }
}

abstract class LoginPageEvent extends Equatable {
  const LoginPageEvent();

  @override
  List<Object?> get props => [];
}

// update stay logged in checkbox
class StayLoggedInToggleEvent extends LoginPageEvent {
  final String username;
  final String password;
  final bool stayLoggedIn;

  const StayLoggedInToggleEvent(
      this.username, this.password, this.stayLoggedIn);

  @override
  List<Object?> get props => [username, password, stayLoggedIn];
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
  final bool stayLoggedIn;

  const LoginPageState(this.username, this.password, this.stayLoggedIn);

  @override
  List<Object?> get props => [username, password, stayLoggedIn];
}

/// Successfully logged in
class LoginPageLoggedIn extends LoginPageState {
  /// Successfully logged in
  const LoginPageLoggedIn() : super("", "", true);
}

/// Loading on the login page
class LoadingLoginPage extends LoginPageState {
  /// Loading on the login page
  const LoadingLoginPage(super.username, super.password, super.stayLoggedIn);
}

/// Display the login page
class DisplayLoginPage extends LoginPageState {
  /// Display the login page
  const DisplayLoginPage(super.username, super.password, super.stayLoggedIn);
}

/// Display a loading symbol without login page
class LoadingLoginCache extends LoginPageState {
  /// Display a loading symbol without login page
  const LoadingLoginCache() : super("", "", true);
}

/// Display an error alert with given [title] and [body]
class LoginPageError extends LoginPageState {
  final String title;
  final String body;

  /// Display an error alert with given [title] and [body]
  const LoginPageError(
    super.username,
    super.password,
    super.stayLoggedIn, {
    required this.title,
    required this.body,
  });

  @override
  List<Object?> get props => [username, password, stayLoggedIn, title, body];
}
