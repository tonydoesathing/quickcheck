import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quickcheck/data/model/class.dart';
import 'package:quickcheck/data/repository/authentification_repository.dart';
import 'package:quickcheck/data/repository/cache_repository.dart';
import 'package:quickcheck/data/repository/class_repository.dart';

class ViewClassesPageBloc
    extends Bloc<ViewClassesPageEvent, ViewClassesPageState> {
  /// class repository
  final ClassRepository _classRepository;

  /// authentication repository
  final AuthenticationRepository _authenticationRepository;

  /// cache repository
  final CacheRepository _cacheRepository;

  ViewClassesPageBloc(this._classRepository, this._authenticationRepository,
      this._cacheRepository)
      : super(const LoadingClasses([])) {
    on<LoadClassesEvent>((event, emit) async {
      List<Class> classes = await _classRepository.getClasses();
      emit(DisplayClasses(List.from(classes)));
    });

    on<AddClassEvent>((event, emit) async {
      try {
        emit(LoadingClasses(state.classes));
        final List<Class> classes = List.from(state.classes);
        Class? newClass = await _classRepository.addClass(event.theClass);
        if (newClass != null) {
          classes.add(newClass);
          emit(DisplayClasses(classes));
        } else {
          emit(DisplayClassesError(
              state.classes, Exception("Could not add the class")));
        }
      } catch (e) {
        emit(DisplayClassesError(state.classes, e));
      }
    });

    on<LogoutEvent>((event, emit) async {
      final List<Class> classes = List.from(state.classes);
      // set loading
      emit(LoadingClasses(classes));

      // log out from auth
      await _authenticationRepository.logout();
      // clear cached token
      await _cacheRepository.putRecord("token", null);

      emit(LoggedOut(classes));
    });
  }
}

abstract class ViewClassesPageEvent extends Equatable {
  const ViewClassesPageEvent();

  @override
  List<Object> get props => [];
}

class LoadClassesEvent extends ViewClassesPageEvent {}

/// Logout
class LogoutEvent extends ViewClassesPageEvent {}

class AddClassEvent extends ViewClassesPageEvent {
  final Class theClass;

  const AddClassEvent(this.theClass);

  @override
  List<Object> get props => [theClass];
}

abstract class ViewClassesPageState extends Equatable {
  final List<Class> classes;
  const ViewClassesPageState(this.classes);

  @override
  List<Object> get props => [classes];
}

class LoadingClasses extends ViewClassesPageState {
  const LoadingClasses(super.classes);
}

class DisplayClasses extends ViewClassesPageState {
  const DisplayClasses(super.classes);
}

class LoggedOut extends ViewClassesPageState {
  const LoggedOut(super.classes);
}

class DisplayClassesError extends ViewClassesPageState {
  final Object exception;

  const DisplayClassesError(super.classes, this.exception);

  @override
  List<Object> get props => [classes, exception];
}
