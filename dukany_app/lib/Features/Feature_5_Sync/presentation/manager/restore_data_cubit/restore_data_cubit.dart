import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repos/sync_repo.dart';

part 'restore_data_state.dart';

/// Runs right after login: brings the shop's data back from Supabase
/// when this phone has none (new phone, reinstall, after logout).
class RestoreDataCubit extends Cubit<RestoreDataState> {
  RestoreDataCubit(this._syncRepo) : super(const RestoreDataState());

  final SyncRepo _syncRepo;

  Future<void> restore() async {
    emit(const RestoreDataState());
    final result = await _syncRepo.restoreFromCloudIfNeeded();
    result.fold(
      (failure) => emit(RestoreDataState(status: RestoreDataStatus.failure, errorMessage: failure.message)),
      (_) => emit(const RestoreDataState(status: RestoreDataStatus.done)),
    );
  }
}
