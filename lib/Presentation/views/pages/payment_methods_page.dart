import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Presentation/controller/add_new_card_cubit/payment_methods_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/main_button.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:e_commerce_app/core/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  String _maskedCardNumber(String raw) {
    final clean = raw.replaceAll(RegExp(r'\s+'), '');
    if (clean.length <= 4) return clean;
    final last4 = clean.substring(clean.length - 4);
    return '•••• •••• •••• $last4';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<PaymentMethodsCubit>(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final softBg = isDark ? AppColors.surfaceSoftDark : AppColors.surfaceSoft;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('payment_methods')),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(AppRoute.addNewCardRoute, arguments: cubit)
                  .then((_) async => await cubit.fetchPaymentMethods());
            },
            icon: const Icon(Icons.add_card_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<PaymentMethodsCubit, PaymentMethodsState>(
                  bloc: cubit,
                  builder: (context, state) {
                    if (state is FetchingPaymentMethods) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else if (state is FetchPaymentMethodsError &&
                        cubit.cachedCards.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.trError(state.errorMessage),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => cubit.fetchPaymentMethods(),
                              child: Text(context.tr('retry')),
                            ),
                          ],
                        ),
                      );
                    }

                    final cards =
                        state is FetchedPaymentMethods
                            ? state.paymentCards
                            : cubit.cachedCards;
                    final selectedId =
                        state is FetchedPaymentMethods
                            ? (state.selectedPaymentId ?? cubit.selectedPaymentId)
                            : cubit.selectedPaymentId;

                    if (cards.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.credit_card_off_rounded,
                              size: 48,
                              color: AppColors.grey1,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.isArabic
                                  ? 'لا توجد بطاقات دفع محفوظة حالياً'
                                  : 'No saved payment cards yet.',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.isArabic
                                  ? 'أضف بطاقة لاستخدامها عند إتمام الطلب.'
                                  : 'Add a card below to use at checkout.',
                              style: const TextStyle(color: AppColors.grey1),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(
                                        AppRoute.addNewCardRoute,
                                        arguments: cubit,
                                      )
                                      .then(
                                        (_) async =>
                                            await cubit.fetchPaymentMethods(),
                                      );
                                },
                                icon: const Icon(Icons.add_rounded),
                                label: Text(
                                  context.isArabic
                                      ? 'إضافة بطاقة'
                                      : 'Add Card',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RadioGroup<String>(
                      groupValue: selectedId,
                      onChanged: (id) {
                        if (id != null) {
                          cubit.changePaymentMethod(id);
                        }
                      },
                      child: ListView.separated(
                        itemCount: cards.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          final isSelected = selectedId == card.id;
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
                              onTap: () => cubit.changePaymentMethod(card.id),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: softBg,
                                  borderRadius: BorderRadius.circular(10),
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
                                _maskedCardNumber(card.cardNumber),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                '${card.cardHolderName} • Exp ${card.expiryDate}',
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
                                        () =>
                                            cubit.deletePaymentMethod(card.id),
                                  ),
                                  Radio<String>(value: card.id),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              BlocConsumer<PaymentMethodsCubit, PaymentMethodsState>(
                bloc: cubit,
                listenWhen:
                    (previous, current) =>
                        current is ConfirmPaymentSuccess ||
                        current is ConfirmPaymentFailure,
                listener: (context, state) {
                  if (state is ConfirmPaymentSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.trError('Default payment method saved'),
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  } else if (state is ConfirmPaymentFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.trError(state.errorMessage))),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ConfirmPaymentLoading) {
                    return MainButton(isLoading: true);
                  }
                  final hasCards = cubit.cachedCards.isNotEmpty;
                  return MainButton(
                    text:
                        hasCards
                            ? (context.isArabic
                                ? 'تعيين كوسيلة الدفع الافتراضية'
                                : 'Set as Default Payment Method')
                            : (context.isArabic
                                ? 'أضف بطاقة أولاً'
                                : 'Add a Card First'),
                    onTap:
                        hasCards
                            ? () => cubit.confirmPaymentMethod()
                            : () {
                              Navigator.of(context)
                                  .pushNamed(
                                    AppRoute.addNewCardRoute,
                                    arguments: cubit,
                                  )
                                  .then(
                                    (_) async =>
                                        await cubit.fetchPaymentMethods(),
                                  );
                            },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

