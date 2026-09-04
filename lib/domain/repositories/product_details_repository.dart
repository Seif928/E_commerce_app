import 'package:e_commerce_app/domain/entities/cart_item.dart';
import 'package:e_commerce_app/domain/entities/product.dart';

abstract class ProductDetailsRepository {
  Future<Product> fetchProductDetails(String productId);
  Future<void> addToCart(CartItem cartItem, String userId);
}