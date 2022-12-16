import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        color: const Color.fromARGB(172, 14, 14, 196),
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
                      return;
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
                      return;
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
                      return;
                    } else {
                      String? token = RepositoryProvider.of(context)
                          .authentificationRepository
                          .login(_usernameController.text,
                              _passwordController.text) as String?;
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
                        return;
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
