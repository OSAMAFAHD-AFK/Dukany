import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../data_sources/home_local_data_source.dart';
import '../models/dashboard_summary_model.dart';
import 'home_repo.dart';

class HomeRepoImpl implements HomeRepo {
  HomeRepoImpl(this._localDataSource);

  final HomeLocalDataSource _localDataSource;

  @override
  Stream<void> get changes => _localDataSource.changes;

  @override
  Future<Either<Failure, DashboardSummaryModel>> getDashboardSummary() async {
    try {
      return Right(await _localDataSource.getDashboardSummary());
    } catch (error, stackTrace) {
      log('local database error', name: 'HomeRepo', error: error, stackTrace: stackTrace);
      return const Left(LocalDatabaseFailure('تعذّر تحميل الملخص'));
    }
  }
}
