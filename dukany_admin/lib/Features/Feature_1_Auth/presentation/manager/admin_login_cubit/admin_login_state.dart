part of 'admin_login_cubit.dart';

sealed class AdminLoginState extends Equatable {
  const AdminLoginState();

  @override
  List<Object?> get props => [];
}

final class AdminLoginInitial extends AdminLoginState {
  const AdminLoginInitial();
}

final class AdminLoginLoading extends AdminLoginState {
  const AdminLoginLoading();
}

final class AdminLoginSuccess extends AdminLoginState {
  const AdminLoginSuccess();
}

final class AdminLoginFailure extends AdminLoginState {
  const AdminLoginFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
