// ignore_for_file: use_build_context_synchronously
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcheck/bloc/login_page_bloc.dart';
import 'package:quickcheck/data/repository/authentification_repository.dart';
import 'package:quickcheck/data/repository/cache_repository.dart';
import 'package:quickcheck/pages/view_classes_page.dart';
import '/data/repository/networked_authentification_repository.dart';

/// The page to allow a user to log in
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// generate an error dialog with a [title] and [content]
  Future<void> _errorDialog(
      BuildContext context, String title, String content) async {
    await showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: ElevatedButton.styleFrom(
                    // Foreground color
                    onPrimary: Theme.of(context).colorScheme.onPrimary,
                    // Background color
                    primary: Theme.of(context).colorScheme.primary,
                  ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                  child: const Text("Okay"))
            ],
          );
        }));
  }

  /// called on submit
  void _submit(BuildContext context) {
    context
        .read<LoginPageBloc>()
        .add(LoginEvent(_usernameController.text, _passwordController.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginPageBloc>(
      create: (context) => LoginPageBloc(
          context.read<AuthenticationRepository>(),
          context.read<CacheRepository>())
        ..add(LoginFromCacheEvent()),
      child: BlocConsumer<LoginPageBloc, LoginPageState>(
        listener: (context, state) {
          // update textfields
          _usernameController.text = state.username;
          _passwordController.text = state.password;

          if (state is LoginPageLoggedIn) {
            // push to next page
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: "view_classes"),
                  builder: (context) => const ViewClassesPage(),
                ));
          } else if (state is LoginPageError) {
            // display alert
            _errorDialog(context, state.title, state.body);
          }
        },
        builder: ((context, state) {
          if (state is LoadingLoginCache || state is LoginPageLoggedIn) {
            // just display loading
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Center(
                    child: CircularProgressIndicator(),
                  )
                ],
              ),
            );
          }
          // display login page
          return Scaffold(
            body: Stack(fit: StackFit.expand, children: [
              if (state is LoadingLoginPage)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Center(
                      child: CircularProgressIndicator(),
                    )
                  ],
                ),
              SingleChildScrollView(
                child: Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 75,
                          ),
                          child: SvgPicture.asset(
                            'assets/QuickCheckLogo.svg',
                            width: 250,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(50),
                          child: Container(
                            constraints: const BoxConstraints(
                                maxWidth: 400, minWidth: 250),
                            child: Card(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 24.0, right: 24.0, top: 8),
                                    child: TextField(
                                      controller: _usernameController,
                                      onSubmitted: (value) => _submit(context),
                                      decoration: const InputDecoration(
                                          labelText: "Username"),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 24.0, right: 24.0, top: 8),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      onFieldSubmitted: (value) =>
                                          _submit(context),
                                      decoration: const InputDecoration(
                                        labelText: "Password",
                                      ),
                                      obscureText: true,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 75,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                                    onPrimary: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    primary: Theme.of(context)
                                                        .colorScheme
                                                        .primary)
                                                .copyWith(
                                                    elevation: ButtonStyleButton
                                                        .allOrNull(0.0)),
                                            onPressed: () => _submit(context),
                                            icon: const Icon(Icons.login),
                                            label: const Text("Log in")),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
            ]),
          );
        }),
      ),
    );
  }
}
