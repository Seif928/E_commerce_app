import 'package:e_commerce_app/Presentation/controller/cart_cubit/cart_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/cart_item_widget.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dash/flutter_dash.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.black;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.grey1;

    return BlocProvider(
      create: (context) {
        final cubit = CartCubit();
        cubit.getCartItems();
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil(
                  AppRoute.homeRoute,
                  (route) => false,
                );
              }
            },
            icon: Icon(
              context.isArabic
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_back_ios_new_rounded,
              size: 18,
            ),
          ),
          title: Text(context.tr('cart_title')),
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              final cubit = BlocProvider.of<CartCubit>(context);
              return BlocBuilder<CartCubit, CartState>(
                bloc: cubit,
                buildWhen:
                    (previous, current) =>
                        current is CartLoaded ||
                        current is CartLoading ||
                        current is CartError,
                builder: (context, state) {
                  if (state is CartLoading) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  } else if (state is CartLoaded) {
                    final cartItems = state.cartItems;
                    if (cartItems.isEmpty) {
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
                                  Icons.shopping_bag_outlined,
                                  size: 46,
                                  color: AppColors.grey1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.tr('cart_empty'),
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                context.tr('cart_empty_sub'),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: subtextColor),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () => cubit.getCartItems(),
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                              itemCount: cartItems.length,
                              itemBuilder:
                                   (context, index) => CartItemWidget(
                                     cartItem: cartItems[index],
                                   ),
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 14),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            border: Border(
                              top: BorderSide(color: borderColor),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.05,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _summaryRow(
                                context,
                                title: context.tr('subtotal'),
                                amount: state.subtotal,
                                textColor: textColor,
                                subtextColor: subtextColor,
                              ),
                              _summaryRow(
                                context,
                                title: context.tr('shipping'),
                                amount: 10,
                                textColor: textColor,
                                subtextColor: subtextColor,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Dash(
                                  dashColor: borderColor,
                                  length:
                                      MediaQuery.of(context).size.width - 44,
                                ),
                              ),
                              _summaryRow(
                                context,
                                title: context.tr('total'),
                                amount: state.subtotal + 10,
                                isTotal: true,
                                textColor: textColor,
                                subtextColor: subtextColor,
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pushNamed(AppRoute.checkoutRoute).then((_) {
                                    if (context.mounted) {
                                      cubit.getCartItems();
                                    }
                                  });
                                },
                                child: Text(context.tr('checkout')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else if (state is CartError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.trError(state.message),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: textColor),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => cubit.getCartItems(),
                              child: Text(context.tr('refresh')),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Center(child: Text('Something went wrong!'));
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context, {
    required String title,
    required double amount,
    bool isTotal = false,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: isTotal ? textColor : subtextColor,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal ? AppColors.accentColor : textColor,
            ),
          ),
        ],
      ),
    );
  }
}
