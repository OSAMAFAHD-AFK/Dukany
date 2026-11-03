import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/date_formatter.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/party_avatar.dart';
import '../../../data/models/pending_message_model.dart';

class PendingMessageTile extends StatelessWidget {
  const PendingMessageTile({super.key, required this.message, required this.onSend, required this.onDismiss});

  final PendingMessageModel message;
  final VoidCallback onSend;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PartyAvatar(name: message.recipientName, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message.recipientName, style: AppTextStyles.subtitle),
                    Text(formatDateTime(message.createdAt), style: AppTextStyles.caption),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'عدم الإرسال',
                onPressed: onDismiss,
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
              IconButton.filled(
                tooltip: 'إرسال',
                onPressed: onSend,
                style: IconButton.styleFrom(backgroundColor: AppColors.paid),
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.fieldFill, borderRadius: BorderRadius.circular(AppRadius.small)),
            child: Text(
              message.body,
              style: AppTextStyles.caption.copyWith(color: AppColors.ink),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
