class NewShopInputModel {
  const NewShopInputModel({
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.password,
    required this.months,
    this.notes,
  });

  final String shopName;
  final String ownerName;

  /// Already normalized (9677xxxxxxxx).
  final String phone;
  final String password;
  final int months;
  final String? notes;

  Map<String, dynamic> toFunctionBody() => {
    'action': 'create_shop',
    'shop_name': shopName,
    'owner_name': ownerName,
    'phone': phone,
    'password': password,
    'months': months,
    'notes': notes,
  };
}
