import 'package:flutter/material.dart';

import 'custom_button.dart';

/// Floating black pill used for "زبون جديد" / "مورد جديد".
class FloatingPillButton extends StatelessWidget {
  const FloatingPillButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: CustomButton(label: label, icon: Icons.add_rounded, expand: false, height: 58, onPressed: onPressed),
    );
  }
}
