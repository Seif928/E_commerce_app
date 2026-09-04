import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class EmptyListTile extends StatelessWidget {
  const EmptyListTile({
    super.key,

    required this.leadingIcon,
    this.titleColor,
    required this.title,
    this.trailingIcon,
    this.ontap,
  });

  final Widget leadingIcon;
  final String title;
  final Color? titleColor;
  final Widget? trailingIcon;
  final VoidCallback? ontap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.grey2,
        ),
        child: ListTile(
          onTap: ontap,
          leading: leadingIcon,
          title: Text(
            title,
            style: TextTheme.of(context).titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          trailing: trailingIcon,
        ),
      ),
    );
  }
}
