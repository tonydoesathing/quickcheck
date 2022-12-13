import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcheck/bloc/view_classes_page_bloc.dart';
import 'package:quickcheck/data/repository/class_repository.dart';

/// Displays all of the classes for a user
/// Tapping a class takes the user to that class's page
class ViewClassesPage extends StatelessWidget {
  const ViewClassesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ViewClassesPageBloc(context.read<ClassRepository>())
        ..add(LoadClassesEvent()),
      child: BlocConsumer<ViewClassesPageBloc, ViewClassesPageState>(
        listener: (context, state) {
          // on error, display
          if (state is DisplayClassesError) {
            throw state.exception;
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Classes"),
              actions: [
                TextButton(onPressed: () {}, child: const Text("Add Class"))
              ],
            ),
            body: (state is DisplayClasses)
                ? ListView.builder(
                    itemCount: state.classes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(state.classes[index].name),
                        trailing: const Icon(Icons.chevron_right),
                      );
                    },
                  )

                // bloc is loading; display progress indicator
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          );
        },
      ),
    );
  }
}
