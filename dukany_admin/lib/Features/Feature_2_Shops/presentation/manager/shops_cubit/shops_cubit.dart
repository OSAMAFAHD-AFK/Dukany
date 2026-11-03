import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failures.dart';
import '../../../data/models/shop_filter.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/repos/shops_repo.dart';

part 'shops_state.dart';

class ShopsCubit extends Cubit<ShopsState> {
  ShopsCubit(this._shopsRepo) : super(const ShopsState());

  final ShopsRepo _shopsRepo;

  Future<void> loadShops() async {
    emit(state.copyWith(status: ShopsStatus.loading));
    final result = await _shopsRepo.getShops();
    result.fold(
      (failure) => emit(state.copyWith(status: ShopsStatus.failure, errorMessage: failure.message)),
      (shops) => emit(state.copyWith(status: ShopsStatus.loaded, shops: shops)),
    );
  }

  void changeFilter(ShopFilter filter) => emit(state.copyWith(filter: filter));

  void search(String query) => emit(state.copyWith(query: query));

  /// Adds a shop created through the dialog to the top of the list.
  void addCreatedShop(ShopModel shop) => emit(state.copyWith(shops: [shop, ...state.shops]));

  /// Returns an error message, or null on success.
  Future<String?> setActive(ShopModel shop, bool isActive) =>
      _updateShop(shop, () => _shopsRepo.setActive(shop, isActive));

  Future<String?> extendSubscription(ShopModel shop, int months) =>
      _updateShop(shop, () => _shopsRepo.extendSubscription(shop, months));

  Future<String?> resetPassword(ShopModel shop, String newPassword) async {
    final result = await _shopsRepo.resetPassword(shop, newPassword);
    return result.fold((failure) => failure.message, (_) => null);
  }

  Future<String?> _updateShop(ShopModel shop, Future<Either<Failure, ShopModel>> Function() update) async {
    emit(state.copyWith(busyShopIds: {...state.busyShopIds, shop.id}));
    final result = await update();
    final busy = {...state.busyShopIds}..remove(shop.id);
    return result.fold(
      (failure) {
        emit(state.copyWith(busyShopIds: busy));
        return failure.message;
      },
      (updated) {
        emit(
          state.copyWith(
            busyShopIds: busy,
            shops: [for (final item in state.shops) item.id == updated.id ? updated : item],
          ),
        );
        return null;
      },
    );
  }
}
