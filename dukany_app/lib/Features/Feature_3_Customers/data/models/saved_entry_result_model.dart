import 'customer_entry_model.dart';

/// What the UI needs right after saving a debt or a payment:
/// the new balance, and the WhatsApp message that was queued (if the
/// customer has a phone) so it can be sent immediately when online.
class SavedEntryResultModel {
  const SavedEntryResultModel({
    required this.entry,
    required this.newBalance,
    this.queuedMessageId,
    this.messagePhone,
    this.messageBody,
  });

  final CustomerEntryModel entry;
  final double newBalance;
  final String? queuedMessageId;
  final String? messagePhone;
  final String? messageBody;

  bool get hasQueuedMessage => queuedMessageId != null && messagePhone != null && messageBody != null;
}
