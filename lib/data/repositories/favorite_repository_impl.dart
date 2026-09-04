import 'package:e_commerce_app/data/datasources/api_paths.dart';
import 'package:e_commerce_app/data/datasources/firestore_services.dart';
import 'package:e_commerce_app/data/models/product_item_model.dart';
import 'package:e_commerce_app/domain/entities/product.dart';
import 'package:e_commerce_app/domain/repositories/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final firestoreServices = FirestoreServices.instance;

  @override
  Future<void> addFavorite(String userId, Product product) async {
    await firestoreServices.setData(
      path: ApiPaths.favoriteProduct(userId, product.id),
      data: (product as ProductItemModel).toMap(),
    );
  }

  @override
  Future<List<Product>> getFavorites(String userId) async =>
      await firestoreServices.getCollection<ProductItemModel>(
        path: ApiPaths.favoriteProducts(userId),
        builder: (data, documentId) => ProductItemModel.fromMap(data),
      );

  @override
  Future<void> removeFavorite(String userId, String productId) async =>
      await firestoreServices.deleteData(
        path: ApiPaths.favoriteProduct(userId, productId),
      );
}