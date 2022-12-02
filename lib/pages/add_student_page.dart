import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/student.dart';

class AddStudentPage extends StatefulWidget {
  final Function(Student) callback;
  const AddStudentPage({Key? key, required this.callback}) : super(key: key);

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
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
                  Navigator.pop(context);
                  widget.callback.call(Student(name: _controller.text));
                },
                icon: const Icon(Icons.save),
                label: const Text("Save")),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 16.0),
              child: TextButton(
                  onPressed: () {
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
