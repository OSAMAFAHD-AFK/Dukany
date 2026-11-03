import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/pending_counts_model.dart';
import '../../../data/repos/sync_repo.dart';

/// App-wide counter behind the badge on the home "upload & send" button.
/// Recounts automatically after every local write.
class SyncBadgeCubit extends Cubit<PendingCountsModel> {
  SyncBadgeCubit(this._syncRepo) : super(PendingCountsModel.zero) {
    _changesSubscription = _syncRepo.changes.listen((_) => refresh());
    refresh();
  }

  final SyncRepo _syncRepo;
  late final StreamSubscription<void> _changesSubscription;

  Future<void> refresh() async {
    final result = await _syncRepo.getPendingCounts();
    if (!isClosed) result.fold((_) {}, emit);
  }

  @override
  Future<void> close() {
    _changesSubscription.cancel();
    return super.close();
  }
}
