import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ttd_bloc/models/credentials.dart';
import 'package:ttd_bloc/models/user.dart';
import 'package:ttd_bloc/services/auth_service.dart';

class AuthState {}

class InitialState extends AuthState{}
class LoadingState extends AuthState {}

class UnresolvedState extends AuthState {}

class AuthenticatedState extends AuthState {
  User user;

  AuthenticatedState(this.user);
}
class SignOutEvent extends AuthEvent{}

class UnauthenticatedState extends AuthState {}

class AuthEvent {}

class RestoreAuthEvent extends AuthEvent {}

class SignInEvent extends AuthEvent {
  Credentials credentials;
  SignInEvent(this.credentials);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService);
  @override
  AuthState get initialState => UnresolvedState();

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    switch (event.runtimeType) {
      case SignInEvent:
        yield LoadingState();
        yield await signIn((event as SignInEvent).credentials);
        break;
      case RestoreAuthEvent:
        yield LoadingState();
        yield await restoreAuth();
        break;
      case SignOutEvent:
        await authService.signOut();
        yield UnauthenticatedState();
        break;

    }
  }

  Future<AuthState> signIn(Credentials credentials) async {
    final user = await authService.signIn(credentials);
    if (user == null) {
      return UnauthenticatedState();
    } else {
      return AuthenticatedState(user);
    }
  }

  Future<AuthState> restoreAuth() async {
    final user = await authService.readAuthFromStorage();
    if (user == null) {
      return UnauthenticatedState();
    } else {
      return AuthenticatedState(user);
    }
  }
}
