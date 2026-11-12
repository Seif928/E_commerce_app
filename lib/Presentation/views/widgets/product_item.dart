import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Presentation/controller/favorite_cubit/favorite_cubit.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductItem extends StatelessWidget {
  final Product productItem;
  const ProductItem({super.key, required this.productItem});

  @override
  Widget build(BuildContext context) {
    final favoritCubit = BlocProvider.of<FavoriteCubit>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final softBg = isDark ? AppColors.surfaceSoftDark : AppColors.surfaceSoft;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.black;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: softBg,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      imageUrl: productItem.imgUrl,
                      fit: BoxFit.contain,
                      placeholder:
                          (context, url) => const Center(
                            child: SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.grey1,
                            ),
                          ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 6,
                  start: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cardBg.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.yellow,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          productItem.averageRate.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 6,
                  end: 6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cardBg.withValues(alpha: 0.92),
                    ),
                    child: BlocConsumer<FavoriteCubit, FavoriteState>(
                      bloc: favoritCubit,
                      listenWhen:
                          (previous, current) =>
                              (current is FavoriteRemoveError ||
                                  current is SetFavoriteLoadedError),
                      listener: (context, state) {
                        if (state is FavoriteRemoveError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.error)),
                          );
                        } else if (state is SetFavoriteLoadedError &&
                            state.productId == productItem.id) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.error)),
                          );
                        }
                      },
                      buildWhen:
                          (previous, current) =>
                              current is FavoriteLoaded ||
                              current is FavoriteInitial ||
                              (current is SetFavoriteLoading &&
                                  current.productId == productItem.id) ||
                              (current is FavoriteRemoving &&
                                  current.productId == productItem.id),
                      builder: (context, state) {
                        final isFavLoading =
                            (state is SetFavoriteLoading &&
                                state.productId == productItem.id) ||
                            (state is FavoriteRemoving &&
                                state.productId == productItem.id);

                        if (isFavLoading) {
                          return const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          );
                        }

                        final isFav =
                            state is FavoriteLoaded
                                ? state.favoriteProducts.any(
                                  (p) => p.id == productItem.id,
                                )
                                : productItem.isFavorite;

                        return InkWell(
                          onTap: () async {
                            await favoritCubit.setFavorite(productItem);
                          },
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18,
                            color: isFav ? AppColors.red : textColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.trCategory(productItem.category).toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: isDark ? AppColors.textSecondaryDark : AppColors.grey1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            productItem.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${productItem.price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
