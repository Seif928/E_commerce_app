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
      if (isClosed) return;
      emit(ProductDetailsLoaded(product: selectedProduct));
    } catch (e) {
      if (isClosed) return;
      emit(ProductDetailsError(e.toString()));
    }
  }

  void selectSize(ProductSize size) {
    selectedSize = size;
    emit(SizeSelected(size: size));
  }

  Future<void> addToCart(String productId) async {
    if (selectedSize == null) {
      emit(ProductAddToCartError('Please select a size'));
      return;
    }
    final currentUserId = _authRepository.currentUserId;
    if (currentUserId == null) {
      emit(ProductAddToCartError('User is not logged in'));
      return;
    }
    emit(ProductAddingToCart());
    try {
      final selectedProduct = await _productDetailsRepository
          .fetchProductDetails(productId);
      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: selectedProduct,
        size: selectedSize!,
        quantity: quantity,
      );
      await _productDetailsRepository.addToCart(cartItem, currentUserId);
      if (isClosed) return;
      emit(ProductAddedToCart(productId: productId));
    } catch (e) {
      if (isClosed) return;
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
