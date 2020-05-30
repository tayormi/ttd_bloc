import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';
import 'package:ttd_bloc/blocs/auth_bloc.dart';
import 'package:ttd_bloc/models/credentials.dart';
import 'package:ttd_bloc/models/user.dart';
import 'package:ttd_bloc/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

final mockUser = User('42', 'testuser');
final mockCorrectCredentials = Credentials('username', 'password');

Matcher isAuthenticatedState(User user) {
  return const TypeMatcher<AuthenticatedState>()
      .having((state) => state.user, 'user', user);
}

void main() {
  AuthBloc bloc;
  AuthService authService;

  setUp(() {
    authService = MockAuthService();
    bloc = AuthBloc(authService);
  });

  tearDown(() {
    bloc.close();
  });
  group(
      'AuthBloc',
      () => {
            test('has unresolved initial state',
                () => {expect(bloc.initialState, isA<UnresolvedState>())})
          });
  group('if user wasn\'t previously authenticated', () {
    blocTest<AuthBloc, AuthEvent, AuthState>(
      'emits LoadingState, then AuthenticatedState when SignInEvent was added with correct credentials',
      build: () async => bloc,
      act: (bloc) async {
        when(authService.signIn(mockCorrectCredentials))
            .thenAnswer((_) async => mockUser);

        bloc.add(SignInEvent(mockCorrectCredentials));
      },
      expect: [isA<LoadingState>(), isAuthenticatedState(mockUser)],
    );
  });
  // 'emits LoadingState, then UnauthenticatedState when SignInEvent was added with wrong credentials'
  group('If user was previously authenticated', () => {
    blocTest<AuthBloc, AuthEvent, AuthState>('emits LoadingState, then AuthenticatedState when RestoreEvent was added', 
    build: () async => bloc,
    act: (bloc) async {
      when(authService.readAuthFromStorage()).thenAnswer((_) async => mockUser);
      bloc.add(RestoreAuthEvent());
    },
    expect: [isA<LoadingState>(), isAuthenticatedState(mockUser)]
    )
    
  });
  group('If user wants to signout', () => {
    blocTest<AuthBloc, AuthEvent, AuthState>('calls signout of AuthService and emits UnAuthenticated when the SignOutEvent is added', 
    build: () async => bloc,
    act: (bloc) async {
      bloc.add(SignOutEvent());
    },
    verify: (bloc) async {
      final state = bloc.state;
      if(state is UnauthenticatedState) {
        expect(verify(authService.signOut()).callCount, 1);
      }
    },
    expect: [isA<UnauthenticatedState>()]
    )
  });

  //
}
