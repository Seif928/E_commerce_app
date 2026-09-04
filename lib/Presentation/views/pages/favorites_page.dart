import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Presentation/controller/favorite_cubit/favorite_cubit.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<FavoriteCubit>(context);
    final size = MediaQuery.of(context).size;
    return BlocBuilder<FavoriteCubit, FavoriteState>(
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
          return Scaffold(
            appBar: AppBar(
              leading: InkWell(
                onTap: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil(
                    AppRoute.homeRoute,
                    (route) => false,
                  );
                },
                child: const Icon(Icons.arrow_back_ios_new),
              ),
              centerTitle: true,
              title: Text(
                'Favorites',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
              actions: [
                InkWell(
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.notifications),
                  ),
                ),
              ],
            ),
            body:
                state.favoriteProducts.isNotEmpty
                    ? RefreshIndicator(
                      onRefresh: () async => await cubit.getFavoriteProducts(),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: state.favoriteProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              childAspectRatio: 0.7,
                            ),
                        itemBuilder:
                            (context, index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoute.productDetailsRoute,
                                    arguments: state.favoriteProducts[index].id,
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: SizedBox(
                                        height: size.height * 0.2,
                                        width: double.infinity,
                                        child: Stack(
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl:
                                                  state
                                                      .favoriteProducts[index]
                                                      .imgUrl,
                                              height: size.height * 0.3,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Column(
                                                children: [
                                                  BlocConsumer<
                                                    FavoriteCubit,
                                                    FavoriteState
                                                  >(
                                                    bloc: cubit,
                                                    listenWhen:
                                                        (previous, current) =>
                                                            (current
                                                                is FavoriteRemoveError),
                                                    listener: (context, state) {
                                                      if (state
                                                          is FavoriteRemoveError) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              state.error,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    buildWhen:
                                                        (previous, current) =>
                                                            current
                                                                is FavoriteLoaded ||
                                                            (current
                                                                    is FavoriteRemoving &&
                                                                current.productId ==
                                                                    favoriteProduct[index]
                                                                        .id) ||
                                                            current
                                                                is FavoriteRemoveError,
                                                    builder: (context, state) {
                                                      if (state
                                                              is FavoriteRemoving &&
                                                          state.productId ==
                                                              favoriteProduct[index]
                                                                  .id) {
                                                        return const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                8.0,
                                                              ),
                                                          child: SizedBox(
                                                            height: 24,
                                                            width: 24,
                                                            child:
                                                                CircularProgressIndicator.adaptive(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          ),
                                                        );
                                                      }
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8.0,
                                                            ),
                                                        child: InkWell(
                                                          onTap: () async {
                                                            await cubit
                                                                .removeFavorite(
                                                                  favoriteProduct[index],
                                                                );
                                                          },
                                                          child: const Icon(
                                                            Icons.favorite,
                                                            color:
                                                                AppColors.red,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      state.favoriteProducts[index].name,
                                      style: TextTheme.of(
                                        context,
                                      ).titleSmall!.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      state.favoriteProducts[index].category,
                                      style: TextTheme.of(context).labelMedium!
                                          .copyWith(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      "\$${state.favoriteProducts[index].price}",
                                      style: TextTheme.of(
                                        context,
                                      ).titleSmall!.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ),
                    )
                    : const Center(
                      child: Text(
                        'There is no favorite item',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
          );
        } else if (state is FavoriteError) {
          return Center(child: Text(state.error));
        } else {
          return const Center(child: Text('Something Error'));
        }
      },
    );
  }
}
