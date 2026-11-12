import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Presentation/controller/add_new_card_cubit/payment_methods_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/main_button.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:e_commerce_app/core/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentMethodBottomSheet extends StatelessWidget {
  const PaymentMethodBottomSheet({super.key});

  String _maskedCardNumber(String raw) {
    final clean = raw.replaceAll(RegExp(r'\s+'), '');
    if (clean.length <= 4) return clean;
    final last4 = clean.substring(clean.length - 4);
    return '•••• •••• •••• $last4';
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethodsCubit = BlocProvider.of<PaymentMethodsCubit>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final softBg = isDark ? AppColors.surfaceSoftDark : AppColors.surfaceSoft;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('payment_methods'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                BlocBuilder<PaymentMethodsCubit, PaymentMethodsState>(
                  bloc: paymentMethodsCubit,
                  builder: (_, state) {
                    if (state is FetchingPaymentMethods) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
                    } else if (state is FetchPaymentMethodsError &&
                        paymentMethodsCubit.cachedCards.isEmpty) {
                      return Center(child: Text(context.trError(state.errorMessage)));
                    }

                    final paymentCards =
                        state is FetchedPaymentMethods
                            ? state.paymentCards
                            : paymentMethodsCubit.cachedCards;
                    final selectedId =
                        state is FetchedPaymentMethods
                            ? (state.selectedPaymentId ??
                                paymentMethodsCubit.selectedPaymentId)
                            : paymentMethodsCubit.selectedPaymentId;

                    if (paymentCards.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          context.isArabic
                              ? 'لا توجد بطاقات محفوظة. اضغط على إضافة بطاقة جديدة أدناه.'
                              : 'No saved cards yet. Tap Add New Card below.',
                          style: const TextStyle(color: AppColors.grey1),
                        ),
                      );
                    }

                    return RadioGroup<String>(
                      groupValue: selectedId,
                      onChanged: (id) {
                        if (id != null) {
                          paymentMethodsCubit.changePaymentMethod(id);
                        }
                      },
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: paymentCards.length,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          final paymentCard = paymentCards[index];
                          final isSelected = selectedId == paymentCard.id;
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color:
                                    isSelected
                                        ? AppColors.accentColor
                                        : borderColor,
                                width: isSelected ? 1.6 : 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              onTap:
                                  () => paymentMethodsCubit.changePaymentMethod(
                                    paymentCard.id,
                                  ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: softBg,
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: ImageUtils.masterCardUrl,
                                  width: 34,
                                  height: 26,
                                  fit: BoxFit.contain,
                                  errorWidget:
                                      (_, __, ___) => const Icon(
                                        Icons.credit_card_rounded,
                                        color: AppColors.primaryColor,
                                      ),
                                ),
                              ),
                              title: Text(
                                _maskedCardNumber(paymentCard.cardNumber),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                '${paymentCard.cardHolderName} • Exp ${paymentCard.expiryDate}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.red,
                                      size: 20,
                                    ),
                                    onPressed:
                                        () => paymentMethodsCubit
                                            .deletePaymentMethod(paymentCard.id),
                                  ),
                                  Radio<String>(value: paymentCard.id),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(
                            AppRoute.addNewCardRoute,
                            arguments: paymentMethodsCubit,
                          )
                          .then(
                            (_) async =>
                                await paymentMethodsCubit.fetchPaymentMethods(),
                          );
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentSoft,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.accentColor,
                      ),
                    ),
                    title: Text(
                      context.isArabic
                          ? 'إضافة بطاقة جديدة'
                          : 'Add New Card',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                BlocConsumer<PaymentMethodsCubit, PaymentMethodsState>(
                  bloc: paymentMethodsCubit,
                  listenWhen:
                      (previous, current) =>
                          current is ConfirmPaymentSuccess ||
                          current is ConfirmPaymentFailure,
                  buildWhen:
                      (previous, current) =>
                          current is ConfirmPaymentLoading ||
                          current is ConfirmPaymentSuccess ||
                          current is ConfirmPaymentFailure,
                  listener: (context, state) {
                    if (state is ConfirmPaymentSuccess) {
                      Navigator.of(context).pop();
                    } else if (state is ConfirmPaymentFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.trError(state.errorMessage))),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is ConfirmPaymentLoading) {
                      return MainButton(isLoading: true, onTap: null);
                    }
                    return MainButton(
                      text: context.isArabic
                          ? 'تأكيد وسيلة الدفع'
                          : 'Confirm Payment Method',
                      onTap: () => paymentMethodsCubit.confirmPaymentMethod(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
