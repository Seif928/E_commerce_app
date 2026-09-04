import 'package:e_commerce_app/data/datasources/api_paths.dart';
import 'package:e_commerce_app/data/datasources/firestore_services.dart';
import 'package:e_commerce_app/data/models/add_to_cart_model.dart';
import 'package:e_commerce_app/domain/entities/cart_item.dart';
import 'package:e_commerce_app/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final firestoreServices = FirestoreServices.instance;

  @override
  Future<List<CartItem>> fetchCartItems(String userId) async =>
      await firestoreServices.getCollection<AddToCartModel>(
        path: ApiPaths.cartItems(userId),
        builder: (data, documentId) => AddToCartModel.fromMap(data),
      );

  @override
  Future<void> setCartItem(String userId, CartItem cartItem) async {
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

  @override
  Future<void> removeCartItem(String userId, String cartItemId) async =>
      await firestoreServices.deleteData(
        path: ApiPaths.cartItem(userId, cartItemId),
      );
}