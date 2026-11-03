import 'shop_model.dart';

enum ShopFilter {
  all('الكل'),
  active('نشطة'),
  expiringSoon('تنتهي قريباً'),
  expired('منتهية'),
  suspended('موقوفة');

  const ShopFilter(this.label);

  final String label;

  bool matches(ShopModel shop) => switch (this) {
    ShopFilter.all => true,
    ShopFilter.active => shop.canUseApp,
    ShopFilter.expiringSoon => shop.status == ShopStatus.expiringSoon,
    ShopFilter.expired => shop.status == ShopStatus.expired,
    ShopFilter.suspended => shop.status == ShopStatus.suspended,
  };
}
