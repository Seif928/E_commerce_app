import 'package:e_commerce_app/domain/entities/product.dart';

abstract class FavoriteRepository {
  Future<void> addFavorite(String userId, Product product);
  Future<void> removeFavorite(String userId, String productId);
  Future<List<Product>> getFavorites(String userId);
}