import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class EmptyListTile extends StatelessWidget {
  const EmptyListTile({
    super.key,
    required this.leadingIcon,
    this.titleColor,
    required this.title,
    this.subtitle,
    this.trailingIcon,
    this.ontap,
  });

  final Widget leadingIcon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailingIcon;
  final VoidCallback? ontap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final softBg = isDark ? AppColors.surfaceSoftDark : AppColors.surfaceSoft;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final defaultTextColor = isDark ? AppColors.textDark : AppColors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: ontap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: softBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: leadingIcon,
              ),
              title: Text(
                title,
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? defaultTextColor,
                ),
              ),
              subtitle: subtitle != null
                  ? Text(
                      subtitle!,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.grey1,
                      ),
                    )
                  : null,
              trailing: trailingIcon,
            ),
          ),
        ),
      ),
    );
  }
}
