import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/dashboard_summary_model.dart';
import '../../../data/repos/home_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._homeRepo) : super(const HomeLoading()) {
    _changesSubscription = _homeRepo.changes.listen((_) => loadSummary());
  }

  final HomeRepo _homeRepo;
  late final StreamSubscription<void> _changesSubscription;

  Future<void> loadSummary() async {
    final result = await _homeRepo.getDashboardSummary();
    if (isClosed) return;
    result.fold((failure) => emit(HomeFailure(failure.message)), (summary) => emit(HomeLoaded(summary)));
  }

  @override
  Future<void> close() {
    _changesSubscription.cancel();
    return super.close();
  }
}
