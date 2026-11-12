import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Presentation/controller/favorite_cubit/favorite_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/notifications_sheet.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<FavoriteCubit>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final softBg = isDark ? AppColors.surfaceSoftDark : AppColors.surfaceSoft;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.black;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.grey1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamedAndRemoveUntil(AppRoute.homeRoute, (route) => false);
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: Text(context.tr('favorites_title')),
        actions: [
          IconButton(
            onPressed: () => showNotificationsSheet(context),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: BlocBuilder<FavoriteCubit, FavoriteState>(
        bloc: cubit,
        buildWhen:
            (previous, current) =>
                current is FavoriteError ||
                current is FavoriteLoaded ||
                current is FavoriteLoading,
        builder: (context, state) {
          if (state is FavoriteLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (state is FavoriteLoaded) {
            final favoriteProduct = state.favoriteProducts;
            if (favoriteProduct.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          size: 46,
                          color: AppColors.grey1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.tr('favorites_empty'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr('favorites_empty_sub'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: subtextColor),
                      ),
                    ],
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => await cubit.getFavoriteProducts(),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: favoriteProduct.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.67,
                ),
                itemBuilder: (context, index) {
                  final item = favoriteProduct[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed(
                        AppRoute.productDetailsRoute,
                        arguments: item.id,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: softBg,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: CachedNetworkImage(
                                      imageUrl: item.imgUrl,
                                      fit: BoxFit.contain,
                                      errorWidget:
                                          (_, __, ___) => const Icon(
                                            Icons.image_not_supported_outlined,
                                            color: AppColors.grey1,
                                          ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: BlocConsumer<
                                    FavoriteCubit,
                                    FavoriteState
                                  >(
                                    bloc: cubit,
                                    listenWhen:
                                        (previous, current) =>
                                            current is FavoriteRemoveError,
                                    listener: (context, favState) {
                                      if (favState is FavoriteRemoveError) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              context.trError(favState.error),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    buildWhen:
                                        (previous, current) =>
                                            current is FavoriteLoaded ||
                                            (current is FavoriteRemoving &&
                                                current.productId == item.id) ||
                                            current is FavoriteRemoveError,
                                    builder: (context, favState) {
                                      final removing =
                                          favState is FavoriteRemoving &&
                                          favState.productId == item.id;
                                      return Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: cardBg,
                                          shape: BoxShape.circle,
                                        ),
                                        child:
                                            removing
                                                ? const SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child:
                                                      CircularProgressIndicator.adaptive(
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                                : InkWell(
                                                  onTap:
                                                      () => cubit
                                                          .removeFavorite(item),
                                                  child: const Icon(
                                                    Icons.favorite_rounded,
                                                    color: AppColors.red,
                                                    size: 18,
                                                  ),
                                                ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            context.trCategory(item.category).toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: subtextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is FavoriteError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.trError(state.error),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => cubit.getFavoriteProducts(),
                      child: Text(context.tr('refresh')),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(
            child: Text(
              context.isArabic ? 'حدث خطأ ما' : 'Something went wrong',
              style: TextStyle(color: textColor),
            ),
          );
        },
      ),
    );
  }
}
