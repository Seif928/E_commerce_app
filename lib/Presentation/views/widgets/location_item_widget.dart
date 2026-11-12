import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/domain/entities/location.dart';
import 'package:flutter/material.dart';

class LocationItemWidget extends StatelessWidget {
  final Color borderColor;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final Location location;

  const LocationItemWidget({
    super.key,
    this.borderColor = AppColors.borderLight,
    this.isSelected = false,
    required this.onTap,
    this.onDelete,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final softBg = isDark ? AppColors.surfaceSoftDark : AppColors.surfaceSoft;

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.8 : 1.0,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              ClipOval(
                child: Container(
                  width: 52,
                  height: 52,
                  color: softBg,
                  child:
                      location.imgUrl.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: location.imgUrl,
                            fit: BoxFit.cover,
                            errorWidget:
                                (_, __, ___) => const Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.accentColor,
                                ),
                          )
                          : const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.accentColor,
                          ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.city,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${location.city}, ${location.country}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(color: AppColors.grey1),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.red,
                    size: 20,
                  ),
                ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? AppColors.accentColor : AppColors.grey1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
