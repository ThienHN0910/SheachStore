import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:src/blocs/auth/auth_bloc.dart';
import 'package:src/blocs/auth/auth_event.dart';
import 'package:src/blocs/auth/auth_state.dart';
import 'package:src/models/auth_models.dart';

import '../helpers/mocks.mocks.dart';
import '../helpers/test_helpers.dart';

class MockFirebaseAuthException extends Mock implements firebase_auth.FirebaseAuthException {
  @override
  final String message;
  @override
  final String code;

  MockFirebaseAuthException({required this.message, this.code = 'error'});
}

void main() {
  group('[BLoC Test] AuthBloc', () {
    late MockAuthService mockAuthService;
    late AuthBloc authBloc;

    final mockUser = createMockUserResponse();
    final mockAuthResponse = AuthResponse(user: mockUser);

    setUp(() {
      mockAuthService = MockAuthService();
      authBloc = AuthBloc(authService: mockAuthService);
    });

    tearDown(() {
      authBloc.close();
    });

    test('TC-B01: Trạng thái ban đầu là AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    blocTest<AuthBloc, AuthState>(
      'TC-B02: AppStarted → Authenticated khi user đã đăng nhập',
      build: () {
        when(mockAuthService.getProfile()).thenAnswer((_) async => mockUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [Authenticated(mockUser)],
      verify: (_) {
        verify(mockAuthService.getProfile()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'TC-B03: AppStarted → Unauthenticated khi user chưa đăng nhập',
      build: () {
        when(mockAuthService.getProfile()).thenThrow(Exception('No user'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'TC-B04: LoginRequested → AuthLoading → Authenticated khi đăng nhập thành công',
      build: () {
        when(mockAuthService.login(email: 'test@example.com', password: 'password'))
            .thenAnswer((_) async => mockAuthResponse);
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(email: 'test@example.com', password: 'password')),
      expect: () => [AuthLoading(), Authenticated(mockUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'TC-B05: LoginRequested → AuthLoading → AuthError khi sai mật khẩu',
      build: () {
        when(mockAuthService.login(email: 'test@example.com', password: 'wrong'))
            .thenThrow(MockFirebaseAuthException(message: 'Invalid password'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(email: 'test@example.com', password: 'wrong')),
      expect: () => [AuthLoading(), const AuthError('Invalid password')],
    );

    blocTest<AuthBloc, AuthState>(
      'TC-B06: RegisterRequested → AuthLoading → Authenticated khi đăng ký thành công',
      build: () {
        when(mockAuthService.register(
          email: 'test@example.com',
          password: 'password',
          fullName: 'Test User',
        )).thenAnswer((_) async => mockAuthResponse);
        return authBloc;
      },
      act: (bloc) => bloc.add(const RegisterRequested(
        email: 'test@example.com',
        password: 'password',
        fullName: 'Test User',
      )),
      expect: () => [AuthLoading(), Authenticated(mockUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'TC-B07: GoogleSignInRequested → AuthLoading → Authenticated khi đăng nhập Google thành công',
      build: () {
        when(mockAuthService.signInWithGoogle()).thenAnswer((_) async => mockAuthResponse);
        return authBloc;
      },
      act: (bloc) => bloc.add(GoogleSignInRequested()),
      expect: () => [AuthLoading(), Authenticated(mockUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'TC-B08: LogoutRequested → Unauthenticated khi đăng xuất',
      build: () {
        when(mockAuthService.logout()).thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [Unauthenticated()],
      verify: (_) {
        verify(mockAuthService.logout()).called(1);
      },
    );
  });
}
