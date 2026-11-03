import 'package:flutter/material.dart';

import '../../../../../core/widgets/empty_state_view.dart';
import '../../../data/models/customer_entry_model.dart';
import 'customer_entry_tile.dart';

class CustomerEntriesList extends StatelessWidget {
  const CustomerEntriesList({super.key, required this.entries, required this.onEntryTap});

  final List<CustomerEntryModel> entries;
  final ValueChanged<CustomerEntryModel> onEntryTap;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyStateView(
          icon: Icons.receipt_outlined,
          title: 'لا توجد عمليات بعد',
          message: 'اضغط "تسجيل دين" عندما يأخذ الزبون أغراضاً',
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      sliver: SliverList.separated(
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) =>
            CustomerEntryTile(entry: entries[index], onTap: () => onEntryTap(entries[index])),
      ),
    );
  }
}
