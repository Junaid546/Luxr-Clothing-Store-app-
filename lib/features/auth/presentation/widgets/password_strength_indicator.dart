import 'package:flutter/material.dart';

import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_dimensions.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  // 0-4

  const PasswordStrengthIndicator({required this.strengthLevel, super.key});
  final int strengthLevel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bars
        Row(
          children: List.generate(3, (index) {
            final isActive = index < strengthLevel;
            final color = _getBarColor(index);
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < 2 ? AppDimensions.spacing4 : 0,
                ),
                height: 4,
                decoration: BoxDecoration(
                  color: isActive ? color : AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppDimensions.spacing8),
        // Strength text
        Text(
          _getStrengthText(),
          style: TextStyle(
            fontSize: 12,
            color: _getBarColor(strengthLevel - 1),
          ),
        ),
      ],
    );
  }

  Color _getBarColor(int index) {
    if (index < 0) return AppColors.textMuted;
    if (index == 0) return AppColors.error;
    if (index == 1) return AppColors.warning;
    return AppColors.success;
  }

  String _getStrengthText() {
    if (strengthLevel == 0) return '';
    if (strengthLevel == 1) return 'Weak password';
    if (strengthLevel == 2) return 'Fair password';
    if (strengthLevel == 3) return 'Good password';
    return 'Strong password: Mix of letters, numbers & symbols';
  }
}
