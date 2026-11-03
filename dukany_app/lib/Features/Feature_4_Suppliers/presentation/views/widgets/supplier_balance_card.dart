import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';
import '../../../../../core/widgets/party_avatar.dart';
import '../../../data/models/supplier_model.dart';

class SupplierBalanceCard extends StatelessWidget {
  const SupplierBalanceCard({super.key, required this.supplier});

  final SupplierModel supplier;

  @override
  Widget build(BuildContext context) {
    final balance = supplier.balance;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadius.extraLarge)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PartyAvatar(name: supplier.name, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  supplier.name,
                  style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            balance > 0 ? 'المتبقي عليك للمورد' : 'لا يوجد عليك شيء',
            style: AppTextStyles.caption.copyWith(color: AppColors.textOnInkSecondary),
          ),
          const SizedBox(height: 2),
          AmountText(
            amount: balance.abs(),
            color: balance > 0 ? Colors.white : AppColors.accent,
            fontSize: 34,
            currencyColor: AppColors.textOnInkSecondary,
          ),
        ],
      ),
    );
  }
}
