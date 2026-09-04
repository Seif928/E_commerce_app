import 'package:e_commerce_app/data/datasources/api_paths.dart';
import 'package:e_commerce_app/data/datasources/firestore_services.dart';
import 'package:e_commerce_app/data/models/add_to_cart_model.dart';
import 'package:e_commerce_app/data/models/product_item_model.dart';
import 'package:e_commerce_app/domain/entities/cart_item.dart';
import 'package:e_commerce_app/domain/entities/product.dart';
import 'package:e_commerce_app/domain/repositories/product_details_repository.dart';

class ProductDetailsRepositoryImpl implements ProductDetailsRepository {
  final firestoreServices = FirestoreServices.instance;

  @override
  Future<Product> fetchProductDetails(String productId) async {
    final selectedProduct = await firestoreServices
        .getDocument<Product>(
          path: ApiPaths.product(productId),
          builder: (data, documentId) => ProductItemModel.fromMap(data),
        );
    return selectedProduct;
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