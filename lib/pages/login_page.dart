// ignore_for_file: use_build_context_synchronously
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcheck/data/repository/authentification_repository.dart';
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
  final TextEditingController _addressController = TextEditingController();

  /// generate an error dialog with a [title] and [content]
  Future<void> errorDialog(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
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
            child: Card(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24.0, right: 24.0, top: 8),
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: "Username"),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24.0, right: 24.0, top: 8),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: "Password",
                      ),
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24.0, right: 24.0, top: 8),
                    child: TextField(
                      controller: _addressController,
                      decoration:
                          const InputDecoration(labelText: "Server Address"),
                    ),
                  ),
                  SizedBox(
                    height: 75,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                    onPrimary:
                                        Theme.of(context).colorScheme.onPrimary,
                                    primary:
                                        Theme.of(context).colorScheme.primary)
                                .copyWith(
                                    elevation:
                                        ButtonStyleButton.allOrNull(0.0)),
                            onPressed: () async {
                              if (_usernameController.text.isEmpty) {
                                // prompt user to input username
                                await errorDialog(context, "Username required",
                                    "Please enter a username");
                              } else if (_passwordController.text.isEmpty) {
                                // prompt user to input username
                                await errorDialog(context, "Password Required",
                                    "Please enter a password");
                              } else if (_addressController.text.isEmpty) {
                                // prompt user to input username
                                await errorDialog(
                                    context,
                                    "Server address required",
                                    "Please enter a server address");
                              } else {
                                // set the URL
                                context.read<AuthenticationRepository>().url =
                                    _addressController.text;
                                // try and log in
                                String? token;
                                try {
                                  token = await context
                                      .read<AuthenticationRepository>()
                                      .login(_usernameController.text,
                                          _passwordController.text);
                                } catch (E) {
                                  await errorDialog(
                                      context,
                                      "Invalid server address",
                                      "Could not connect to the specified server");
                                }
                                if (token == null) {
                                  // failed to get a token
                                  await errorDialog(context, "Invalid request",
                                      "The server address, username, or password was incorrect");
                                } else {
                                  // got a token; go to ViewClassesPage
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ViewClassesPage(),
                                      ));
                                }
                              }
                            },
                            icon: const Icon(Icons.login),
                            label: const Text("Log in")),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
