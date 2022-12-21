import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcheck/bloc/view_classes_page_bloc.dart';
import 'package:quickcheck/data/model/class.dart';
import 'package:quickcheck/data/repository/class_repository.dart';
import 'package:quickcheck/pages/add_class_page.dart';
import 'package:quickcheck/pages/class_home_page.dart';

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
                  TextButton(
                      onPressed: () {
                        BuildContext blocContext = context;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddClassPage(
                                callback: (theClass) {
                                  // on save button in AddStudentPage, add the student to the repo
                                  blocContext
                                      .read<ViewClassesPageBloc>()
                                      .add(AddClassEvent(theClass));
                                },
                              ),
                            ));
                      },
                      child: const Text("Add Class"))
                ],
              ),
              body: Stack(
                fit: StackFit.expand,
                children: [
                  // display loading
                  if (state is LoadingClasses)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Center(
                          child: CircularProgressIndicator(),
                        )
                      ],
                    ),
                  if (state.classes.isEmpty && state is DisplayClasses)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: SizedBox(
                          width: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Text(
                                    "Add a class!",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                    overflow: TextOverflow.clip,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 8.0, top: 2),
                                child: Icon(
                                  size: 33,
                                  Icons.arrow_upward,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .color,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  // list classes
                  ListView.builder(
                    itemCount: state.classes.length,
                    padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 4.0),
                    itemBuilder: (context, index) {
                      return Card(
                        clipBehavior: Clip.hardEdge,
                        child: ListTile(
                          title: Text(state.classes[index].name),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // navigate to the appropriate class's home page
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClassHomePage(
                                    theClass: state.classes[index],
                                  ),
                                ));
                          },
                        ),
                      );
                    },
                  ),
                ],
              ));
        },
      ),
    );
  }
}
