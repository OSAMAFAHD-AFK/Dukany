import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

abstract class AdminAuthRepo {
  String? get currentEmail;

  Future<Either<Failure, Unit>> login({required String email, required String password});

  /// True only if a session exists AND the user is in public.admins.
  Future<bool> hasValidAdminSession();

  Future<void> logout();
}
