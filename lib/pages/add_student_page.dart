import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/model/group.dart';

/// The page where new students can be added.
/// Consists of a textfield, a save button, and a cancel button.
/// On save, it calls the optional [callback]. On cancel, it returns
/// to the preivous page.
class AddStudentPage extends StatefulWidget {
  /// the callback to be called on save
  final Function(Student) callback;

  /// Groups to potentially add students to
  final List<Group> groups;

  /// Initial data to populate fields with
  final Student? student;

  /// The page where new students can be added.
  /// Takes an optional [callback], which is called on save with the new student.
  const AddStudentPage(
      {Key? key, required this.callback, required this.groups, this.student})
      : super(key: key);

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  /// The controller for the textfield
  final TextEditingController _controller = TextEditingController();

  /// The collection of groups and whether or not the student is in that group
  final Map<Group, bool> groups = {};

  @override
  void initState() {
    super.initState();
    // initialize the groups map with false or the group value
    for (Group group in widget.groups) {
      groups[group] = widget.student?.groups?.contains(group.id) ?? false;
    }
    _controller.text = widget.student?.name ?? "";
  }

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
          title: Text(widget.student == null ? "Add Student" : "Edit Student"),
        ),
        body: ListView.builder(
            itemCount: widget.groups.length + 2,
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
            itemBuilder: ((context, index) {
              // render name textbox first
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(labelText: "Name (required)"),
                  ),
                );
              } else if (index == 1) {
                // render the title for the groups
                return Center(
                    child: Text(
                  "Groups",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ));
              }
              // otherwise render the groups
              return CheckboxListTile(
                  value: groups[widget.groups[index - 2]],
                  title: Text(
                    widget.groups[index - 2].name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  onChanged: ((value) {
                    setState(() {
                      groups[widget.groups[index - 2]] = value!;
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
                    // take out false values
                    groups.removeWhere((key, value) => value == false);

                    // call the callback
                    // and go to previous page
                    widget.callback.call(Student(
                        id: widget.student?.id,
                        name: _controller.text,
                        groups:
                            groups.keys.map((element) => element.id!).toList(),
                        classId: widget.student?.classId ?? 1));
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
