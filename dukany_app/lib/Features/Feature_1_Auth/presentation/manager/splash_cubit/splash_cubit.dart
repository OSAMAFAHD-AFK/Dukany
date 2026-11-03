import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repos/auth_repo.dart';

part 'splash_state.dart';

/// Decides where the app opens — works fully offline thanks to the
/// cached subscription; refreshes it in the background when online.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._authRepo) : super(const SplashDeciding());

  final AuthRepo _authRepo;

  Future<void> decideStartDestination() async {
    // Short pause so the logo does not just flash.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final cached = _authRepo.getCachedSession();
    if (cached == null) return emit(const SplashDecided(SplashDestination.login));

    if (cached.canUseApp) {
      emit(const SplashDecided(SplashDestination.home));
      _authRepo.refreshSession(); // fire-and-forget; next launch uses the result
      return;
    }

    // Cached says expired: maybe the admin just renewed it — check online.
    final refreshed = await _authRepo.refreshSession();
    final session = refreshed.getOrElse(() => cached);
    emit(SplashDecided(session.canUseApp ? SplashDestination.home : SplashDestination.subscriptionEnded));
  }
}
