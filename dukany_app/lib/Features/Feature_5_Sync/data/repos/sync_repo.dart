import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../models/pending_counts_model.dart';
import '../models/pending_message_model.dart';
import '../models/sync_report_model.dart';

abstract class SyncRepo {
  Stream<void> get changes;

  Future<Either<Failure, PendingCountsModel>> getPendingCounts();

  /// Checks the subscription, uploads invoice photos, then every row
  /// saved offline (customers → suppliers → entries).
  Future<Either<Failure, SyncReportModel>> uploadPendingData();

  Future<Either<Failure, List<PendingMessageModel>>> getUnsentMessages();

  /// Opens WhatsApp with the message typed and marks it as sent.
  Future<Either<Failure, Unit>> sendMessage(PendingMessageModel message);

  /// Removes a message from the queue without sending it.
  Future<Either<Failure, Unit>> dismissMessage(PendingMessageModel message);

  /// After login on a new/cleared phone: downloads the shop's data.
  /// Right(true) if data was restored, Right(false) if nothing was needed.
  Future<Either<Failure, bool>> restoreFromCloudIfNeeded();
}
