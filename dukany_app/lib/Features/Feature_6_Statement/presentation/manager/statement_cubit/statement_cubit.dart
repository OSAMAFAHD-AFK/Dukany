import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/models/party_type.dart';
import '../../../data/models/statement_model.dart';
import '../../../data/models/statement_period.dart';
import '../../../data/repos/statement_repo.dart';

part 'statement_state.dart';

class StatementCubit extends Cubit<StatementState> {
  StatementCubit(this._statementRepo, {required this.partyType, required this.partyId}) : super(const StatementState());

  final StatementRepo _statementRepo;
  final PartyType partyType;
  final String partyId;

  Future<void> loadStatement() async {
    emit(state.copyWith(status: StatementStatus.loading));
    final result = await _statementRepo.getStatement(partyType: partyType, partyId: partyId, period: state.period);
    result.fold(
      (failure) => emit(state.copyWith(status: StatementStatus.failure, errorMessage: failure.message)),
      (statement) => emit(state.copyWith(status: StatementStatus.loaded, statement: statement)),
    );
  }

  void changePeriod(StatementPeriod period) {
    if (period == state.period) return;
    emit(state.copyWith(period: period));
    loadStatement();
  }

  /// Returns an error message, or null on success.
  Future<String?> sharePdf() => _runShare(_statementRepo.sharePdf);

  Future<String?> sendWhatsAppText() => _runShare(_statementRepo.sendAsWhatsAppText);

  Future<String?> _runShare(Future<Either<Failure, Unit>> Function(StatementModel statement) action) async {
    final statement = state.statement;
    if (statement == null || state.isSharing) return null;
    emit(state.copyWith(isSharing: true));
    final result = await action(statement);
    emit(state.copyWith(isSharing: false));
    return result.fold((failure) => failure.message, (_) => null);
  }
}
