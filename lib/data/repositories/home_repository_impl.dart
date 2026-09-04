import 'package:e_commerce_app/data/datasources/api_paths.dart';
import 'package:e_commerce_app/data/datasources/firestore_services.dart';
import 'package:e_commerce_app/data/models/category_model.dart';
import 'package:e_commerce_app/data/models/home_carosel_item_model.dart';
import 'package:e_commerce_app/data/models/product_item_model.dart';
import 'package:e_commerce_app/domain/entities/carousel_item.dart';
import 'package:e_commerce_app/domain/entities/category.dart';
import 'package:e_commerce_app/domain/entities/product.dart';
import 'package:e_commerce_app/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final firestoreServices = FirestoreServices.instance;

  @override
  Future<List<Product>> fetchProducts() async {
    final result = await firestoreServices.getCollection<ProductItemModel>(
      path: ApiPaths.products(),
      builder: (data, documentId) => ProductItemModel.fromMap(data),
    );
    return result;
  }

  @override
  Future<List<CarouselItem>> fetchCarouselItems() async {
    final result =
        await firestoreServices.getCollection<HomeCarouselItemModel>(
          path: ApiPaths.announcements(),
          builder: (data, documentId) => HomeCarouselItemModel.fromMap(data),
        );
    return result;
  }

  @override
  Future<List<Category>> fetchCategories() async {
    final result = await firestoreServices.getCollection<CategoryModel>(
      path: ApiPaths.categories(),
      builder: (data, documentId) => CategoryModel.fromMap(data),
    );
    return result;
  }
}