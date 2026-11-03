import 'package:equatable/equatable.dart';

/// A WhatsApp notice waiting to be sent to a customer.
class PendingMessageModel extends Equatable {
  const PendingMessageModel({
    required this.id,
    required this.recipientName,
    required this.phone,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String recipientName;
  final String phone;
  final String body;
  final DateTime createdAt;

  factory PendingMessageModel.fromDb(Map<String, Object?> row) => PendingMessageModel(
    id: row['id'] as String,
    recipientName: row['recipient_name'] as String,
    phone: row['phone'] as String,
    body: row['body'] as String,
    createdAt: DateTime.parse(row['created_at'] as String),
  );

  @override
  List<Object?> get props => [id, recipientName, phone, body, createdAt];
}
