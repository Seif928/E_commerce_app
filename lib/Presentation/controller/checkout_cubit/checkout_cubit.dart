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
      final cartItems = await _cartRepository.fetchCartItems(currentUserId!);
      double shippingValue = 10;
      final subtotal = cartItems.fold(
        0.0,
        (previousValue, element) =>
            previousValue + (element.product.price * element.quantity),
      );
      final numOfProducts = cartItems.fold(
        0,
        (previousValue, element) => previousValue + element.quantity,
      );

      final chosenPaymentCard = (await _checkoutRepository.fetchPaymentMethods(
        currentUserId,
      )).first;

      final locations = await _locationRepository.fetchLocations(
        currentUserId,
        chosen: true,
      );
      final chosenAddress = locations.isNotEmpty ? locations.first : null;

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
      emit(CheckoutError(e.toString()));
    }
  }
}