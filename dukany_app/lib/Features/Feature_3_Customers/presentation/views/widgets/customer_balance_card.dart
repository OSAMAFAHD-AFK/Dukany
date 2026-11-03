import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/phone_normalizer.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';
import '../../../../../core/widgets/party_avatar.dart';
import '../../../data/models/customer_model.dart';

/// Dark hero card on top of the customer page: who, and how much is owed.
class CustomerBalanceCard extends StatelessWidget {
  const CustomerBalanceCard({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    final balance = customer.balance;
    final label = balance > 0
        ? 'المتبقي عليه'
        : balance < 0
        ? 'له رصيد عندك'
        : 'الحساب مسدد بالكامل';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadius.extraLarge)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PartyAvatar(name: customer.name, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      customer.hasPhone ? formatPhoneForDisplay(customer.phone!) : 'بدون رقم جوال',
                      textDirection: TextDirection.ltr,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textOnInkSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textOnInkSecondary)),
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
