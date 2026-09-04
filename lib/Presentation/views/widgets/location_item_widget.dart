import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/domain/entities/location.dart';
import 'package:flutter/material.dart';

class LocationItemWidget extends StatelessWidget {
  final Color borderColor;
  final VoidCallback onTap;
  final Location location;
  const LocationItemWidget({
    super.key,
    this.borderColor = AppColors.grey1,
    required this.onTap,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.city,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${location.city}, ${location.country}',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall!.copyWith(color: AppColors.grey1),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(radius: 55, backgroundColor: borderColor),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: CachedNetworkImageProvider(
                      location.imgUrl,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
