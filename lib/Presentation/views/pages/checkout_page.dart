import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Presentation/controller/add_new_card_cubit/payment_methods_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/checkout_cubit/checkout_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/checkout_headlines_item.dart';
import 'package:e_commerce_app/Presentation/views/widgets/empty_shipping_payment.dart';
import 'package:e_commerce_app/Presentation/views/widgets/label_with_value_row.dart';
import 'package:e_commerce_app/Presentation/views/widgets/payment_method_bottom_sheet.dart';
import 'package:e_commerce_app/Presentation/views/widgets/payment_method_item.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:e_commerce_app/domain/entities/location.dart';
import 'package:e_commerce_app/domain/entities/payment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isCashOnDelivery = false;

  Widget _buildPaymentTypeSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final softBg = isDark ? AppColors.surfaceSoftDark : AppColors.surfaceSoft;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PaymentTypeChip(
              icon: Icons.credit_card_rounded,
              label: context.tr('credit_card_title'),
              selected: !_isCashOnDelivery,
              onTap: () => setState(() => _isCashOnDelivery = false),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _PaymentTypeChip(
              icon: Icons.payments_outlined,
              label: context.tr('cod_title'),
              selected: _isCashOnDelivery,
              onTap: () => setState(() => _isCashOnDelivery = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashOnDeliveryCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final textColor = isDark ? AppColors.textDark : AppColors.black;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.grey1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentColor.withValues(alpha: 0.45),
          width: 1.4,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('cod_title'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.tr('cod_sub'),
                  style: TextStyle(color: subtextColor, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.accentColor,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(
    PaymentCard? chosenCard,
    BuildContext context,
  ) {
    final checkoutCubit = BlocProvider.of<CheckoutCubit>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;

    if (chosenCard != null) {
      return PaymentMethodItem(
        paymentCard: chosenCard,
        onItemTapped: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: cardBg,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) {
              return SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.65,
                child: BlocProvider(
                  create: (context) {
                    final cubit = PaymentMethodsCubit();
                    cubit.fetchPaymentMethods();
                    return cubit;
                  },
                  child: const PaymentMethodBottomSheet(),
                ),
              );
            },
          ).then((value) async {
            await checkoutCubit.getCheckoutContent();
          });
        },
      );
    }
    return EmptyShippingAndPayment(
      title: context.tr('add_payment_card'),
      isPayment: true,
    );
  }

  Widget _buildShippingItem(Location? chosenAddress, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final softBg = isDark ? AppColors.surfaceSoftDark : AppColors.surfaceSoft;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.black;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.grey1;

    if (chosenAddress == null) {
      return EmptyShippingAndPayment(
        title: context.tr('add_shipping_address'),
        isPayment: false,
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                chosenAddress.imgUrl.isNotEmpty
                    ? CachedNetworkImage(
                      imageUrl: chosenAddress.imgUrl,
                      width: 84,
                      height: 68,
                      fit: BoxFit.cover,
                      errorWidget:
                          (_, __, ___) => Container(
                            width: 84,
                            height: 68,
                            color: softBg,
                            child: const Icon(
                              Icons.location_on_rounded,
                              size: 32,
                              color: AppColors.accentColor,
                            ),
                          ),
                    )
                    : Container(
                      width: 84,
                      height: 68,
                      color: softBg,
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 32,
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
                  chosenAddress.city,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${chosenAddress.city}, ${chosenAddress.country}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: subtextColor),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.green,
            size: 20,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<CheckoutCubit>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final softBg = isDark ? AppColors.surfaceSoftDark : AppColors.surfaceSoft;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.black;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.grey1;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('checkout')),
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
      ),
      body: BlocBuilder<CheckoutCubit, CheckoutState>(
        bloc: cubit,
        buildWhen:
            (previous, current) =>
                current is CheckoutLoaded ||
                current is CheckoutLoading ||
                current is CheckoutError,
        builder: (context, state) {
          if (state is CheckoutLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (state is CheckoutLoaded) {
            final cartItems = state.cartItems;
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckoutHeadlinesItem(
                      title: context.tr('shipping_address'),
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppRoute.chooseLocation)
                            .then((_) async => await cubit.getCheckoutContent());
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildShippingItem(state.chosenAddress, context),
                    const SizedBox(height: 22),
                    CheckoutHeadlinesItem(
                      title: context.tr('order_items'),
                      numOfProducts: state.numOfProducts,
                    ),
                    const SizedBox(height: 10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final cartItem = cartItems[index];
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 76,
                                width: 76,
                                decoration: BoxDecoration(
                                  color: softBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: cartItem.product.imgUrl,
                                    fit: BoxFit.contain,
                                    errorWidget:
                                        (_, __, ___) => const Icon(
                                          Icons.image_not_supported_outlined,
                                          color: AppColors.grey1,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall!.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${context.tr('size_label')}: ${cartItem.size.name}  •  ${context.tr('qty')}: ${cartItem.quantity}',
                                      style: TextStyle(
                                        color: subtextColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppColors.accentColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    CheckoutHeadlinesItem(
                      title: context.tr('payment_methods'),
                      onTap:
                          _isCashOnDelivery
                              ? null
                              : () {
                                Navigator.of(context)
                                    .pushNamed(AppRoute.paymentMethodsRoute)
                                    .then(
                                      (_) async =>
                                          await cubit.getCheckoutContent(),
                                    );
                              },
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentTypeSelector(context),
                    const SizedBox(height: 12),
                    _isCashOnDelivery
                        ? _buildCashOnDeliveryCard(context)
                        : _buildPaymentMethodItem(
                          state.chosenPaymentCard,
                          context,
                        ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          LabelWithValueRow(
                            label: context.tr('subtotal'),
                            value: '\$${state.subtotal.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 8),
                          LabelWithValueRow(
                            label: context.tr('shipping'),
                            value:
                                '\$${state.shippingValue.toStringAsFixed(2)}',
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: borderColor),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr('total_amount'),
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                              ),
                              Text(
                                '\$${state.totalAmount.toStringAsFixed(2)}',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge!.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    BlocConsumer<CheckoutCubit, CheckoutState>(
                      bloc: cubit,
                      listenWhen:
                          (previous, current) =>
                              current is CheckoutOrderPlaced ||
                              current is CheckoutOrderError,
                      listener: (context, orderState) {
                        if (orderState is CheckoutOrderPlaced) {
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (dialogContext) {
                              return AlertDialog(
                                icon: const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.green,
                                  size: 48,
                                ),
                                title: Text(context.tr('order_placed_title')),
                                content: Text(
                                  context.tr('order_placed_sub'),
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pushNamedAndRemoveUntil(
                                        AppRoute.homeRoute,
                                        (route) => false,
                                      );
                                    },
                                    child: Text(context.tr('back_to_home')),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (orderState is CheckoutOrderError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.trError(orderState.message))),
                          );
                        }
                      },
                      buildWhen:
                          (previous, current) =>
                              current is CheckoutPlacingOrder ||
                              current is CheckoutLoaded ||
                              current is CheckoutOrderError ||
                              current is CheckoutOrderPlaced,
                      builder: (context, orderState) {
                        final isPlacing = orderState is CheckoutPlacingOrder;
                        return ElevatedButton(
                          onPressed:
                              isPlacing
                                  ? null
                                  : () => cubit.placeOrder(
                                    isCashOnDelivery: _isCashOnDelivery,
                                  ),
                          child:
                              isPlacing
                                  ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator.adaptive(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    _isCashOnDelivery
                                        ? context.tr('confirm_order_cod')
                                        : context.tr('place_order'),
                                  ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (state is CheckoutError) {
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
                      onPressed: () => cubit.getCheckoutContent(),
                      child: Text(context.tr('refresh')),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(
            child: Text(
              context.isArabic ? 'حدث خطأ ما!' : 'Something went wrong!',
              style: TextStyle(color: textColor),
            ),
          );
        },
      ),
    );
  }
}

class _PaymentTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTypeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? AppColors.white1 : AppColors.grey1,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.white1
                      : (isDark ? AppColors.textDark : AppColors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
