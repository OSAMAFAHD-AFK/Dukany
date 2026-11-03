import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/models/shop_session_model.dart';

abstract class AuthRepo {
  /// Cached shop, available offline. Null when nobody is logged in.
  ShopSessionModel? getCachedSession();

  Future<Either<Failure, ShopSessionModel>> login({required String phone, required String password});

  /// Re-reads the subscription from Supabase (needs internet).
  Future<Either<Failure, ShopSessionModel>> refreshSession();

  /// Signs out and wipes this shop's data from the phone.
  Future<Either<Failure, Unit>> logout();
}
