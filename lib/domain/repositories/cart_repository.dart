import 'package:e_commerce_app/domain/entities/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> fetchCartItems(String userId);
  Future<void> setCartItem(String userId, CartItem cartItem);
  Future<void> removeCartItem(String userId, String cartItemId);
}