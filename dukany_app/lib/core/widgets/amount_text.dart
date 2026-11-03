import 'package:flutter/material.dart';

import '../utils/app_config.dart';
import '../utils/functions/money_formatter.dart';
import '../utils/style.dart';
import '../utils/theme.dart';

/// "15,000 ريال" with the currency label smaller and lighter.
class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    required this.amount,
    this.color = AppColors.ink,
    this.fontSize = 16,
    this.prefix = '',
    this.currencyColor,
  });

  final num amount;
  final Color color;
  final double fontSize;
  final String prefix;
  final Color? currencyColor;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$prefix${formatMoney(amount)}',
            style: AppTextStyles.subtitle.copyWith(color: color, fontSize: fontSize, fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: ' ${AppConfig.currencyLabel}',
            style: AppTextStyles.caption.copyWith(
              color: currencyColor ?? color.withValues(alpha: 0.7),
              fontSize: fontSize * 0.62 < 11 ? 11 : fontSize * 0.62,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
