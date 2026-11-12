import 'package:e_commerce_app/Presentation/controller/add_new_card_cubit/payment_methods_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/label_with_textfield.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewCardPage extends StatefulWidget {
  const AddNewCardPage({super.key});

  @override
  State<AddNewCardPage> createState() => _AddNewCardPageState();
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 19 ? digits.substring(0, 19) : digits;
    final buffer = StringBuffer();
    for (int i = 0; i < clipped.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clipped[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 6 ? digits.substring(0, 6) : digits;
    final formatted =
        clipped.length > 2
            ? '${clipped.substring(0, 2)}/${clipped.substring(2)}'
            : clipped;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _AddNewCardPageState extends State<AddNewCardPage> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String _formattedCardDisplay(String raw) {
    final clean = raw.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return '•••• •••• •••• ••••';
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length && i < 19; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }

  String _cardBrandLabel(String raw) {
    final clean = raw.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('4')) return 'VISA';
    if (clean.startsWith('5') || clean.startsWith('2')) return 'MASTERCARD';
    if (clean.startsWith('3')) return 'AMEX';
    return 'VERVE PAY';
  }

  String _normalizedExpiry(String raw) {
    final text = raw.trim().replaceAll(RegExp(r'\s+'), '');
    if (RegExp(r'^(0[1-9]|1[0-2])/\d{4}$').hasMatch(text)) {
      return '${text.substring(0, 3)}${text.substring(5)}';
    }
    if (!text.contains('/') && text.length == 4) {
      return '${text.substring(0, 2)}/${text.substring(2)}';
    }
    if (!text.contains('/') && text.length == 6) {
      return '${text.substring(0, 2)}/${text.substring(4)}';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<PaymentMethodsCubit>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.isArabic ? 'إضافة بطاقة جديدة' : 'Add New Card'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryColor, Color(0xFF283044)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _cardBrandLabel(_cardNumberController.text),
                              style: const TextStyle(
                                color: AppColors.white1,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.contactless_rounded,
                            color: AppColors.white1,
                            size: 26,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _formattedCardDisplay(_cardNumberController.text),
                        style: const TextStyle(
                          color: AppColors.white1,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.isArabic ? 'صاحب البطاقة' : 'CARD HOLDER',
                                style: TextStyle(
                                  color: AppColors.white1.withValues(
                                    alpha: 0.65,
                                  ),
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _cardHolderNameController.text.trim().isEmpty
                                    ? (context.isArabic ? 'اسمك هنا' : 'YOUR NAME')
                                    : _cardHolderNameController.text
                                        .trim()
                                        .toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.white1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                context.isArabic ? 'تاريخ الانتهاء' : 'EXPIRES',
                                style: TextStyle(
                                  color: AppColors.white1.withValues(
                                    alpha: 0.65,
                                  ),
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _expiryDateController.text.trim().isEmpty
                                    ? 'MM/YY'
                                    : _expiryDateController.text.trim(),
                                style: const TextStyle(
                                  color: AppColors.white1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      LabelWithTextField(
                        label: context.isArabic ? 'رقم البطاقة' : 'Card Number',
                        controller: _cardNumberController,
                        prefixIcon: Icons.credit_card_rounded,
                        hintText: '1234 5678 9012 3456',
                        keyboardType: TextInputType.number,
                        inputFormatters: [_CardNumberInputFormatter()],
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          final digits = (value ?? '').replaceAll(
                            RegExp(r'\s+'),
                            '',
                          );
                          if (digits.length < 12 || digits.length > 19) {
                            return context.isArabic
                                ? 'أدخل من 12 إلى 19 رقماً'
                                : 'Enter 12-19 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      LabelWithTextField(
                        label: context.isArabic ? 'اسم صاحب البطاقة' : 'Card Holder Name',
                        controller: _cardHolderNameController,
                        prefixIcon: Icons.person_outline_rounded,
                        hintText: context.isArabic ? 'الاسم الكامل كما هو مدون على البطاقة' : 'Full name on card',
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: LabelWithTextField(
                              label: context.isArabic ? 'تاريخ الانتهاء' : 'Expiry Date',
                              controller: _expiryDateController,
                              prefixIcon: Icons.date_range_rounded,
                              hintText: 'MM/YY',
                              keyboardType: TextInputType.number,
                              inputFormatters: [_ExpiryDateInputFormatter()],
                              onChanged: (_) => setState(() {}),
                              validator: (value) {
                                final normalized = _normalizedExpiry(
                                  value ?? '',
                                );
                                if (!RegExp(
                                  r'^(0[1-9]|1[0-2])/\d{2}$',
                                ).hasMatch(normalized)) {
                                  return context.isArabic
                                      ? 'استخدم صيغة MM/YY (مثال: 12/28)'
                                      : 'Use MM/YY (e.g. 12/28)';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: LabelWithTextField(
                              label: 'CVV',
                              controller: _cvvController,
                              prefixIcon: Icons.lock_outline_rounded,
                              hintText: '123',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              obsecureText: true,
                              validator: (value) {
                                final digits = (value ?? '').trim();
                                if (digits.length < 3 || digits.length > 4) {
                                  return context.isArabic
                                      ? '3 أو 4 أرقام'
                                      : '3-4 digits';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                BlocConsumer<PaymentMethodsCubit, PaymentMethodsState>(
                  bloc: cubit,
                  listenWhen:
                      (previous, current) =>
                          current is AddNewCardFailure ||
                          current is AddNewCardSuccess,
                  listener: (context, state) {
                    if (state is AddNewCardSuccess) {
                      Navigator.pop(context);
                    } else if (state is AddNewCardFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.trError(state.errorMessage))),
                      );
                    }
                  },
                  buildWhen:
                      (previous, current) =>
                          current is AddNewCardLoading ||
                          current is AddNewCardFailure ||
                          current is AddNewCardSuccess,
                  builder: (context, state) {
                    if (state is AddNewCardLoading) {
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
                    return ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          cubit.addNewCard(
                            _cardNumberController.text,
                            _cardHolderNameController.text,
                            _expiryDateController.text,
                            _cvvController.text,
                          );
                        }
                      },
                      child: Text(context.tr('save')),
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
