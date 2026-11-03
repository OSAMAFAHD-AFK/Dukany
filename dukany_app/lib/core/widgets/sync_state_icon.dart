import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Small cloud icon: filled when the row is uploaded, outlined while it
/// is still only on the device.
class SyncStateIcon extends StatelessWidget {
  const SyncStateIcon({super.key, required this.isSynced});

  final bool isSynced;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isSynced ? 'مرفوع' : 'محفوظ على الجهاز فقط',
      child: Icon(
        isSynced ? Icons.cloud_done_rounded : Icons.cloud_upload_outlined,
        size: 16,
        color: isSynced ? AppColors.paid : AppColors.warning,
      ),
    );
  }
}
