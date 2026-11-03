import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failures.dart';
import '../../../data/models/pending_counts_model.dart';
import '../../../data/models/pending_message_model.dart';
import '../../../data/models/sync_report_model.dart';
import '../../../data/repos/sync_repo.dart';

part 'sync_state.dart';

/// The "upload & send" screen:
/// 1) upload everything saved offline to Supabase,
/// 2) then open WhatsApp for each queued customer message, one after
///    another (the next one opens when the owner comes back to the app).
class SyncCubit extends Cubit<SyncState> {
  SyncCubit(this._syncRepo) : super(const SyncState());

  final SyncRepo _syncRepo;

  Future<void> loadQueue() async {
    final counts = await _syncRepo.getPendingCounts();
    final messages = await _syncRepo.getUnsentMessages();
    if (isClosed) return;
    emit(
      state.copyWith(counts: counts.getOrElse(() => state.counts), messages: messages.getOrElse(() => state.messages)),
    );
  }

  Future<void> startSync() async {
    if (state.phase == SyncPhase.uploading) return;
    emit(state.copyWith(phase: SyncPhase.uploading, isSendingAll: false));
    final result = await _syncRepo.uploadPendingData();
    if (isClosed) return;

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          phase: SyncPhase.failed,
          errorMessage: failure.message,
          isSubscriptionInactive: failure is SubscriptionInactiveFailure,
        ),
      ),
      (report) async {
        emit(state.copyWith(phase: SyncPhase.uploaded, report: report));
        await loadQueue();
        if (state.messages.isNotEmpty) await startSendingAll();
      },
    );
  }

  Future<void> startSendingAll() async {
    if (state.messages.isEmpty) return;
    emit(state.copyWith(isSendingAll: true));
    await _sendNext();
  }

  void stopSendingAll() => emit(state.copyWith(isSendingAll: false));

  /// Called by the view when the owner returns from WhatsApp.
  Future<void> onAppResumed() async {
    await loadQueue();
    if (state.isSendingAll) await _sendNext();
  }

  Future<String?> sendMessage(PendingMessageModel message) async {
    final result = await _syncRepo.sendMessage(message);
    return result.fold((failure) => failure.message, (_) => null);
  }

  Future<void> dismissMessage(PendingMessageModel message) async {
    await _syncRepo.dismissMessage(message);
    await loadQueue();
  }

  Future<void> _sendNext() async {
    if (state.messages.isEmpty) {
      emit(state.copyWith(isSendingAll: false));
      return;
    }
    final error = await sendMessage(state.messages.first);
    if (error != null) emit(state.copyWith(isSendingAll: false, errorMessage: error));
  }
}
