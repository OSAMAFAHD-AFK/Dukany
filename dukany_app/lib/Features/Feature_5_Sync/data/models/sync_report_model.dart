import 'package:equatable/equatable.dart';

class SyncReportModel extends Equatable {
  const SyncReportModel({required this.uploadedRows, required this.uploadedImages});

  final int uploadedRows;
  final int uploadedImages;

  @override
  List<Object?> get props => [uploadedRows, uploadedImages];
}
