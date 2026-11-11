import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:shortly_app/core/errors/exception.dart';
import 'package:shortly_app/core/errors/failure.dart';
import 'package:shortly_app/features/auth/data/datasources/auth_remote_datasources.dart';
import 'package:shortly_app/features/auth/data/models/auth_session_model.dart';
import 'package:shortly_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shortly_app/features/auth/domain/entities/auth_session.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late AuthRepositoryImpl repository;

  final testSessionModel = AuthSessionModel(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    userId: 'user-001',
    email: 'test@example.com',
  );

  const testSession = AuthSession(
    userId: 'user-001',
    email: 'test@example.com',
    accessToken: 'access-token',
  );

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  group('login', () {
    const email = 'test@example.com';
    const password = 'password123';

    test('returns AuthSession when login succeeds', () async {
      when(
        () => remoteDataSource.login(email: email, password: password),
      ).thenAnswer((_) async => testSessionModel);

      final result = await repository.login(email: email, password: password);

      expect(result, const Right<Failure, AuthSession>(testSession));

      verify(
        () => remoteDataSource.login(email: email, password: password),
      ).called(1);
    });

    test('returns AuthFailure when AuthException is thrown', () async {
      when(
        () => remoteDataSource.login(email: email, password: password),
      ).thenAnswer(
        (_) => Future.error(const AuthException('Invalid credentials')),
      );

      final result = await repository.login(email: email, password: password);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Invalid credentials');
      }, (_) => fail('Expected AuthFailure'));
    });

    test('returns ServerFailure when ServerException is thrown', () async {
      when(
        () => remoteDataSource.login(email: email, password: password),
      ).thenAnswer((_) => Future.error(const ServerException('Server error')));

      final result = await repository.login(email: email, password: password);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Server error');
      }, (_) => fail('Expected ServerFailure'));
    });

    test('returns UnknownFailure when unexpected error occurs', () async {
      when(
        () => remoteDataSource.login(email: email, password: password),
      ).thenAnswer((_) => Future.error(Exception('Unexpected error')));

      final result = await repository.login(email: email, password: password);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<UnknownFailure>());
      }, (_) => fail('Expected UnknownFailure'));
    });
  });

  group('register', () {
    const email = 'test@example.com';
    const password = 'password123';
    const username = 'testuser';

    test('returns AuthSession when register succeeds', () async {
      when(
        () => remoteDataSource.register(
          email: email,
          password: password,
          username: username,
        ),
      ).thenAnswer((_) async => testSessionModel);

      final result = await repository.register(
        email: email,
        password: password,
        username: username,
      );

      expect(result, const Right<Failure, AuthSession>(testSession));

      verify(
        () => remoteDataSource.register(
          email: email,
          password: password,
          username: username,
        ),
      ).called(1);
    });

    test('returns AuthFailure when AuthException is thrown', () async {
      when(
        () => remoteDataSource.register(
          email: email,
          password: password,
          username: username,
        ),
      ).thenAnswer(
        (_) => Future.error(const AuthException('Email already exists')),
      );

      final result = await repository.register(
        email: email,
        password: password,
        username: username,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Email already exists');
      }, (_) => fail('Expected AuthFailure'));
    });

    test('returns ServerFailure when ServerException is thrown', () async {
      when(
        () => remoteDataSource.register(
          email: email,
          password: password,
          username: username,
        ),
      ).thenAnswer((_) => Future.error(const ServerException('Server error')));

      final result = await repository.register(
        email: email,
        password: password,
        username: username,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Server error');
      }, (_) => fail('Expected ServerFailure'));
    });

    test('returns UnknownFailure when unexpected error occurs', () async {
      when(
        () => remoteDataSource.register(
          email: email,
          password: password,
          username: username,
        ),
      ).thenAnswer((_) => Future.error(Exception('Unexpected error')));

      final result = await repository.register(
        email: email,
        password: password,
        username: username,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<UnknownFailure>());
      }, (_) => fail('Expected UnknownFailure'));
    });
  });

  group('logout', () {
    test('returns Right(null) when logout succeeds', () async {
      when(() => remoteDataSource.logout()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result, const Right<Failure, void>(null));
      verify(() => remoteDataSource.logout()).called(1);
    });

    test('returns ServerFailure when ServerException is thrown', () async {
      when(
        () => remoteDataSource.logout(),
      ).thenAnswer((_) => Future.error(const ServerException('Logout failed')));

      final result = await repository.logout();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Logout failed');
      }, (_) => fail('Expected ServerFailure'));
    });

    test('returns UnknownFailure when unexpected error occurs', () async {
      when(
        () => remoteDataSource.logout(),
      ).thenAnswer((_) => Future.error(Exception('Unexpected error')));

      final result = await repository.logout();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<UnknownFailure>());
      }, (_) => fail('Expected UnknownFailure'));
    });
  });

  group('getCurrentSession', () {
    test('returns AuthSession when a session exists', () async {
      when(
        () => remoteDataSource.getCurrentSession(),
      ).thenAnswer((_) async => testSessionModel);

      final result = await repository.getCurrentSession();

      expect(result, const Right<Failure, AuthSession?>(testSession));

      verify(() => remoteDataSource.getCurrentSession()).called(1);
    });

    test('returns null when no session exists', () async {
      when(
        () => remoteDataSource.getCurrentSession(),
      ).thenAnswer((_) async => null);

      final result = await repository.getCurrentSession();

      expect(result, const Right<Failure, AuthSession?>(null));
    });

    test('returns UnknownFailure when an error occurs', () async {
      when(
        () => remoteDataSource.getCurrentSession(),
      ).thenAnswer((_) => Future.error(Exception('Session error')));

      final result = await repository.getCurrentSession();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<UnknownFailure>());
      }, (_) => fail('Expected UnknownFailure'));
    });
  });

  group('exchangeCode', () {
    const code = 'authorization-code';

    test('returns Right(null) when exchangeCode succeeds', () async {
      when(() => remoteDataSource.exchangeCode(code)).thenAnswer((_) async {});

      final result = await repository.exchangeCode(code);

      expect(result, const Right<Failure, void>(null));
      verify(() => remoteDataSource.exchangeCode(code)).called(1);
    });

    test('returns AuthFailure when AuthException is thrown', () async {
      when(
        () => remoteDataSource.exchangeCode(code),
      ).thenAnswer((_) => Future.error(const AuthException('Invalid code')));

      final result = await repository.exchangeCode(code);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Invalid code');
      }, (_) => fail('Expected AuthFailure'));
    });

    test('returns ServerFailure when ServerException is thrown', () async {
      when(() => remoteDataSource.exchangeCode(code)).thenAnswer(
        (_) => Future.error(const ServerException('Exchange failed')),
      );

      final result = await repository.exchangeCode(code);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Exchange failed');
      }, (_) => fail('Expected ServerFailure'));
    });

    test('returns UnknownFailure when unexpected error occurs', () async {
      when(
        () => remoteDataSource.exchangeCode(code),
      ).thenAnswer((_) => Future.error(Exception('Unexpected error')));

      final result = await repository.exchangeCode(code);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<UnknownFailure>());
      }, (_) => fail('Expected UnknownFailure'));
    });
  });
}
