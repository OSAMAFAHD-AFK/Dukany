import 'package:equatable/equatable.dart';

class PendingCountsModel extends Equatable {
  const PendingCountsModel({required this.operations, required this.messages});

  /// Rows saved on the phone but not yet uploaded to Supabase.
  final int operations;

  /// WhatsApp notices not yet sent.
  final int messages;

  static const PendingCountsModel zero = PendingCountsModel(operations: 0, messages: 0);

  bool get hasWork => operations > 0 || messages > 0;

  /// Number shown on the home sync button.
  int get badgeCount => operations > 0 ? operations : messages;

  @override
  List<Object?> get props => [operations, messages];
}
