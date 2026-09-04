import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Presentation/controller/favorite_cubit/favorite_cubit.dart';

import 'package:e_commerce_app/domain/entities/product.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductItem extends StatelessWidget {
  final Product productItem;
  const ProductItem({super.key, required this.productItem});

  @override
  Widget build(BuildContext context) {
    final favoritCubit = BlocProvider.of<FavoriteCubit>(context);

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 110,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: AppColors.grey2,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CachedNetworkImage(
                  imageUrl: productItem.imgUrl,
                  fit: BoxFit.contain,
                  placeholder:
                      (context, url) => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                  errorWidget:
                      (context, url, error) =>
                          const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white54,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: BlocConsumer<FavoriteCubit, FavoriteState>(
                    bloc: favoritCubit,
                    listenWhen:
                        (previous, current) =>
                            (current is FavoriteRemoveError ||
                                current is SetFavoriteLoadedError),
                    listener: (context, state) {
                      if (state is FavoriteRemoveError) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.error)));
                      } else if (state is SetFavoriteLoadedError) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.error)));
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
                      final isFavLoading = (state is SetFavoriteLoading &&
                              state.productId == productItem.id) ||
                          (state is FavoriteRemoving &&
                              state.productId == productItem.id);

                      if (isFavLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }

                      final isFav = state is FavoriteLoaded
                          ? state.favoriteProducts.any(
                              (p) => p.id == productItem.id,
                            )
                          : productItem.isFavorite;

                      return InkWell(
                        onTap: () async {
                          await favoritCubit.setFavorite(productItem);
                        },
                        child: isFav
                            ? const Icon(Icons.favorite, color: Colors.red)
                            : const Icon(Icons.favorite_border),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        Text(
          productItem.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          productItem.category,
          style: Theme.of(
            context,
          ).textTheme.labelMedium!.copyWith(color: Colors.grey),
        ),
        Text(
          '\$${productItem.price}',
          style: Theme.of(
            context,
          ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
