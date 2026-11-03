import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../data_sources/admin_auth_remote_data_source.dart';
import 'admin_auth_repo.dart';

class AdminAuthRepoImpl implements AdminAuthRepo {
  AdminAuthRepoImpl(this._remoteDataSource);

  final AdminAuthRemoteDataSource _remoteDataSource;

  @override
  String? get currentEmail => _remoteDataSource.currentEmail;

  @override
  Future<Either<Failure, Unit>> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return const Left(ValidationFailure('اكتب البريد وكلمة المرور'));
    }
    try {
      await _remoteDataSource.signIn(email: email, password: password);
      if (!await _remoteDataSource.isCurrentUserAdmin()) {
        // A shop owner (or anyone else) must never stay signed in here.
        await _remoteDataSource.signOut();
        return const Left(ValidationFailure('هذا الحساب ليس حساب مشرف'));
      }
      return const Right(unit);
    } catch (error) {
      return Left(ServerFailure.fromException(error));
    }
  }

  @override
  Future<bool> hasValidAdminSession() async {
    if (!_remoteDataSource.hasSession) return false;
    try {
      return await _remoteDataSource.isCurrentUserAdmin();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.signOut();
    } catch (_) {
      // Local session is cleared even if the network call fails.
    }
  }
}
