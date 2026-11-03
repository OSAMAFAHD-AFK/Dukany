import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';

/// Controllers + focus nodes of one "item — price" row.
class DebtLineControllers {
  DebtLineControllers({required this.id, String? initialName}) : name = TextEditingController(text: initialName);

  final int id;
  final TextEditingController name;
  final TextEditingController price = TextEditingController();
  final FocusNode nameFocus = FocusNode();
  final FocusNode priceFocus = FocusNode();

  void dispose() {
    name.dispose();
    price.dispose();
    nameFocus.dispose();
    priceFocus.dispose();
  }
}

class DebtLineRow extends StatelessWidget {
  const DebtLineRow({
    super.key,
    required this.line,
    required this.onChanged,
    required this.onRemove,
    required this.onPriceSubmitted,
  });

  final DebtLineControllers line;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final VoidCallback onPriceSubmitted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: line.name,
            focusNode: line.nameFocus,
            textInputAction: TextInputAction.next,
            onChanged: (_) => onChanged(),
            onSubmitted: (_) => line.priceFocus.requestFocus(),
            style: AppTextStyles.bodyMedium,
            decoration: const InputDecoration(hintText: 'فاصوليا', isDense: true),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextField(
            controller: line.price,
            focusNode: line.priceFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            textDirection: TextDirection.ltr,
            onChanged: (_) => onChanged(),
            onSubmitted: (_) => onPriceSubmitted(),
            style: AppTextStyles.subtitle,
            decoration: const InputDecoration(hintText: '0', isDense: true),
          ),
        ),
        SizedBox(
          width: 40,
          child: IconButton(
            tooltip: 'حذف الصنف',
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
