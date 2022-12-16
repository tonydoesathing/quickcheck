import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcheck/data/repository/authentification_repository.dart';
import 'package:quickcheck/pages/view_classes_page.dart';
import '/data/repository/networked_authentification_repository.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Card(
        color: Color.fromARGB(189, 57, 57, 221),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 8),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 8),
              child: TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                ),
                obscureText: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 8),
              child: TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Server Address"),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                          onPrimary: Theme.of(context).colorScheme.onPrimary,
                          primary: Theme.of(context).colorScheme.primary)
                      .copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                  onPressed: () async {
                    if (_usernameController.text.isEmpty) {
                      // prompt user to input username
                      await showDialog(
                          context: context,
                          builder: ((context) {
                            return AlertDialog(
                              title: const Text("Username required"),
                              content: const Text("Please enter a username"),
                              actions: [
                                ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    style: ElevatedButton.styleFrom(
                                      // Foreground color
                                      onPrimary: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      // Background color
                                      primary:
                                          Theme.of(context).colorScheme.primary,
                                    ).copyWith(
                                        elevation:
                                            ButtonStyleButton.allOrNull(0.0)),
                                    child: const Text("Okay"))
                              ],
                            );
                          }));
                    } else if (_passwordController.text.isEmpty) {
                      // prompt user to input username
                      await showDialog(
                          context: context,
                          builder: ((context) {
                            return AlertDialog(
                              title: const Text("Password required"),
                              content: const Text("Please enter a password"),
                              actions: [
                                ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    style: ElevatedButton.styleFrom(
                                      // Foreground color
                                      onPrimary: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      // Background color
                                      primary:
                                          Theme.of(context).colorScheme.primary,
                                    ).copyWith(
                                        elevation:
                                            ButtonStyleButton.allOrNull(0.0)),
                                    child: const Text("Okay"))
                              ],
                            );
                          }));
                    } else if (_addressController.text.isEmpty) {
                      // prompt user to input username
                      await showDialog(
                          context: context,
                          builder: ((context) {
                            return AlertDialog(
                              title: const Text("Server address required"),
                              content:
                                  const Text("Please enter a server address"),
                              actions: [
                                ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    style: ElevatedButton.styleFrom(
                                      // Foreground color
                                      onPrimary: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      // Background color
                                      primary:
                                          Theme.of(context).colorScheme.primary,
                                    ).copyWith(
                                        elevation:
                                            ButtonStyleButton.allOrNull(0.0)),
                                    child: const Text("Okay"))
                              ],
                            );
                          }));
                    } else {
                      context.read<AuthenticationRepository>().url =
                          _addressController.text;
                      String? token;
                      try {
                        token = await context
                            .read<AuthenticationRepository>()
                            .login(_usernameController.text,
                                _passwordController.text);
                      } catch (E) {
                        await showDialog(
                            context: context,
                            builder: ((context) {
                              return AlertDialog(
                                title: const Text("Invalid server address"),
                                content: const Text(
                                    "Could not connect to the specified server"),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      style: ElevatedButton.styleFrom(
                                        // Foreground color
                                        onPrimary: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        // Background color
                                        primary: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ).copyWith(
                                          elevation:
                                              ButtonStyleButton.allOrNull(0.0)),
                                      child: const Text("Okay"))
                                ],
                              );
                            }));
                      }
                      if (token == null) {
                        await showDialog(
                            context: context,
                            builder: ((context) {
                              return AlertDialog(
                                title: const Text("Invalid request"),
                                content: const Text(
                                    "The server address, username or password was incorrect"),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      style: ElevatedButton.styleFrom(
                                        // Foreground color
                                        onPrimary: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        // Background color
                                        primary: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ).copyWith(
                                          elevation:
                                              ButtonStyleButton.allOrNull(0.0)),
                                      child: const Text("Okay"))
                                ],
                              );
                            }));
                      } else {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewClassesPage(),
                            ));
                      }
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("Log in")),
            ],
          ),
        ),
      ),
    );
  }
}
