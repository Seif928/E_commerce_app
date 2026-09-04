import 'package:e_commerce_app/data/repositories/auth_repository_impl.dart';
import 'package:e_commerce_app/data/repositories/product_details_repository_impl.dart';
import 'package:e_commerce_app/domain/entities/cart_item.dart';
import 'package:e_commerce_app/domain/entities/product.dart';
import 'package:e_commerce_app/domain/repositories/auth_repository.dart';
import 'package:e_commerce_app/domain/repositories/product_details_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit({
    ProductDetailsRepository? productDetailsRepository,
    AuthRepository? authRepository,
  }) : _productDetailsRepository =
           productDetailsRepository ?? ProductDetailsRepositoryImpl(),
       _authRepository = authRepository ?? AuthRepositoryImpl(),
       super(ProductDetailsInitial());

  final ProductDetailsRepository _productDetailsRepository;
  final AuthRepository _authRepository;

  ProductSize? selectedSize;
  int quantity = 1;

  Future<void> getProductDetails(String id) async {
    emit(ProductDetailsLoading());
    try {
      final selectedProduct = await _productDetailsRepository
          .fetchProductDetails(id);
      emit(ProductDetailsLoaded(product: selectedProduct));
    } catch (e) {
      emit(ProductDetailsError(e.toString()));
    }
  }

  void selectSize(ProductSize size) {
    selectedSize = size;
    emit(SizeSelected(size: size));
  }

  Future<void> addToCart(String productId) async {
    emit(ProductAddingToCart());
    try {
      final selectedProduct = await _productDetailsRepository
          .fetchProductDetails(productId);
      final currentUserId = _authRepository.currentUserId;

      final cartItem = CartItem(
        id: DateTime.now().toIso8601String(),
        product: selectedProduct,
        size: selectedSize!,
        quantity: quantity,
      );
      await _productDetailsRepository.addToCart(cartItem, currentUserId!);
      emit(ProductAddedToCart(productId: productId));
    } catch (e) {
      emit(ProductAddToCartError(e.toString()));
    }
  }

  void incrementCounter(String productId) {
    quantity++;
    emit(QuantityCounterLoaded(value: quantity));
  }

  void decrementCounter(String productId) {
    if (quantity <= 1) return;
    quantity--;
    emit(QuantityCounterLoaded(value: quantity));
  }
}