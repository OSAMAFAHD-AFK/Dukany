import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/date_formatter.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/sync_state_icon.dart';
import '../../../data/models/supplier_entry_model.dart';

class SupplierEntryTile extends StatelessWidget {
  const SupplierEntryTile({super.key, required this.entry, required this.onTap});

  final SupplierEntryModel entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localImage = entry.localImagePath;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: SizedBox(
              width: 52,
              height: 52,
              child: localImage != null
                  ? Image.file(
                      File(localImage),
                      fit: BoxFit.cover,
                      cacheWidth: 160,
                      errorBuilder: (_, _, _) => _EntryIcon(entry: entry),
                    )
                  : _EntryIcon(entry: entry),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.description, style: AppTextStyles.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(formatDateTime(entry.createdAt), style: AppTextStyles.caption),
                    const SizedBox(width: 6),
                    SyncStateIcon(isSynced: entry.isSynced),
                  ],
                ),
              ],
            ),
          ),
          AmountText(
            amount: entry.amount,
            prefix: entry.isInvoice ? '+' : '−',
            color: entry.isInvoice ? AppColors.ink : AppColors.paid,
            fontSize: 16,
          ),
        ],
      ),
    );
  }
}

class _EntryIcon extends StatelessWidget {
  const _EntryIcon({required this.entry});

  final SupplierEntryModel entry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: entry.isInvoice ? AppColors.fieldFill : AppColors.paidSoft,
      child: Icon(
        entry.isInvoice
            ? (entry.remoteImagePath != null ? Icons.cloud_outlined : Icons.receipt_outlined)
            : Icons.payments_outlined,
        color: entry.isInvoice ? AppColors.ink : AppColors.paid,
      ),
    );
  }
}
