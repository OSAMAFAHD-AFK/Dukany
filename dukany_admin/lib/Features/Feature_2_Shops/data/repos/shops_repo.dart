import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../models/new_shop_input_model.dart';
import '../models/shop_model.dart';

abstract class ShopsRepo {
  Future<Either<Failure, List<ShopModel>>> getShops();

  /// Suspend (false) or re-activate (true) a shop.
  Future<Either<Failure, ShopModel>> setActive(ShopModel shop, bool isActive);

  /// Adds [months] starting from today, or from the current end date if
  /// the subscription is still running (no paid days are lost).
  Future<Either<Failure, ShopModel>> extendSubscription(ShopModel shop, int months);

  Future<Either<Failure, ShopModel>> createShop(NewShopInputModel input);

  Future<Either<Failure, Unit>> resetPassword(ShopModel shop, String newPassword);
}
