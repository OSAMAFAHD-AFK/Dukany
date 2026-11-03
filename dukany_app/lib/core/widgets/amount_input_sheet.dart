import 'package:flutter/material.dart';

import '../utils/functions/money_formatter.dart';
import '../utils/style.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';

typedef AmountInputResult = ({double amount, String? note});

/// Bottom sheet asking for an amount (+ optional note).
/// Used for "customer paid" and "I paid the supplier".
Future<AmountInputResult?> showAmountInputSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String confirmLabel,
  CustomButtonVariant confirmVariant = CustomButtonVariant.primary,
  double? suggestedAmount,
}) {
  return showModalBottomSheet<AmountInputResult>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AmountInputSheetBody(
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
      confirmVariant: confirmVariant,
      suggestedAmount: suggestedAmount,
    ),
  );
}

class _AmountInputSheetBody extends StatefulWidget {
  const _AmountInputSheetBody({
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.confirmVariant,
    this.suggestedAmount,
  });

  final String title;
  final String subtitle;
  final String confirmLabel;
  final CustomButtonVariant confirmVariant;
  final double? suggestedAmount;

  @override
  State<_AmountInputSheetBody> createState() => _AmountInputSheetBodyState();
}

class _AmountInputSheetBodyState extends State<_AmountInputSheetBody> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final note = _noteController.text.trim();
    Navigator.of(context)
        .pop<AmountInputResult>((amount: parseMoney(_amountController.text)!, note: note.isEmpty ? null : note));
  }

  @override
  Widget build(BuildContext context) {
    final suggested = widget.suggestedAmount;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: AppTextStyles.headline),
            const SizedBox(height: 4),
            Text(widget.subtitle, style: AppTextStyles.caption),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _amountController,
              label: 'المبلغ',
              hint: '0',
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.headline,
              validator: (value) => parseMoney(value) == null ? 'اكتب مبلغاً صحيحاً' : null,
            ),
            if (suggested != null && suggested > 0) ...[
              const SizedBox(height: 10),
              ActionChip(
                avatar: const Icon(Icons.done_all_rounded, size: 18),
                label: Text('المبلغ كاملاً ${formatMoney(suggested)}'),
                onPressed: () => _amountController.text = formatMoney(suggested).replaceAll(',', ''),
              ),
            ],
            const SizedBox(height: 16),
            CustomTextField(
              controller: _noteController,
              label: 'ملاحظة (اختياري)',
              hint: 'مثال: نقداً / تحويل',
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: widget.confirmLabel,
              icon: Icons.check_rounded,
              variant: widget.confirmVariant,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
