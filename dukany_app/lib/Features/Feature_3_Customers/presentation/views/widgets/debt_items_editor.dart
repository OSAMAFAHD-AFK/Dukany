import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../manager/add_customer_debt_cubit/add_customer_debt_cubit.dart';
import 'debt_line_row.dart';

/// Hand-typed list of "item — price" rows (no stock / catalog on purpose).
class DebtItemsEditor extends StatefulWidget {
  const DebtItemsEditor({
    super.key,
    required this.frequentItemNames,
    required this.onLinesChanged,
    required this.onNoteChanged,
  });

  final List<String> frequentItemNames;
  final ValueChanged<List<DebtLineInput>> onLinesChanged;
  final ValueChanged<String> onNoteChanged;

  @override
  State<DebtItemsEditor> createState() => _DebtItemsEditorState();
}

class _DebtItemsEditorState extends State<DebtItemsEditor> {
  final List<DebtLineControllers> _lines = [];
  final _noteController = TextEditingController();
  int _nextLineId = 0;

  @override
  void initState() {
    super.initState();
    final firstLine = DebtLineControllers(id: _nextLineId++);
    _lines.add(firstLine);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) firstLine.nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final line in _lines) {
      line.dispose();
    }
    _noteController.dispose();
    super.dispose();
  }

  void _notify() =>
      widget.onLinesChanged(_lines.map((line) => (name: line.name.text, priceText: line.price.text)).toList());

  void _addLine({String? name}) {
    final line = DebtLineControllers(id: _nextLineId++, initialName: name);
    setState(() => _lines.add(line));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      (name == null ? line.nameFocus : line.priceFocus).requestFocus();
    });
    _notify();
  }

  /// Quick chip: fill the last empty row, otherwise add a new one.
  void _useFrequentItem(String name) {
    final emptyLine = _lines.where((line) => line.name.text.trim().isEmpty).firstOrNull;
    if (emptyLine != null) {
      emptyLine.name.text = name;
      emptyLine.priceFocus.requestFocus();
      _notify();
    } else {
      _addLine(name: name);
    }
  }

  void _removeLine(DebtLineControllers line) {
    setState(() => _lines.remove(line));
    line.dispose();
    if (_lines.isEmpty) _addLine();
    _notify();
  }

  void _onPriceSubmitted(DebtLineControllers line) {
    if (identical(line, _lines.last)) _addLine();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        if (widget.frequentItemNames.isNotEmpty) ...[
          const Text('أصناف متكررة', style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in widget.frequentItemNames)
                ActionChip(label: Text(name), onPressed: () => _useFrequentItem(name)),
            ],
          ),
          const SizedBox(height: 18),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.large)),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('الصنف', style: AppTextStyles.caption)),
                    SizedBox(width: 8),
                    Expanded(flex: 2, child: Text('السعر', style: AppTextStyles.caption)),
                    SizedBox(width: 40),
                  ],
                ),
              ),
              for (final line in _lines)
                Padding(
                  key: ValueKey(line.id),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DebtLineRow(
                    line: line,
                    onChanged: _notify,
                    onRemove: () => _removeLine(line),
                    onPriceSubmitted: () => _onPriceSubmitted(line),
                  ),
                ),
              TextButton.icon(
                onPressed: _addLine,
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('إضافة صنف آخر', style: AppTextStyles.bodyMedium),
                style: TextButton.styleFrom(foregroundColor: AppColors.ink),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _noteController,
          label: 'ملاحظة (اختياري)',
          hint: 'مثال: أخذها ابنه',
          onChanged: widget.onNoteChanged,
        ),
      ],
    );
  }
}
