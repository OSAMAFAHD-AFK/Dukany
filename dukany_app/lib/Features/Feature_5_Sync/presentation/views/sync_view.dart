import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/functions/app_snack_bar.dart';
import '../../../../core/utils/style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../manager/sync_cubit/sync_cubit.dart';
import 'widgets/pending_message_tile.dart';
import 'widgets/sending_all_banner.dart';
import 'widgets/sync_status_card.dart';

class SyncView extends StatefulWidget {
  const SyncView({super.key});

  @override
  State<SyncView> createState() => _SyncViewState();
}

class _SyncViewState extends State<SyncView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) context.read<SyncCubit>().onAppResumed();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SyncCubit>();
    return BlocConsumer<SyncCubit, SyncState>(
      listenWhen: (previous, current) => current.errorMessage != null && previous.errorMessage != current.errorMessage,
      listener: (context, state) => showAppSnackBar(context, state.errorMessage!, isError: true),
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('الرفع والإرسال')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              SyncStatusCard(state: state),
              const SizedBox(height: 14),
              if (state.isSubscriptionInactive)
                CustomButton(
                  label: 'عرض حالة الاشتراك',
                  icon: Icons.lock_clock_outlined,
                  variant: CustomButtonVariant.danger,
                  onPressed: () => context.go(AppRouter.kSubscriptionEndedView),
                )
              else
                CustomButton(
                  label: 'رفع البيانات وإرسال الرسائل',
                  icon: Icons.cloud_upload_outlined,
                  isLoading: state.phase == SyncPhase.uploading,
                  onPressed: cubit.startSync,
                ),
              if (state.isSendingAll) ...[
                const SizedBox(height: 14),
                SendingAllBanner(remaining: state.messages.length, onStop: cubit.stopSendingAll),
              ],
              if (state.messages.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Text('رسائل واتساب (${state.messages.length})', style: AppTextStyles.title)),
                    if (!state.isSendingAll)
                      TextButton.icon(
                        onPressed: cubit.startSendingAll,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('إرسال الكل'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final message in state.messages) ...[
                  PendingMessageTile(
                    message: message,
                    onSend: () async {
                      final error = await cubit.sendMessage(message);
                      if (error != null && context.mounted) showAppSnackBar(context, error, isError: true);
                    },
                    onDismiss: () => cubit.dismissMessage(message),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
