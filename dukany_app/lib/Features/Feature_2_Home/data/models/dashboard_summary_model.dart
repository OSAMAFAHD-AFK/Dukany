import 'package:equatable/equatable.dart';

import 'recent_activity_model.dart';

class DashboardSummaryModel extends Equatable {
  const DashboardSummaryModel({
    required this.customersOwe,
    required this.customersCount,
    required this.suppliersDue,
    required this.suppliersCount,
    required this.todayDebts,
    required this.todayCollected,
    required this.recentActivity,
  });

  /// Total customers owe the shop.
  final double customersOwe;
  final int customersCount;

  /// Total the shop owes suppliers.
  final double suppliersDue;
  final int suppliersCount;

  final double todayDebts;
  final double todayCollected;
  final List<RecentActivityModel> recentActivity;

  @override
  List<Object?> get props => [
    customersOwe,
    customersCount,
    suppliersDue,
    suppliersCount,
    todayDebts,
    todayCollected,
    recentActivity,
  ];
}
