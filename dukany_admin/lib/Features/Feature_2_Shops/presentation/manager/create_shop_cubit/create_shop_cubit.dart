import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/functions/phone_normalizer.dart';
import '../../../data/models/new_shop_input_model.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/repos/shops_repo.dart';

part 'create_shop_state.dart';

class CreateShopCubit extends Cubit<CreateShopState> {
  CreateShopCubit(this._shopsRepo) : super(const CreateShopState());

  final ShopsRepo _shopsRepo;

  Future<void> createShop({
    required String shopName,
    required String ownerName,
    required String phone,
    required String password,
    required int months,
    String? notes,
  }) async {
    final normalizedPhone = normalizeYemeniPhone(phone);
    final error = shopName.trim().length < 2
        ? 'اكتب اسم البقالة'
        : ownerName.trim().length < 2
        ? 'اكتب اسم صاحب البقالة'
        : normalizedPhone == null
        ? 'رقم الجوال غير صحيح'
        : password.length < 6
        ? 'كلمة المرور 6 أحرف على الأقل'
        : null;
    if (error != null) {
      emit(CreateShopState(status: CreateShopStatus.failure, errorMessage: error));
      return;
    }

    emit(const CreateShopState(status: CreateShopStatus.saving));
    final result = await _shopsRepo.createShop(
      NewShopInputModel(
        shopName: shopName.trim(),
        ownerName: ownerName.trim(),
        phone: normalizedPhone!,
        password: password,
        months: months,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      ),
    );
    result.fold(
      (failure) => emit(CreateShopState(status: CreateShopStatus.failure, errorMessage: failure.message)),
      (shop) => emit(
        CreateShopState(
          status: CreateShopStatus.success,
          createdShop: shop,
          loginPhone: normalizedPhone,
          loginPassword: password,
        ),
      ),
    );
  }
}
