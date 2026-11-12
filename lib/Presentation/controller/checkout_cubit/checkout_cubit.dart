import 'package:e_commerce_app/data/repositories/auth_repository_impl.dart';
import 'package:e_commerce_app/data/repositories/cart_repository_impl.dart';
import 'package:e_commerce_app/data/repositories/checkout_repository_impl.dart';
import 'package:e_commerce_app/data/repositories/location_repository_impl.dart';
import 'package:e_commerce_app/domain/entities/cart_item.dart';
import 'package:e_commerce_app/domain/entities/location.dart';
import 'package:e_commerce_app/domain/entities/payment_card.dart';
import 'package:e_commerce_app/domain/repositories/auth_repository.dart';
import 'package:e_commerce_app/domain/repositories/cart_repository.dart';
import 'package:e_commerce_app/domain/repositories/checkout_repository.dart';
import 'package:e_commerce_app/domain/repositories/location_repository.dart';
import 'package:e_commerce_app/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    CartRepository? cartRepository,
    CheckoutRepository? checkoutRepository,
    LocationRepository? locationRepository,
    AuthRepository? authRepository,
  }) : _cartRepository = cartRepository ?? CartRepositoryImpl(),
       _checkoutRepository = checkoutRepository ?? CheckoutRepositoryImpl(),
       _locationRepository = locationRepository ?? LocationRepositoryImpl(),
       _authRepository = authRepository ?? AuthRepositoryImpl(),
       super(CheckoutInitial());

  final CartRepository _cartRepository;
  final CheckoutRepository _checkoutRepository;
  final LocationRepository _locationRepository;
  final AuthRepository _authRepository;

  Future<void> getCheckoutContent() async {
    emit(CheckoutLoading());
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(CheckoutError('User is not logged in'));
        return;
      }
      final cartItems = await _cartRepository.fetchCartItems(currentUserId);
      final double shippingValue = cartItems.isEmpty ? 0 : 10;
      final subtotal = cartItems.fold(
        0.0,
        (previousValue, element) =>
            previousValue + (element.product.price * element.quantity),
      );
      final numOfProducts = cartItems.fold(
        0,
        (previousValue, element) => previousValue + element.quantity,
      );

      final paymentCards = await _checkoutRepository.fetchPaymentMethods(
        currentUserId,
      );
      PaymentCard? chosenPaymentCard;
      for (final card in paymentCards) {
        if (card.isChosen) {
          chosenPaymentCard = card;
          break;
        }
      }
      chosenPaymentCard ??=
          paymentCards.isNotEmpty ? paymentCards.first : null;

      final chosenLocations = await _locationRepository.fetchLocations(
        currentUserId,
        chosen: true,
      );
      Location? chosenAddress =
          chosenLocations.isNotEmpty ? chosenLocations.first : null;
      if (chosenAddress == null) {
        final allLocations = await _locationRepository.fetchLocations(
          currentUserId,
        );
        if (allLocations.isNotEmpty) {
          chosenAddress = allLocations.first;
        }
      }

      if (isClosed) return;
      emit(
        CheckoutLoaded(
          cartItems: cartItems,
          totalAmount: subtotal + shippingValue,
          subtotal: subtotal,
          shippingValue: shippingValue,
          numOfProducts: numOfProducts,
          chosenPaymentCard: chosenPaymentCard,
          chosenAddress: chosenAddress,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(CheckoutError(e.toString()));
    }
  }

  Future<void> placeOrder({bool isCashOnDelivery = false}) async {
    final currentState = state;
    if (currentState is! CheckoutLoaded) return;
    if (currentState.cartItems.isEmpty) {
      emit(CheckoutOrderError('Your cart is empty'));
      emit(currentState);
      return;
    }
    if (currentState.chosenAddress == null) {
      emit(CheckoutOrderError('Please select a shipping address'));
      emit(currentState);
      return;
    }
    if (!isCashOnDelivery && currentState.chosenPaymentCard == null) {
      emit(
        CheckoutOrderError(
          'Please select a payment card or choose Cash on Delivery',
        ),
      );
      emit(currentState);
      return;
    }

    emit(CheckoutPlacingOrder());
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(CheckoutOrderError('User is not logged in'));
        emit(currentState);
        return;
      }
      await _checkoutRepository.placeOrder(
        userId: currentUserId,
        items: currentState.cartItems,
        subtotal: currentState.subtotal,
        shipping: currentState.shippingValue,
        totalAmount: currentState.totalAmount,
        address: currentState.chosenAddress!,
        paymentCard: currentState.chosenPaymentCard,
        isCashOnDelivery: isCashOnDelivery,
      );
      final generatedOrderId = DateTime.now().millisecondsSinceEpoch.toString();
      await NotificationService.instance.showOrderPlacedNotification(
        orderId: generatedOrderId,
        totalAmount: currentState.totalAmount,
      );
      if (isClosed) return;
      emit(CheckoutOrderPlaced());
    } catch (e) {
      if (isClosed) return;
      emit(CheckoutOrderError(e.toString()));
      emit(currentState);
    }
  }
}
