import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/models/shop_session_model.dart';
import '../../../data/repos/auth_repo.dart';

part 'shop_account_state.dart';

/// Subscription info, "check again" and logout — used by the account
/// sheet on Home and by the "subscription ended" screen.
class ShopAccountCubit extends Cubit<ShopAccountState> {
  ShopAccountCubit(this._authRepo) : super(ShopAccountState(session: _authRepo.getCachedSession()));

  final AuthRepo _authRepo;

  Future<void> checkSubscriptionAgain() async {
    emit(state.copyWith(isBusy: true));
    final result = await _authRepo.refreshSession();
    result.fold(
      (failure) => emit(state.copyWith(isBusy: false, message: failure.message)),
      (session) => emit(
        state.copyWith(
          isBusy: false,
          session: session,
          message: session.canUseApp ? 'الاشتراك فعّال ✓' : 'الاشتراك ما زال موقوفاً',
        ),
      ),
    );
  }

  Future<void> logout() async {
    emit(state.copyWith(isBusy: true));
    final result = await _authRepo.logout();
    result.fold(
      (failure) => emit(state.copyWith(isBusy: false, message: failure.message)),
      (_) => emit(state.copyWith(isBusy: false, isLoggedOut: true)),
    );
  }
}
