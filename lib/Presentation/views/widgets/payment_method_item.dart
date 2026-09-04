import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/domain/entities/payment_card.dart';
import 'package:flutter/material.dart';

class PaymentMethodItem extends StatelessWidget {
  final PaymentCard paymentCard;
  final VoidCallback onItemTapped;
  const PaymentMethodItem({
    super.key,
    required this.paymentCard,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onItemTapped,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.white1,
          border: Border.all(color: AppColors.grey3),
        ),
        child: ListTile(
          leading: CachedNetworkImage(
            imageUrl:
                'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/MasterCard_Logo.svg/1200px-MasterCard_Logo.svg.png',
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          title: const Text('MasterCard'),
          subtitle: Text(paymentCard.cardNumber),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
