import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../data_sources/shops_remote_data_source.dart';
import '../models/new_shop_input_model.dart';
import '../models/shop_model.dart';
import 'shops_repo.dart';

class ShopsRepoImpl implements ShopsRepo {
  ShopsRepoImpl(this._remoteDataSource);

  final ShopsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ShopModel>>> getShops() => _guard(_remoteDataSource.fetchShops);

  @override
  Future<Either<Failure, ShopModel>> setActive(ShopModel shop, bool isActive) =>
      _guard(() => _remoteDataSource.setActive(shop.id, isActive));

  @override
  Future<Either<Failure, ShopModel>> extendSubscription(ShopModel shop, int months) {
    final now = DateTime.now();
    final base = shop.subscriptionEndsAt.isAfter(now) ? shop.subscriptionEndsAt : now;
    final newEnd = DateTime(base.year, base.month + months, base.day, base.hour, base.minute);
    return _guard(() => _remoteDataSource.setSubscriptionEnd(shop.id, newEnd));
  }

  @override
  Future<Either<Failure, ShopModel>> createShop(NewShopInputModel input) =>
      _guard(() => _remoteDataSource.createShop(input));

  @override
  Future<Either<Failure, Unit>> resetPassword(ShopModel shop, String newPassword) async {
    if (newPassword.length < 6) return const Left(ValidationFailure('كلمة المرور 6 أحرف على الأقل'));
    return _guard(() async {
      await _remoteDataSource.resetPassword(shop.id, newPassword);
      return unit;
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (error) {
      return Left(ServerFailure.fromException(error));
    }
  }
}
