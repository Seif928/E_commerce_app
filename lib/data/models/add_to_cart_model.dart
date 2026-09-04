import 'package:e_commerce_app/data/models/product_item_model.dart';
import 'package:e_commerce_app/domain/entities/cart_item.dart';
import 'package:e_commerce_app/domain/entities/product.dart';

class AddToCartModel extends CartItem {
  const AddToCartModel({
    required super.id,
    required super.product,
    required super.size,
    required super.quantity,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'product': (product as ProductItemModel).toMap()});
    result.addAll({'size': size.name});
    result.addAll({'quantity': quantity});

    return result;
  }

  factory AddToCartModel.fromMap(Map<String, dynamic> map) {
    return AddToCartModel(
      id: map['id'] as String? ?? '',
      product: ProductItemModel.fromMap(map['product']),
      size: ProductSize.fromString(map['size']),
      quantity: map['quantity'] as int? ?? 0,
    );
  }
}

List<AddToCartModel> dummyCart = [];