import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Presentation/controller/home_cubit/home_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/product_item.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class HomeTabView extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?>? onCategorySelected;
  final VoidCallback? onShowAll;

  const HomeTabView({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
    this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.black;

    return BlocBuilder<HomeCubit, HomeState>(
      bloc: BlocProvider.of<HomeCubit>(context),
      buildWhen:
          (previous, current) =>
              current is HomeLoaded ||
              current is HomeLoading ||
              current is HomeError,
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (state is HomeLoaded) {
          final displayedProducts =
              selectedCategory == null
                  ? state.products
                  : state.products
                      .where(
                        (p) =>
                            p.category.toLowerCase() ==
                            selectedCategory!.toLowerCase(),
                      )
                      .toList();

          final filterChips = [
            'All',
            ...state.categories
                .where((c) => c.name != 'All Products')
                .map((c) => c.name),
          ];

          return RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().getHomeData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FlutterCarousel.builder(
                    itemCount: state.carouselItems.length,
                    itemBuilder: (context, itemIndex, pageViewIndex) {
                      final banner = state.carouselItems[itemIndex];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: GestureDetector(
                          onTap: () {
                            final matchesProduct = state.products.any(
                              (p) => p.id == banner.id,
                            );
                            if (matchesProduct) {
                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pushNamed(
                                AppRoute.productDetailsRoute,
                                arguments: banner.id,
                              );
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  color:
                                      isDark
                                          ? AppColors.surfaceCardDark
                                          : AppColors.primaryColor,
                                ),
                                CachedNetworkImage(
                                  imageUrl: banner.imgUrl,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => const Center(
                                        child:
                                            CircularProgressIndicator.adaptive(),
                                      ),
                                  errorWidget:
                                      (context, url, error) => const Center(
                                        child: Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 40,
                                          color: AppColors.grey1,
                                        ),
                                      ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.75),
                                      ],
                                      stops: const [0.45, 1.0],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 18,
                                  bottom: 18,
                                  right: 18,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentColor,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          context.tr('featured').toUpperCase(),
                                          style: const TextStyle(
                                            color: AppColors.white1,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        context.isArabic
                                            ? 'تشكيلات جديدة وحصرية'
                                            : 'Live Collection Arrivals',
                                        style: const TextStyle(
                                          color: AppColors.white1,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    options: FlutterCarouselOptions(
                      height: 175,
                      viewportFraction: 1.0,
                      showIndicator: true,
                      autoPlay: true,
                      slideIndicator: CircularWaveSlideIndicator(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filterChips.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final label = filterChips[index];
                        final displayLabel =
                            label == 'All'
                                ? context.tr('all')
                                : context.trCategory(label);
                        final isSelected =
                            (label == 'All' && selectedCategory == null) ||
                            (selectedCategory != null &&
                                label.toLowerCase() ==
                                    selectedCategory!.toLowerCase());
                        return ChoiceChip(
                          label: Text(displayLabel),
                          selected: isSelected,
                          showCheckmark: false,
                          selectedColor:
                              isDark
                                  ? AppColors.accentColor
                                  : AppColors.primaryColor,
                          backgroundColor: cardBg,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.white1 : textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color:
                                  isSelected
                                      ? (isDark
                                          ? AppColors.accentColor
                                          : AppColors.primaryColor)
                                      : borderColor,
                            ),
                          ),
                          onSelected: (_) {
                            onCategorySelected?.call(
                              label == 'All' ? null : label,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedCategory != null
                            ? context.trCategory(selectedCategory!)
                            : context.tr('trending_products'),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      TextButton(
                        onPressed: onShowAll,
                        child: Text(
                          selectedCategory != null
                              ? context.tr('view_all')
                              : context.tr('refresh'),
                          style: const TextStyle(
                            color: AppColors.accentColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (displayedProducts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          context.isArabic
                              ? 'لا توجد منتجات في هذه الفئة'
                              : 'No products found in this category',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      itemCount: displayedProducts.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.65,
                          ),
                      itemBuilder: (context, index) {
                        final product = displayedProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(
                              AppRoute.productDetailsRoute,
                              arguments: product.id,
                            );
                          },
                          child: ProductItem(productItem: product),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        } else if (state is HomeError) {
          return Center(
            child: Text(state.message, style: TextStyle(color: textColor)),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
