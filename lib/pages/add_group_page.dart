import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/group.dart';
import 'package:quickcheck/data/model/student.dart';

/// The page where new groups can be added.
/// Consists of a textfield, a save button, and a cancel button.
/// On save, it calls the [callback]. On cancel, it returns
/// to the preivous page.
class AddGroupPage extends StatefulWidget {
  /// the callback to be called on save
  final Function(Group) callback;

  /// Students to potentially add to the group
  final List<Student> students;

  /// The page where new groups can be added.
  /// Takes a [callback], which is called on save with the new group.
  const AddGroupPage({Key? key, required this.callback, required this.students})
      : super(key: key);

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  /// The controller for the textfield
  final TextEditingController _controller = TextEditingController();

  /// The collection of students and whether or not they're in the group
  final Map<Student, bool> students = {};

  @override
  void initState() {
    super.initState();
    // initialize the students map with false
    for (Student student in widget.students) {
      students[student] = false;
    }
  }

  /// prompt user if they want to lose their work
  Future<bool> _onBack(BuildContext context) async {
    if (_controller.text.isNotEmpty || students.containsValue(true)) {
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
          title: const Text("Add Group"),
        ),
        body: ListView.builder(
            itemCount: widget.students.length + 2,
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
            itemBuilder: ((context, index) {
              // render name textbox first
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(labelText: "Name (required)"),
                  ),
                );
              } else if (index == 1) {
                // render the title for the students
                return Center(
                    child: Text(
                  "Students",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ));
              }
              // otherwise render the students
              return CheckboxListTile(
                  value: students[widget.students[index - 2]],
                  title: Text(widget.students[index - 2].name),
                  onChanged: ((value) {
                    setState(() {
                      students[widget.students[index - 2]] = value!;
                    });
                  }));
            })),
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
                              title: const Text("Improper group formatting"),
                              content: const Text("A group requires a name!"),
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
                    // remove the students that aren't selected
                    students.removeWhere((key, value) => value == false);
                    // call the callback
                    // and go to previous page
                    widget.callback.call(Group(
                        name: _controller.text,
                        members: students.keys.toList()));
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