part of 'statement_cubit.dart';

enum StatementStatus { loading, loaded, failure }

class StatementState extends Equatable {
  const StatementState({
    this.status = StatementStatus.loading,
    this.period = StatementPeriod.thisMonth,
    this.statement,
    this.isSharing = false,
    this.errorMessage,
  });

  final StatementStatus status;
  final StatementPeriod period;
  final StatementModel? statement;
  final bool isSharing;
  final String? errorMessage;

  StatementState copyWith({
    StatementStatus? status,
    StatementPeriod? period,
    StatementModel? statement,
    bool? isSharing,
    String? errorMessage,
  }) => StatementState(
    status: status ?? this.status,
    period: period ?? this.period,
    statement: statement ?? this.statement,
    isSharing: isSharing ?? this.isSharing,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, period, statement, isSharing, errorMessage];
}
