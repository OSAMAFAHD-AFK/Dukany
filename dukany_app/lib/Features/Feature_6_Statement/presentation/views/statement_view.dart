import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/functions/app_snack_bar.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../data/models/statement_period.dart';
import '../manager/statement_cubit/statement_cubit.dart';
import 'widgets/statement_line_tile.dart';
import 'widgets/statement_summary_card.dart';

class StatementView extends StatelessWidget {
  const StatementView({super.key});

  Future<void> _share(BuildContext context, Future<String?> Function() action) async {
    final error = await action();
    if (error != null && context.mounted) showAppSnackBar(context, error, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StatementCubit>();
    return BlocBuilder<StatementCubit, StatementState>(
      builder: (context, state) {
        final statement = state.statement;
        return Scaffold(
          appBar: AppBar(title: Text(statement == null ? 'كشف حساب' : 'كشف حساب ${statement.partyName}')),
          bottomNavigationBar: statement == null
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: 'مشاركة PDF',
                            icon: Icons.picture_as_pdf_outlined,
                            isLoading: state.isSharing,
                            onPressed: () => _share(context, cubit.sharePdf),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            label: 'واتساب نص',
                            icon: Icons.chat_outlined,
                            variant: CustomButtonVariant.success,
                            onPressed: state.isSharing ? null : () => _share(context, cubit.sendWhatsAppText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          body: Column(
            children: [
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: StatementPeriod.values.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final period = StatementPeriod.values[index];
                    final selected = period == state.period;
                    return ChoiceChip(
                      label: Text(period.label),
                      selected: selected,
                      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.ink),
                      onSelected: (_) => cubit.changePeriod(period),
                    );
                  },
                ),
              ),
              Expanded(
                child: switch (state.status) {
                  StatementStatus.loading when statement == null => const LoadingView(),
                  StatementStatus.failure => ErrorView(message: state.errorMessage ?? '', onRetry: cubit.loadStatement),
                  _ => ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      StatementSummaryCard(statement: statement!),
                      const SizedBox(height: 16),
                      if (statement.lines.isEmpty)
                        const EmptyStateView(icon: Icons.event_busy_outlined, title: 'لا توجد عمليات في هذه الفترة')
                      else
                        for (final line in statement.lines.reversed) ...[
                          StatementLineTile(line: line),
                          const SizedBox(height: 8),
                        ],
                    ],
                  ),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
