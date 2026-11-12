import 'package:e_commerce_app/data/datasources/api_paths.dart';
import 'package:e_commerce_app/data/datasources/external_catalog_service.dart';
import 'package:e_commerce_app/data/datasources/firestore_services.dart';
import 'package:e_commerce_app/data/datasources/product_local_cache.dart';
import 'package:e_commerce_app/data/models/category_model.dart';
import 'package:e_commerce_app/data/models/home_carosel_item_model.dart';
import 'package:e_commerce_app/data/models/product_item_model.dart';
import 'package:e_commerce_app/domain/entities/carousel_item.dart';
import 'package:e_commerce_app/domain/entities/category.dart';
import 'package:e_commerce_app/domain/entities/product.dart';
import 'package:e_commerce_app/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final firestoreServices = FirestoreServices.instance;
  final externalCatalog = ExternalCatalogService.instance;
  final localCache = ProductLocalCache.instance;

  Future<List<ProductItemModel>> _loadProductsFromApiThenFallback() async {
    try {
      final apiProducts = await externalCatalog.fetchProducts();
      if (apiProducts.isNotEmpty) return apiProducts;
    } catch (_) {
      // Fall back to persistent local cache when network fails
    }

    try {
      final cached = await localCache.getCachedProducts(ignoreExpiration: true);
      if (cached != null && cached.isNotEmpty) return cached;
    } catch (_) {}

    try {
      final firestoreResult =
          await firestoreServices.getCollection<ProductItemModel>(
        path: ApiPaths.products(),
        builder: (data, documentId) => ProductItemModel.fromMap(data),
      );
      if (firestoreResult.isNotEmpty) return firestoreResult;
    } catch (_) {
      // Ignore Firestore failure and use bundled catalog.
    }
    return dummyProducts;
  }

  @override
  Future<List<Product>> fetchProducts() async =>
      _loadProductsFromApiThenFallback();

  @override
  Future<List<CarouselItem>> fetchCarouselItems() async {
    try {
      final apiProducts = await externalCatalog.fetchProducts();
      if (apiProducts.isNotEmpty) {
        return externalCatalog.buildCarouselFromProducts(apiProducts);
      }
    } catch (_) {}

    try {
      final cached = await localCache.getCachedCarousel();
      if (cached != null && cached.isNotEmpty) return cached;
    } catch (_) {}

    try {
      final result =
          await firestoreServices.getCollection<HomeCarouselItemModel>(
        path: ApiPaths.announcements(),
        builder: (data, documentId) => HomeCarouselItemModel.fromMap(data),
      );
      if (result.isNotEmpty) return result;
    } catch (_) {}
    return dummyHomeCarouselItems;
  }

  @override
  Future<List<Category>> fetchCategories() async {
    try {
      final apiProducts = await externalCatalog.fetchProducts();
      if (apiProducts.isNotEmpty) {
        return externalCatalog.buildCategoriesFromProducts(apiProducts);
      }
    } catch (_) {}

    try {
      final cached = await localCache.getCachedCategories();
      if (cached != null && cached.isNotEmpty) return cached;
    } catch (_) {}

    try {
      final result = await firestoreServices.getCollection<CategoryModel>(
        path: ApiPaths.categories(),
        builder: (data, documentId) => CategoryModel.fromMap(data),
      );
      if (result.isNotEmpty) return result;
    } catch (_) {}
    return dummyCategories;
  }
}
