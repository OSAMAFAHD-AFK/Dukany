import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repos/admin_auth_repo.dart';

/// Holds the signed-in admin's email; emits null after logout.
class AdminSessionCubit extends Cubit<String?> {
  AdminSessionCubit(this._authRepo) : super(_authRepo.currentEmail);

  final AdminAuthRepo _authRepo;

  Future<void> logout() async {
    await _authRepo.logout();
    emit(null);
  }
}
