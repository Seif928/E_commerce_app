import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Presentation/controller/favorite_cubit/favorite_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/product_details_cubit/product_details_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/counter_widget.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:e_commerce_app/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productId;
  const ProductDetailsPage({super.key, required this.productId});

  void _navigateBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil(AppRoute.homeRoute, (route) => false);
    }
  }

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
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => _navigateBack(context),
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
              title: const Text('Product Details'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () =>
                              cubitProductDetails.getProductDetails(productId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is ProductDetailsLoaded) {
          final product = state.product;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
          final softBg = isDark ? AppColors.surfaceSoftDark : AppColors.surfaceSoft;
          final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
          final textColor = isDark ? AppColors.textDark : AppColors.black;
          final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.grey1;

          return Scaffold(
            backgroundColor: isDark ? AppColors.scaffoldBgDark : AppColors.surfaceSoft,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: cardBg,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _navigateBack(context),
                    child: Icon(
                      context.isArabic
                          ? Icons.arrow_forward_ios_rounded
                          : Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              title: Text(
                context.trCategory(product.category),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: BlocConsumer<FavoriteCubit, FavoriteState>(
                    bloc: cubitFavoriteProduct,
                    listenWhen:
                        (previous, current) =>
                            current is FavoriteRemoveError ||
                            current is SetFavoriteLoadedError,
                    listener: (context, favState) {
                      if (favState is FavoriteRemoveError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(favState.error)),
                        );
                      } else if (favState is SetFavoriteLoadedError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(favState.error)),
                        );
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
                    builder: (context, favState) {
                      final isFavLoading =
                          (favState is SetFavoriteLoading &&
                              favState.productId == product.id) ||
                          (favState is FavoriteRemoving &&
                              favState.productId == product.id);
                      final isFav =
                          favState is FavoriteLoaded
                              ? favState.favoriteProducts.any(
                                (p) => p.id == product.id,
                              )
                              : product.isFavorite;

                      return Material(
                        color: cardBg,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap:
                              isFavLoading
                                  ? null
                                  : () => cubitFavoriteProduct.setFavorite(
                                    product,
                                  ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child:
                                isFavLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator.adaptive(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Icon(
                                      isFav
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color:
                                          isFav
                                              ? AppColors.red
                                              : textColor,
                                      size: 20,
                                    ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                SizedBox(
                  height: size.height * 0.32,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28.0,
                      vertical: 12.0,
                    ),
                    child: Hero(
                      tag: 'product_${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: product.imgUrl,
                        fit: BoxFit.contain,
                        placeholder:
                            (_, __) => const Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                        errorWidget:
                            (_, __, ___) => const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: AppColors.grey1,
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall!.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceSoftDark
                                      : AppColors.accentSoft,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.yellow,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      product.averageRate.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr('select_size'),
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
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
                                builder: (context, qtyState) {
                                  final qty =
                                      qtyState is QuantityCounterLoaded
                                          ? qtyState.value
                                          : cubitProductDetails.quantity;
                                  return CounterWidget(
                                    value: qty,
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
                          const SizedBox(height: 12),
                          BlocBuilder<
                            ProductDetailsCubit,
                            ProductDetailsState
                          >(
                            bloc: cubitProductDetails,
                            buildWhen:
                                (previous, current) =>
                                    current is SizeSelected ||
                                    current is ProductDetailsLoaded,
                            builder: (context, sizeState) {
                              final currentSize =
                                  sizeState is SizeSelected
                                      ? sizeState.size
                                      : cubitProductDetails.selectedSize;
                              return Wrap(
                                spacing: 10,
                                children:
                                    ProductSize.values.map((itemSize) {
                                      final isSelected =
                                          currentSize == itemSize;
                                      return ChoiceChip(
                                        label: Text(itemSize.name),
                                        selected: isSelected,
                                        showCheckmark: false,
                                        selectedColor:
                                            isDark
                                                ? AppColors.accentColor
                                                : AppColors.primaryColor,
                                        backgroundColor: softBg,
                                        labelStyle: TextStyle(
                                          color:
                                              isSelected
                                                  ? AppColors.white1
                                                  : textColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          side: BorderSide(
                                            color:
                                                isSelected
                                                    ? (isDark
                                                        ? AppColors.accentColor
                                                        : AppColors.primaryColor)
                                                    : borderColor,
                                          ),
                                        ),
                                        onSelected:
                                            (_) => cubitProductDetails
                                                .selectSize(itemSize),
                                      );
                                    }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            context.tr('description'),
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description.isNotEmpty
                                ? product.description
                                : context.tr('default_product_desc'),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.copyWith(
                              color: subtextColor,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(
                  top: BorderSide(color: borderColor),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.3 : 0.05,
                    ),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('price'),
                          style: TextStyle(
                            color: subtextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
                          bloc: cubitProductDetails,
                          buildWhen:
                              (previous, current) =>
                                  current is QuantityCounterLoaded ||
                                  current is ProductDetailsLoaded,
                          builder: (context, qtyState) {
                            final qty =
                                qtyState is QuantityCounterLoaded
                                    ? qtyState.value
                                    : cubitProductDetails.quantity;
                            return Text(
                              '\$${(product.price * qty).toStringAsFixed(2)}',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.accentColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: BlocConsumer<
                        ProductDetailsCubit,
                        ProductDetailsState
                      >(
                        bloc: cubitProductDetails,
                        listenWhen:
                            (previous, current) =>
                                current is ProductAddedToCart ||
                                current is ProductAddToCartError,
                        listener: (context, cartState) {
                          if (cartState is ProductAddedToCart) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.tr('item_added_to_cart'),
                                ),
                              ),
                            );
                          } else if (cartState is ProductAddToCartError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.trError(cartState.message),
                                ),
                              ),
                            );
                          }
                        },
                        buildWhen:
                            (previous, current) =>
                                current is ProductAddedToCart ||
                                current is ProductAddingToCart ||
                                current is ProductAddToCartError ||
                                current is SizeSelected ||
                                current is QuantityCounterLoaded,
                        builder: (context, cartState) {
                          if (cartState is ProductAddingToCart) {
                            return const ElevatedButton(
                              onPressed: null,
                              child: SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          final isAdded = cartState is ProductAddedToCart;
                          return ElevatedButton.icon(
                            onPressed:
                                isAdded
                                    ? null
                                    : () {
                                      if (cubitProductDetails.selectedSize !=
                                          null) {
                                        cubitProductDetails.addToCart(
                                          product.id,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              context.trError(
                                                'Please select a size first',
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                            icon: Icon(
                              isAdded
                                  ? Icons.check_circle_outline
                                  : Icons.shopping_bag_outlined,
                            ),
                            label: Text(
                              isAdded
                                  ? context.tr('item_added_to_cart')
                                  : context.tr('add_to_cart'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
