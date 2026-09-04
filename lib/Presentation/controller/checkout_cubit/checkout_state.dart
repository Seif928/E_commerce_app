part of 'checkout_cubit.dart';

sealed class CheckoutState {}

final class CheckoutInitial extends CheckoutState {}

final class CheckoutLoading extends CheckoutState {}

final class CheckoutLoaded extends CheckoutState {
  final List<CartItem> cartItems;
  final double totalAmount;
  final double subtotal;
  final double shippingValue;
  final int numOfProducts;
  final PaymentCard? chosenPaymentCard;
  final Location? chosenAddress;

  CheckoutLoaded({
    required this.cartItems,
    required this.totalAmount,
    required this.shippingValue,
    required this.subtotal,
    required this.numOfProducts,
    this.chosenPaymentCard,
    this.chosenAddress,
  });
}

final class CheckoutError extends CheckoutState {
  final String message;

  CheckoutError(
    this.message,
  );
}
