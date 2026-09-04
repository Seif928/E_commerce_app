import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Presentation/controller/cart_cubit/cart_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/counter_widget.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/domain/entities/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  const CartItemWidget({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<CartCubit>(context);
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, right: 2.0, bottom: 8.0),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.grey2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CachedNetworkImage(
              imageUrl: cartItem.product.imgUrl,
              height: 125,
              width: 125,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: InkWell(
                      onTap: () => cubit.removeCartItem(cartItem.id),
                      child: Icon(Icons.delete, color: AppColors.red),
                    ),
                  ),
                ),
                Text(
                  cartItem.product.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4.0),
                Text.rich(
                  TextSpan(
                    text: 'Size: ',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(color: AppColors.grey1),
                    children: [
                      TextSpan(
                        text: cartItem.size.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: CounterWidget(
                        value: cartItem.quantity,
                        onIncrement: () => cubit.incrementCounter(cartItem),
                        onDecrement: () => cubit.decrementCounter(cartItem),
                      ),
                    ),
                    Text(
                      '\$${cartItem.totalPrice.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
