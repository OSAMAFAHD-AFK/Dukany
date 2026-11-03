part of 'shops_cubit.dart';

enum ShopsStatus { loading, loaded, failure }

class ShopsState extends Equatable {
  const ShopsState({
    this.status = ShopsStatus.loading,
    this.shops = const [],
    this.filter = ShopFilter.all,
    this.query = '',
    this.busyShopIds = const {},
    this.errorMessage,
  });

  final ShopsStatus status;
  final List<ShopModel> shops;
  final ShopFilter filter;
  final String query;

  /// Shops with an update in flight (their row shows a spinner).
  final Set<String> busyShopIds;
  final String? errorMessage;

  List<ShopModel> get visibleShops {
    final search = query.trim().toLowerCase();
    return shops.where((shop) {
      if (!filter.matches(shop)) return false;
      if (search.isEmpty) return true;
      return shop.name.toLowerCase().contains(search) ||
          shop.ownerName.toLowerCase().contains(search) ||
          shop.phone.contains(search);
    }).toList();
  }

  int countOf(ShopFilter filter) => shops.where(filter.matches).length;

  ShopsState copyWith({
    ShopsStatus? status,
    List<ShopModel>? shops,
    ShopFilter? filter,
    String? query,
    Set<String>? busyShopIds,
    String? errorMessage,
  }) => ShopsState(
    status: status ?? this.status,
    shops: shops ?? this.shops,
    filter: filter ?? this.filter,
    query: query ?? this.query,
    busyShopIds: busyShopIds ?? this.busyShopIds,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, shops, filter, query, busyShopIds, errorMessage];
}
