import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/student.dart';

/// The page where new students can be added.
/// Consists of a textfield, a save button, and a cancel button.
/// On save, it calls the optional [callback]. On cancel, it returns
/// to the preivous page.
class AddStudentPage extends StatefulWidget {
  /// the callback to be called on save
  final Function(Student) callback;

  /// The page where new students can be added.
  /// Takes an optional [callback], which is called on save with the new student.
  const AddStudentPage({Key? key, required this.callback}) : super(key: key);

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  /// The controller for the textfield
  final TextEditingController _controller = TextEditingController();

  /// prompt user if they want to lose their work
  Future<bool> _onBack(BuildContext context) async {
    if (_controller.text.isNotEmpty) {
      return await showDialog(
              context: context,
              builder: ((context) {
                return AlertDialog(
                  title: const Text("Exit without saving?"),
                  content: const Text(
                      "If you leave now, you will lose your progress!"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Exit")),
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          // Foreground color
                          onPrimary: Theme.of(context).colorScheme.onPrimary,
                          // Background color
                          primary: Theme.of(context).colorScheme.primary,
                        ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                        child: const Text("Cancel"))
                  ],
                );
              })) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope checks to see if the user can go back
    return WillPopScope(
      onWillPop: () => _onBack(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Student"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 8),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: "Name (required)"),
              ),
            )
          ],
        ),
        bottomNavigationBar: BottomAppBar(
            child: Container(
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
                    if (_controller.text.isEmpty) {
                      // prompt user to input name
                      await showDialog(
                          context: context,
                          builder: ((context) {
                            return AlertDialog(
                              title: const Text("Improper student formatting"),
                              content: const Text("A student requires a name!"),
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
                    }
                    // call the callback
                    // and go to previous page
                    widget.callback.call(Student(name: _controller.text));
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Save")),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                child: TextButton(
                    onPressed: () async {
                      bool goBack = await _onBack(context);
                      if (goBack) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Cancel",
                    )),
              )
            ],
          ),
        )),
      ),
    );
  }
}
