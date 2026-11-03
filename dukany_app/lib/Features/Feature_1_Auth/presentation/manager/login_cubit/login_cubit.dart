import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/models/shop_session_model.dart';
import '../../../data/repos/auth_repo.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepo) : super(const LoginInitial());

  final AuthRepo _authRepo;

  Future<void> login({required String phone, required String password}) async {
    if (state is LoginLoading) return;
    emit(const LoginLoading());
    final result = await _authRepo.login(phone: phone, password: password);
    result.fold((failure) => emit(LoginFailure(failure.message)), (session) => emit(LoginSuccess(session)));
  }
}
