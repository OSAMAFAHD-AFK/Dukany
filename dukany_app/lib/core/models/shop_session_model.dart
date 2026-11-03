import 'package:equatable/equatable.dart';

/// The logged-in shop, cached on the device so the app opens offline.
class ShopSessionModel extends Equatable {
  const ShopSessionModel({
    required this.shopId,
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.isActive,
    required this.subscriptionEndsAt,
    required this.lastCheckedAt,
  });

  final String shopId;
  final String shopName;
  final String ownerName;
  final String phone;
  final bool isActive;
  final DateTime subscriptionEndsAt;

  /// Last time the subscription was confirmed with Supabase.
  final DateTime lastCheckedAt;

  bool get canUseApp => isActive && subscriptionEndsAt.isAfter(DateTime.now());

  int get daysLeft => subscriptionEndsAt.difference(DateTime.now()).inDays;

  factory ShopSessionModel.fromShopRow(Map<String, dynamic> row) => ShopSessionModel(
    shopId: row['id'] as String,
    shopName: row['name'] as String,
    ownerName: row['owner_name'] as String,
    phone: row['phone'] as String,
    isActive: row['is_active'] as bool,
    subscriptionEndsAt: DateTime.parse(row['subscription_ends_at'] as String).toLocal(),
    lastCheckedAt: DateTime.now(),
  );

  factory ShopSessionModel.fromJson(Map<String, dynamic> json) => ShopSessionModel(
    shopId: json['shop_id'] as String,
    shopName: json['shop_name'] as String,
    ownerName: json['owner_name'] as String,
    phone: json['phone'] as String,
    isActive: json['is_active'] as bool,
    subscriptionEndsAt: DateTime.parse(json['subscription_ends_at'] as String),
    lastCheckedAt: DateTime.parse(json['last_checked_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'shop_id': shopId,
    'shop_name': shopName,
    'owner_name': ownerName,
    'phone': phone,
    'is_active': isActive,
    'subscription_ends_at': subscriptionEndsAt.toIso8601String(),
    'last_checked_at': lastCheckedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [shopId, shopName, ownerName, phone, isActive, subscriptionEndsAt, lastCheckedAt];
}
