part of 'restore_data_cubit.dart';

enum RestoreDataStatus { restoring, done, failure }

class RestoreDataState extends Equatable {
  const RestoreDataState({this.status = RestoreDataStatus.restoring, this.errorMessage});

  final RestoreDataStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];
}
