import 'package:e_commerce_app/data/datasources/api_paths.dart';
import 'package:e_commerce_app/data/datasources/external_catalog_service.dart';
import 'package:e_commerce_app/data/datasources/firestore_services.dart';
import 'package:e_commerce_app/data/models/add_to_cart_model.dart';
import 'package:e_commerce_app/data/models/product_item_model.dart';
import 'package:e_commerce_app/domain/entities/cart_item.dart';
import 'package:e_commerce_app/domain/entities/product.dart';
import 'package:e_commerce_app/domain/repositories/product_details_repository.dart';

class ProductDetailsRepositoryImpl implements ProductDetailsRepository {
  final firestoreServices = FirestoreServices.instance;
  final externalCatalog = ExternalCatalogService.instance;

  @override
  Future<Product> fetchProductDetails(String productId) async {
    final apiProduct = await externalCatalog.fetchProductById(productId);
    if (apiProduct != null) {
      return apiProduct;
    }
    try {
      final docSnapshot =
          await firestoreServices.firestore
              .doc(ApiPaths.product(productId))
              .get();
      final data = docSnapshot.data();
      if (docSnapshot.exists && data != null) {
        return ProductItemModel.fromMap(data);
      }
    } catch (_) {
      // Fall back to bundled catalog.
    }
    return dummyProducts.firstWhere(
      (product) => product.id == productId,
      orElse: () => throw Exception('Product not found'),
    );
  }

  @override
  Future<void> addToCart(CartItem cartItem, String userId) async {
    final cartItemModel = cartItem is AddToCartModel
        ? cartItem
        : AddToCartModel(
            id: cartItem.id,
            product: cartItem.product,
            size: cartItem.size,
            quantity: cartItem.quantity,
          );
    await firestoreServices.setData(
      path: ApiPaths.cartItem(userId, cartItem.id),
      data: cartItemModel.toMap(),
    );
  }
}
