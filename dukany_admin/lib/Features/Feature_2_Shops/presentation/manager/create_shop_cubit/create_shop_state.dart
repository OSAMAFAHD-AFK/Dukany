part of 'create_shop_cubit.dart';

enum CreateShopStatus { initial, saving, success, failure }

class CreateShopState extends Equatable {
  const CreateShopState({
    this.status = CreateShopStatus.initial,
    this.createdShop,
    this.loginPhone,
    this.loginPassword,
    this.errorMessage,
  });

  final CreateShopStatus status;
  final ShopModel? createdShop;

  /// Shown once to the admin to hand over to the shop owner.
  final String? loginPhone;
  final String? loginPassword;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, createdShop, loginPhone, loginPassword, errorMessage];
}
