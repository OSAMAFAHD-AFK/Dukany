import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/date_formatter.dart';
import '../../../../../core/utils/functions/money_formatter.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../data/models/statement_model.dart';

class StatementLineTile extends StatelessWidget {
  const StatementLineTile({super.key, required this.line});

  final StatementLineModel line;

  @override
  Widget build(BuildContext context) {
    final isDebit = line.debit > 0;
    return AppCard(
      padding: const EdgeInsets.all(14),
      radius: AppRadius.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(formatDateTime(line.date), style: AppTextStyles.caption)),
              AmountText(
                amount: isDebit ? line.debit : line.credit,
                prefix: isDebit ? '+' : '−',
                color: isDebit ? AppColors.debt : AppColors.paid,
                fontSize: 16,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(line.description, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 4),
          Text('الرصيد بعدها: ${formatMoney(line.runningBalance)}', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
