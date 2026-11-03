import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/date_formatter.dart';
import '../../../../../core/utils/style.dart';
import '../../../data/models/shop_model.dart';

/// Returns the number of months to add, or null if cancelled.
Future<int?> showExtendSubscriptionDialog(BuildContext context, ShopModel shop) {
  final from = shop.subscriptionEndsAt.isAfter(DateTime.now()) ? shop.subscriptionEndsAt : DateTime.now();
  return showDialog<int>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: Text('تمديد اشتراك ${shop.name}'),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('يبدأ التمديد من ${formatDate(from)}', style: AppTextStyles.caption),
        ),
        const SizedBox(height: 8),
        for (final months in const [1, 3, 6, 12])
          ListTile(
            leading: const Icon(Icons.add_circle_outline_rounded),
            title: Text(months == 1 ? 'شهر واحد' : '$months أشهر'),
            subtitle: Text(
              'حتى ${formatDate(DateTime(from.year, from.month + months, from.day))}',
              style: AppTextStyles.caption,
            ),
            onTap: () => Navigator.of(dialogContext).pop(months),
          ),
      ],
    ),
  );
}
