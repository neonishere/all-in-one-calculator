import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'unresolvable_icon.dart';

/// Replaces a [ResultCard] when the given inputs can't be solved (e.g. they
/// violate the triangle inequality, or an impossible side/hypotenuse pair).
class UnresolvableCard extends StatelessWidget {
  const UnresolvableCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const UnresolvableIcon(size: 26),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
