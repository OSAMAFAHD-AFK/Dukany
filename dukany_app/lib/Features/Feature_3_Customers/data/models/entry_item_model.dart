import 'package:equatable/equatable.dart';

/// One line the shop owner types by hand, e.g. "فاصوليا — 500".
class EntryItemModel extends Equatable {
  const EntryItemModel({required this.name, required this.price});

  final String name;
  final double price;

  factory EntryItemModel.fromJson(Map<String, dynamic> json) =>
      EntryItemModel(name: json['name'] as String, price: (json['price'] as num).toDouble());

  Map<String, dynamic> toJson() => {'name': name, 'price': price};

  @override
  List<Object?> get props => [name, price];
}
