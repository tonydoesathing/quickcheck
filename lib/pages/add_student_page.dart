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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onPressed: () {
                  // go to previous page
                  // and call the callback
                  Navigator.pop(context);
                  widget.callback.call(Student(name: _controller.text));
                },
                icon: const Icon(Icons.save),
                label: const Text("Save")),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 16.0),
              child: TextButton(
                  onPressed: () {
                    // go to previous page on click
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                  )),
            )
          ],
        ),
      )),
    );
  }
}
