import 'package:e_commerce_app/domain/entities/carousel_item.dart';
import 'package:e_commerce_app/domain/entities/category.dart';
import 'package:e_commerce_app/domain/entities/product.dart';

abstract class HomeRepository {
  Future<List<Product>> fetchProducts();
  Future<List<CarouselItem>> fetchCarouselItems();
  Future<List<Category>> fetchCategories();
}