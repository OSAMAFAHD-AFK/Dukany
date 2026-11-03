import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../models/dashboard_summary_model.dart';

abstract class HomeRepo {
  Stream<void> get changes;

  Future<Either<Failure, DashboardSummaryModel>> getDashboardSummary();
}
