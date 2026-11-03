import 'dart:math';

final Random _random = Random.secure();

/// 8-digit numeric password: easy for a shop owner to type on a phone.
String generateShopPassword() => List.generate(8, (_) => _random.nextInt(10)).join();
