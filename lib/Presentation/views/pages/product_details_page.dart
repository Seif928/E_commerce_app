import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Presentation/controller/favorite_cubit/favorite_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/product_details_cubit/product_details_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/counter_widget.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:e_commerce_app/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productId;
  const ProductDetailsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cubitProductDetails = BlocProvider.of<ProductDetailsCubit>(context);
    final cubitFavoriteProduct = BlocProvider.of<FavoriteCubit>(context);
    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      bloc: cubitProductDetails,
      buildWhen:
          (previous, current) =>
              current is ProductDetailsLoading ||
              current is ProductDetailsLoaded ||
              current is ProductDetailsError,
      builder: (context, state) {
        if (state is ProductDetailsLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        } else if (state is ProductDetailsError) {
          return Scaffold(body: Center(child: Text(state.message)));
        } else if (state is ProductDetailsLoaded) {
          final product = state.product;
          return Scaffold(
            extendBodyBehindAppBar: true,
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
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Product Details',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
              actions: [
                BlocConsumer<FavoriteCubit, FavoriteState>(
                  bloc: cubitFavoriteProduct,
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
                              current.productId == product.id) ||
                          (current is FavoriteRemoving &&
                              current.productId == product.id),
                  builder: (context, state) {
                    final isFavLoading =
                        (state is SetFavoriteLoading &&
                            state.productId == product.id) ||
                        (state is FavoriteRemoving &&
                            state.productId == product.id);

                    if (isFavLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      );
                    }

                    final isFav =
                        state is FavoriteLoaded
                            ? state.favoriteProducts.any(
                              (p) => p.id == product.id,
                            )
                            : product.isFavorite;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: InkWell(
                        onTap: () async {
                          await cubitFavoriteProduct.setFavorite(product);
                        },
                        child:
                            isFav
                                ? const Icon(Icons.favorite, color: Colors.red)
                                : const Icon(Icons.favorite_border),
                      ),
                    );
                  },
                ),
              ],
            ),

            body: Stack(
              children: [
                Container(
                  height: size.height * 0.48,
                  width: double.infinity,
                  decoration: BoxDecoration(color: AppColors.grey2),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.1),
                      CachedNetworkImage(
                        imageUrl: product.imgUrl,
                        height: size.height * 0.3,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.40),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.white1,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(36.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: AppColors.yellow,
                                          size: 25,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          product.averageRate.toString(),
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                BlocBuilder<
                                  ProductDetailsCubit,
                                  ProductDetailsState
                                >(
                                  bloc: cubitProductDetails,
                                  buildWhen:
                                      (previous, current) =>
                                          current is QuantityCounterLoaded ||
                                          current is ProductDetailsLoaded,
                                  builder: (context, state) {
                                    int quantityValue =
                                        cubitProductDetails.quantity;
                                    if (state is QuantityCounterLoaded) {
                                      quantityValue = state.value;
                                    } else if (state is ProductDetailsLoaded) {
                                      quantityValue = 1;
                                    }
                                    return CounterWidget(
                                      value: quantityValue,
                                      onIncrement:
                                          () => cubitProductDetails
                                              .incrementCounter(product.id),
                                      onDecrement:
                                          () => cubitProductDetails
                                              .decrementCounter(product.id),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Size',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            BlocBuilder<
                              ProductDetailsCubit,
                              ProductDetailsState
                            >(
                              bloc: cubitProductDetails,
                              buildWhen:
                                  (previous, current) =>
                                      current is SizeSelected ||
                                      current is ProductDetailsLoaded,
                              builder: (context, state) {
                                return Row(
                                  children:
                                      ProductSize.values
                                          .map(
                                            (size) => Padding(
                                              padding: const EdgeInsets.only(
                                                top: 6.0,
                                                right: 8.0,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  BlocProvider.of<
                                                    ProductDetailsCubit
                                                  >(context).selectSize(size);
                                                },
                                                child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        state is SizeSelected &&
                                                                state.size ==
                                                                    size
                                                            ? Theme.of(
                                                              context,
                                                            ).primaryColor
                                                            : AppColors.grey2,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          12.0,
                                                        ),
                                                    child: Text(
                                                      size.name,
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelMedium!.copyWith(
                                                        color:
                                                            state
                                                                        is SizeSelected &&
                                                                    state.size ==
                                                                        size
                                                                ? AppColors
                                                                    .white1
                                                                : AppColors
                                                                    .black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              product.description,
                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(color: AppColors.black),
                            ),
                            SizedBox(height: size.height * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    text: '\$',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: product.price.toString(),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge!.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                BlocBuilder<
                                  ProductDetailsCubit,
                                  ProductDetailsState
                                >(
                                  bloc: cubitProductDetails,
                                  buildWhen:
                                      (previous, current) =>
                                          current is ProductAddedToCart ||
                                          current is ProductAddingToCart,
                                  builder: (context, state) {
                                    if (state is ProductAddingToCart) {
                                      return ElevatedButton(
                                        onPressed: null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryColor,
                                          foregroundColor: AppColors.white1,
                                        ),
                                        child:
                                            const CircularProgressIndicator.adaptive(),
                                      );
                                    } else if (state is ProductAddedToCart) {
                                      return ElevatedButton(
                                        onPressed: null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryColor,
                                          foregroundColor: AppColors.white1,
                                        ),
                                        child: const Text('Added To Cart'),
                                      );
                                    }
                                    return ElevatedButton.icon(
                                      onPressed: () {
                                        if (cubitProductDetails.selectedSize !=
                                            null) {
                                          cubitProductDetails.addToCart(
                                            product.id,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please select size',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryColor,
                                        foregroundColor: AppColors.white1,
                                      ),
                                      label: const Text('Add to Cart'),
                                      icon: const Icon(
                                        Icons.shopping_bag_outlined,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text('Something went wrong!')),
          );
        }
      },
    );
  }
}
