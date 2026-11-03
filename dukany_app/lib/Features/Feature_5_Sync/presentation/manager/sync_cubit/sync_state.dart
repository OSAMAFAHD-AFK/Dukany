part of 'sync_cubit.dart';

enum SyncPhase { idle, uploading, uploaded, failed }

class SyncState extends Equatable {
  const SyncState({
    this.phase = SyncPhase.idle,
    this.counts = PendingCountsModel.zero,
    this.messages = const [],
    this.report,
    this.isSendingAll = false,
    this.isSubscriptionInactive = false,
    this.errorMessage,
  });

  final SyncPhase phase;
  final PendingCountsModel counts;
  final List<PendingMessageModel> messages;
  final SyncReportModel? report;

  /// True while WhatsApp is being opened customer after customer.
  final bool isSendingAll;
  final bool isSubscriptionInactive;
  final String? errorMessage;

  SyncState copyWith({
    SyncPhase? phase,
    PendingCountsModel? counts,
    List<PendingMessageModel>? messages,
    SyncReportModel? report,
    bool? isSendingAll,
    bool? isSubscriptionInactive,
    String? errorMessage,
  }) => SyncState(
    phase: phase ?? this.phase,
    counts: counts ?? this.counts,
    messages: messages ?? this.messages,
    report: report ?? this.report,
    isSendingAll: isSendingAll ?? this.isSendingAll,
    isSubscriptionInactive: isSubscriptionInactive ?? this.isSubscriptionInactive,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [phase, counts, messages, report, isSendingAll, isSubscriptionInactive, errorMessage];
}
