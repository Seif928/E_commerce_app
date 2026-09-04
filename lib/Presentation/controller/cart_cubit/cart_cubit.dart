import 'package:e_commerce_app/data/repositories/auth_repository_impl.dart';
import 'package:e_commerce_app/data/repositories/cart_repository_impl.dart';
import 'package:e_commerce_app/domain/entities/cart_item.dart';
import 'package:e_commerce_app/domain/repositories/auth_repository.dart';
import 'package:e_commerce_app/domain/repositories/cart_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({CartRepository? cartRepository, AuthRepository? authRepository})
    : _cartRepository = cartRepository ?? CartRepositoryImpl(),
      _authRepository = authRepository ?? AuthRepositoryImpl(),
      super(CartInitial());
  int quantity = 1;

  final CartRepository _cartRepository;
  final AuthRepository _authRepository;

  Future<void> getCartItems() async {
    emit(CartLoading());
    try {
      final currentUserId = _authRepository.currentUserId;
      final cartItems = await _cartRepository.fetchCartItems(currentUserId!);

      emit(CartLoaded(cartItems, _subtotal(cartItems)));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> removeCartItem(String cartItem) async {
    try {
      final currentUserId = _authRepository.currentUserId;
      await _cartRepository.removeCartItem(currentUserId!, cartItem);
      final cartItems = await _cartRepository.fetchCartItems(currentUserId);
      emit(CartLoaded(cartItems, _subtotal(cartItems)));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> incrementCounter(CartItem cartItem) async {
    try {
      final updatedCartItem = cartItem.copyWith(
        quantity: cartItem.quantity + 1,
      );
      final currentUserId = _authRepository.currentUserId;

      await _cartRepository.setCartItem(currentUserId!, updatedCartItem);
      final cartItems = await _cartRepository.fetchCartItems(currentUserId);
      emit(CartLoaded(cartItems, _subtotal(cartItems)));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> decrementCounter(CartItem cartItem) async {
    if (cartItem.quantity <= 1) return;
    try {
      final updatedCartItem = cartItem.copyWith(
        quantity: cartItem.quantity - 1,
      );
      final currentUserId = _authRepository.currentUserId;

      await _cartRepository.setCartItem(currentUserId!, updatedCartItem);
      final cartItems = await _cartRepository.fetchCartItems(currentUserId);
      emit(CartLoaded(cartItems, _subtotal(cartItems)));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  double _subtotal(List<CartItem> cartItems) => cartItems.fold<double>(
    0,
    (previousValue, item) =>
        previousValue + (item.product.price * item.quantity),
  );
}