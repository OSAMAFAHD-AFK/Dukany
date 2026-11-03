import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/models/shop_session_model.dart';
import '../../../../core/utils/functions/phone_normalizer.dart';
import '../../../../core/utils/local_database_service.dart';
import '../../../../core/utils/shop_session_storage.dart';
import '../data_sources/auth_remote_data_source.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl(this._remoteDataSource, this._shopSessionStorage, this._localDatabase);

  final AuthRemoteDataSource _remoteDataSource;
  final ShopSessionStorage _shopSessionStorage;
  final LocalDatabaseService _localDatabase;

  @override
  ShopSessionModel? getCachedSession() {
    final session = _shopSessionStorage.read();
    if (session == null || !_remoteDataSource.hasAuthSession) return null;
    return session;
  }

  @override
  Future<Either<Failure, ShopSessionModel>> login({required String phone, required String password}) async {
    final normalizedPhone = normalizeYemeniPhone(phone);
    if (normalizedPhone == null) return const Left(ValidationFailure('اكتب رقم الجوال بشكل صحيح'));
    if (password.isEmpty) return const Left(ValidationFailure('اكتب كلمة المرور'));

    try {
      await _remoteDataSource.signIn(phone: normalizedPhone, password: password);
      final shop = await _remoteDataSource.fetchOwnShop();
      if (shop == null) {
        await _remoteDataSource.signOut();
        return const Left(ValidationFailure('هذا الحساب غير مرتبط ببقالة، تواصل مع الدعم'));
      }

      // Another shop used this phone before → never mix their data.
      final previous = _shopSessionStorage.read();
      if (previous != null && previous.shopId != shop.shopId) await _localDatabase.clearAllData();

      await _shopSessionStorage.save(shop);
      return Right(shop);
    } catch (error) {
      return Left(ServerFailure.fromException(error));
    }
  }

  @override
  Future<Either<Failure, ShopSessionModel>> refreshSession() async {
    try {
      final shop = await _remoteDataSource.fetchOwnShop();
      if (shop == null) return const Left(SubscriptionInactiveFailure('انتهت الجلسة، سجّل الدخول مرة أخرى'));
      await _shopSessionStorage.save(shop);
      return Right(shop);
    } catch (error) {
      return Left(ServerFailure.fromException(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _localDatabase.clearAllData();
      await _deleteInvoicePhotos();
      await _shopSessionStorage.clear();
      try {
        await _remoteDataSource.signOut();
      } catch (_) {
        // Offline: the local session is already gone, that is enough.
      }
      return const Right(unit);
    } catch (_) {
      return const Left(LocalDatabaseFailure('تعذّر تسجيل الخروج'));
    }
  }

  Future<void> _deleteInvoicePhotos() async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(documents.path, 'invoices'));
    if (directory.existsSync()) await directory.delete(recursive: true);
  }
}
