import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/money_formatter.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../data/models/invoice_scan_result_model.dart';

/// Photo preview + total (pre-filled by OCR) + note.
class InvoiceAmountForm extends StatefulWidget {
  const InvoiceAmountForm({
    super.key,
    required this.imagePath,
    required this.scanResult,
    required this.isSaving,
    required this.onRetake,
    required this.onSave,
  });

  final String? imagePath;
  final InvoiceScanResultModel scanResult;
  final bool isSaving;
  final VoidCallback onRetake;
  final void Function(String amountText, String note) onSave;

  @override
  State<InvoiceAmountForm> createState() => _InvoiceAmountFormState();
}

class _InvoiceAmountFormState extends State<InvoiceAmountForm> {
  late final TextEditingController _amountController;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final suggested = widget.scanResult.suggestedTotal;
    _amountController = TextEditingController(text: suggested == null ? '' : _plain(suggested));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _plain(double value) => formatMoney(value).replaceAll(',', '');

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.imagePath;
    final scan = widget.scanResult;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              if (imagePath != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.large),
                      child: Image.file(File(imagePath), height: 240, width: double.infinity, fit: BoxFit.cover),
                    ),
                    PositionedDirectional(
                      top: 10,
                      end: 10,
                      child: Material(
                        color: AppColors.surface,
                        shape: const StadiumBorder(),
                        child: InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: widget.onRetake,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.refresh_rounded, size: 18),
                                SizedBox(width: 4),
                                Text('صورة أخرى', style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              if (imagePath != null) _ScanHint(found: scan.suggestedTotal != null),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _amountController,
                label: 'إجمالي الفاتورة (الدين)',
                hint: '0',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textDirection: TextDirection.ltr,
                style: AppTextStyles.headline,
              ),
              if (scan.candidates.length > 1) ...[
                const SizedBox(height: 12),
                const Text('أرقام وجدناها في الفاتورة — اضغط على الإجمالي الصحيح:', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final value in scan.candidates)
                      ActionChip(
                        label: Text(formatMoney(value)),
                        onPressed: () => setState(() => _amountController.text = _plain(value)),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              CustomTextField(controller: _noteController, label: 'ملاحظة (اختياري)', hint: 'مثال: 20 كرتون ماء'),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: CustomButton(
              label: 'حفظ الفاتورة',
              icon: Icons.check_rounded,
              isLoading: widget.isSaving,
              onPressed: () => widget.onSave(_amountController.text, _noteController.text),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanHint extends StatelessWidget {
  const _ScanHint({required this.found});

  final bool found;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: found ? AppColors.paidSoft : AppColors.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: [
          Icon(
            found ? Icons.auto_awesome_rounded : Icons.info_outline_rounded,
            color: found ? AppColors.paid : AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              found ? 'قرأنا الإجمالي من الصورة، تأكد منه قبل الحفظ' : 'لم نستطع قراءة الإجمالي، اكتبه بيدك',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
