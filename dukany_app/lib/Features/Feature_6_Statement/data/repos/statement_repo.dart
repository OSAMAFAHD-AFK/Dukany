import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/models/party_type.dart';
import '../models/statement_model.dart';
import '../models/statement_period.dart';

abstract class StatementRepo {
  Future<Either<Failure, StatementModel>> getStatement({
    required PartyType partyType,
    required String partyId,
    required StatementPeriod period,
  });

  /// Generates the PDF and opens the Android share sheet (WhatsApp, etc.).
  Future<Either<Failure, Unit>> sharePdf(StatementModel statement);

  /// Opens WhatsApp chat of the party with the statement as text.
  Future<Either<Failure, Unit>> sendAsWhatsAppText(StatementModel statement);
}
