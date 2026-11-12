import 'package:e_commerce_app/Presentation/controller/add_new_card_cubit/payment_methods_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/checkout_cubit/checkout_cubit.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmptyShippingAndPayment extends StatelessWidget {
  final String title;
  final bool isPayment;
  const EmptyShippingAndPayment({
    super.key,
    required this.title,
    required this.isPayment,
  });

  @override
  Widget build(BuildContext context) {
    final checkoutCubit = BlocProvider.of<CheckoutCubit>(context);
    final paymentCubit = BlocProvider.of<PaymentMethodsCubit>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.black;

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isPayment) {
            Navigator.of(context)
                .pushNamed(AppRoute.addNewCardRoute, arguments: paymentCubit)
                .then((_) async => await checkoutCubit.getCheckoutContent());
          } else {
            Navigator.of(context)
                .pushNamed(AppRoute.chooseLocation)
                .then((_) async => await checkoutCubit.getCheckoutContent());
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: AppColors.accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
