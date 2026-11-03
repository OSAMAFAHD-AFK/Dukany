import 'package:dukany_admin/Features/Feature_2_Shops/data/models/shop_filter.dart';
import 'package:dukany_admin/Features/Feature_2_Shops/data/models/shop_model.dart';
import 'package:flutter_test/flutter_test.dart';

ShopModel _shop({required bool isActive, required Duration endsIn}) => ShopModel(
  id: 'id',
  name: 'بقالة',
  ownerName: 'مالك',
  phone: '967777123456',
  isActive: isActive,
  subscriptionEndsAt: DateTime.now().add(endsIn),
  createdAt: DateTime.now(),
);

void main() {
  test('status follows the same rules as RLS (active + not expired)', () {
    expect(_shop(isActive: true, endsIn: const Duration(days: 30)).status, ShopStatus.active);
    expect(_shop(isActive: true, endsIn: const Duration(days: 3)).status, ShopStatus.expiringSoon);
    expect(_shop(isActive: true, endsIn: const Duration(days: -1)).status, ShopStatus.expired);
    expect(_shop(isActive: false, endsIn: const Duration(days: 30)).status, ShopStatus.suspended);
  });

  test('active filter includes shops expiring soon', () {
    final soon = _shop(isActive: true, endsIn: const Duration(days: 2));
    expect(ShopFilter.active.matches(soon), isTrue);
    expect(ShopFilter.suspended.matches(soon), isFalse);
  });
}
