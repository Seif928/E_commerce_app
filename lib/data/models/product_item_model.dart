import 'package:e_commerce_app/domain/entities/product.dart';

class ProductItemModel extends Product {
  const ProductItemModel({
    required super.id,
    required super.name,
    required super.imgUrl,
    super.description,
    required super.price,
    super.isFavorite,
    required super.category,
    super.averageRate,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'imgUrl': imgUrl});
    result.addAll({'description': description});
    result.addAll({'price': price});
    result.addAll({'category': category});
    result.addAll({'averageRate': averageRate});

    return result;
  }

  factory ProductItemModel.fromMap(Map<String, dynamic> map) {
    return ProductItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imgUrl: map['imgUrl'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      averageRate: map['averageRate']?.toDouble() ?? 0.0,
    );
  }
}

List<ProductItemModel> dummyProducts = [
  const ProductItemModel(
    id: '1',
    name: 'Essence Mascara Lash Princess',
    imgUrl:
        'https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp',
    description:
        'Volumizing and lengthening mascara formula for a dramatic lash finish that lasts all day.',
    price: 9.99,
    category: 'Beauty',
    averageRate: 4.5,
  ),
  const ProductItemModel(
    id: '6',
    name: 'Calvin Klein CK One',
    imgUrl:
        'https://cdn.dummyjson.com/product-images/fragrances/calvin-klein-ck-one/thumbnail.webp',
    description:
        'Classic unisex eau de toilette with crisp citrus and warm amber notes for everyday wear.',
    price: 49.99,
    category: 'Fragrances',
    averageRate: 4.7,
  ),
  const ProductItemModel(
    id: '11',
    name: 'Annibale Colombo Bed',
    imgUrl:
        'https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-bed/thumbnail.webp',
    description:
        'Crafted solid-wood luxury bed frame combining timeless Italian tailoring with modern comfort.',
    price: 1899.99,
    category: 'Furniture',
    averageRate: 4.8,
  ),
  const ProductItemModel(
    id: '16',
    name: 'Fresh Red Apples',
    imgUrl: 'https://cdn.dummyjson.com/product-images/groceries/apple/thumbnail.webp',
    description:
        'Crisp hand-picked organic red apples packed fresh for daily snacking and healthy recipes.',
    price: 3.49,
    category: 'Groceries',
    averageRate: 4.6,
  ),
  const ProductItemModel(
    id: '78',
    name: 'Apple MacBook Pro 14"',
    imgUrl:
        'https://cdn.dummyjson.com/product-images/laptops/apple-macbook-pro-14-inch-space-grey/thumbnail.webp',
    description:
        'High-performance M-series laptop with Liquid Retina XDR display and all-day battery life.',
    price: 1999.99,
    category: 'Laptops',
    averageRate: 4.9,
  ),
  const ProductItemModel(
    id: '83',
    name: 'Blue & Black Check Shirt',
    imgUrl:
        'https://cdn.dummyjson.com/product-images/mens-shirts/blue-&-black-check-shirt/thumbnail.webp',
    description:
        'Soft brushed cotton button-down shirt tailored for effortless casual and smart-casual styling.',
    price: 29.99,
    category: 'Mens Shirts',
    averageRate: 4.4,
  ),
  const ProductItemModel(
    id: '88',
    name: 'Nike Air Jordan 1 Red & Black',
    imgUrl:
        'https://cdn.dummyjson.com/product-images/mens-shoes/nike-air-jordan-1-red-and-black/thumbnail.webp',
    description:
        'Iconic high-top leather sneaker featuring cushioned Air sole and heritage court traction.',
    price: 149.99,
    category: 'Mens Shoes',
    averageRate: 4.8,
  ),
  const ProductItemModel(
    id: '93',
    name: 'Brown Leather Belt Watch',
    imgUrl:
        'https://cdn.dummyjson.com/product-images/mens-watches/brown-leather-belt-watch/thumbnail.webp',
    description:
        'Minimalist analog chronograph paired with a stitched full-grain brown leather strap.',
    price: 89.99,
    category: 'Mens Watches',
    averageRate: 4.6,
  ),
];