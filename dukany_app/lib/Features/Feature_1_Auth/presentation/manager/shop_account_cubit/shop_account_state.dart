part of 'shop_account_cubit.dart';

class ShopAccountState extends Equatable {
  const ShopAccountState({this.session, this.isBusy = false, this.isLoggedOut = false, this.message});

  final ShopSessionModel? session;
  final bool isBusy;
  final bool isLoggedOut;

  /// One-shot feedback (Arabic) shown as a snack bar.
  final String? message;

  ShopAccountState copyWith({ShopSessionModel? session, bool? isBusy, bool? isLoggedOut, String? message}) =>
      ShopAccountState(
        session: session ?? this.session,
        isBusy: isBusy ?? this.isBusy,
        isLoggedOut: isLoggedOut ?? this.isLoggedOut,
        message: message,
      );

  @override
  List<Object?> get props => [session, isBusy, isLoggedOut, message];
}
