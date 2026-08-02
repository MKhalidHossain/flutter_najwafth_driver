import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/core.dart';

class CustomToggleSwitch extends StatelessWidget {
  const CustomToggleSwitch({
    super.key,
    required this.isOnline,
    required this.onChanged,
    this.isLoading = false,
  });

  final bool isOnline;
  final ValueChanged<bool> onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : () => onChanged(!isOnline),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background, // Or a light grey color
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? AppColors.primary : AppColors.border,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.tr(isOnline ? "You're Online" : "You're Offline"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.title,
                ),
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 60,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isOnline ? AppColors.primary : AppColors.border,
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      left: isOnline ? 28 : 2,
                      top: 2,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.power_settings_new_rounded,
                          size: 18,
                          color: isOnline
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
