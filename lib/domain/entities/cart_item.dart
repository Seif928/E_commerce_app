import 'package:e_commerce_app/domain/entities/product.dart';

class CartItem {
  final String id;
  final Product product;
  final ProductSize size;
  final int quantity;

  const CartItem({
    required this.id,
    required this.product,
    required this.size,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    ProductSize? size,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
    );
  }
}