
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:shortly_app/features/auth/domain/entities/auth_session.dart';
import 'package:shortly_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shortly_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:shortly_app/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:shortly_app/features/auth/presentation/bloc/login/login_event.dart';
import 'package:shortly_app/features/auth/presentation/bloc/login/login_state.dart';
import 'package:shortly_app/core/errors/failure.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late LoginUseCase loginUseCase;

  const testEmail = 'test@example.com';
  const testPassword = 'password123';

  const testSession = AuthSession(
    userId: 'user-001',
    email: testEmail,
    accessToken: 'test-access-token',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockAuthRepository);
  });

  group('LoginBloc', () {
    test('initial state is LoginInitial', () {
      final bloc = LoginBloc(loginUseCase: loginUseCase);

      expect(bloc.state, isA<LoginInitial>());

      bloc.close();
    });

    blocTest<LoginBloc, LoginState>(
      'emits [LoginLoading, LoginSuccess] when login succeeds',
      build: () {
        when(
          () => mockAuthRepository.login(
            email: testEmail,
            password: testPassword,
          ),
        ).thenAnswer((_) async => const Right(testSession));

        return LoginBloc(loginUseCase: loginUseCase);
      },
      act: (bloc) => bloc.add(
        const LoginSubmitted(
          email: testEmail,
          password: testPassword,
        ),
      ),
      expect: () => [
        isA<LoginLoading>(),
        isA<LoginSuccess>().having(
          (state) => state.session.email,
          'session email',
          testEmail,
        ),
      ],
      verify: (_) {
        verify(
          () => mockAuthRepository.login(
            email: testEmail,
            password: testPassword,
          ),
        ).called(1);
      },
    );

    blocTest<LoginBloc, LoginState>(
      'emits [LoginLoading, LoginFailure] when login fails',
      build: () {
        when(
          () => mockAuthRepository.login(
            email: testEmail,
            password: testPassword,
          ),
        ).thenAnswer(
          (_) async => Left(AuthFailure('Invalid email or password')),
        );

        return LoginBloc(loginUseCase: loginUseCase);
      },
      act: (bloc) => bloc.add(
        const LoginSubmitted(
          email: testEmail,
          password: testPassword,
        ),
      ),
      expect: () => [
        isA<LoginLoading>(),
        isA<LoginFailure>().having(
          (state) => state.message,
          'failure message',
          'Invalid email or password',
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [LoginInitial] when LoginReset is added',
      build: () => LoginBloc(loginUseCase: loginUseCase),
      act: (bloc) => bloc.add(const LoginReset()),
      expect: () => [isA<LoginInitial>()],
    );
  });
}
