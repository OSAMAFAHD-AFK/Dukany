import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repos/admin_auth_repo.dart';

part 'admin_login_state.dart';

class AdminLoginCubit extends Cubit<AdminLoginState> {
  AdminLoginCubit(this._authRepo) : super(const AdminLoginInitial());

  final AdminAuthRepo _authRepo;

  Future<void> login({required String email, required String password}) async {
    if (state is AdminLoginLoading) return;
    emit(const AdminLoginLoading());
    final result = await _authRepo.login(email: email, password: password);
    result.fold((failure) => emit(AdminLoginFailure(failure.message)), (_) => emit(const AdminLoginSuccess()));
  }
}
