import 'package:equatable/equatable.dart';

enum ShopStatus { active, expiringSoon, expired, suspended }

class ShopModel extends Equatable {
  const ShopModel({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.phone,
    required this.isActive,
    required this.subscriptionEndsAt,
    required this.createdAt,
    this.notes,
  });

  static const int expiringSoonDays = 7;

  final String id;
  final String name;
  final String ownerName;
  final String phone;

  /// Manual on/off switch controlled by the admin.
  final bool isActive;
  final DateTime subscriptionEndsAt;
  final DateTime createdAt;
  final String? notes;

  int get daysLeft => subscriptionEndsAt.difference(DateTime.now()).inDays;

  ShopStatus get status {
    if (!isActive) return ShopStatus.suspended;
    if (!subscriptionEndsAt.isAfter(DateTime.now())) return ShopStatus.expired;
    if (daysLeft <= expiringSoonDays) return ShopStatus.expiringSoon;
    return ShopStatus.active;
  }

  /// Can the shop use the app right now (what RLS also checks)?
  bool get canUseApp => status == ShopStatus.active || status == ShopStatus.expiringSoon;

  factory ShopModel.fromJson(Map<String, dynamic> json) => ShopModel(
    id: json['id'] as String,
    name: json['name'] as String,
    ownerName: json['owner_name'] as String,
    phone: json['phone'] as String,
    isActive: json['is_active'] as bool,
    subscriptionEndsAt: DateTime.parse(json['subscription_ends_at'] as String).toLocal(),
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    notes: json['notes'] as String?,
  );

  ShopModel copyWith({bool? isActive, DateTime? subscriptionEndsAt}) => ShopModel(
    id: id,
    name: name,
    ownerName: ownerName,
    phone: phone,
    isActive: isActive ?? this.isActive,
    subscriptionEndsAt: subscriptionEndsAt ?? this.subscriptionEndsAt,
    createdAt: createdAt,
    notes: notes,
  );

  @override
  List<Object?> get props => [id, name, ownerName, phone, isActive, subscriptionEndsAt, createdAt, notes];
}
