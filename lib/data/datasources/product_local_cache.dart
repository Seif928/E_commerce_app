import 'dart:convert';
import 'package:e_commerce_app/data/models/category_model.dart';
import 'package:e_commerce_app/data/models/home_carosel_item_model.dart';
import 'package:e_commerce_app/data/models/product_item_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles persistent local caching of products, categories, and carousel items
/// using SharedPreferences, ensuring instant offline loading and fast app startup.
class ProductLocalCache {
  ProductLocalCache._();
  static final ProductLocalCache instance = ProductLocalCache._();

  static const String _productsKey = 'cached_catalog_products_v1';
  static const String _categoriesKey = 'cached_catalog_categories_v1';
  static const String _carouselKey = 'cached_catalog_carousel_v1';
  static const String _timestampKey = 'cached_catalog_timestamp_v1';
  static const Duration _cacheTtl = Duration(hours: 12);

  // In-memory L1 cache
  List<ProductItemModel>? _memoryProducts;
  List<CategoryModel>? _memoryCategories;
  List<HomeCarouselItemModel>? _memoryCarousel;

  /// Cache products list to SharedPreferences & memory
  Future<void> cacheProducts(List<ProductItemModel> products) async {
    if (products.isEmpty) return;
    try {
      _memoryProducts = List.unmodifiable(products);
      final prefs = await SharedPreferences.getInstance();
      final mapped = products.map((p) => p.toMap()).toList();
      await prefs.setString(_productsKey, jsonEncode(mapped));
      await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('[ProductLocalCache] Saved ${products.length} products to local storage.');
    } catch (e) {
      debugPrint('[ProductLocalCache] Failed to cache products: $e');
    }
  }

  /// Get cached products from memory or disk
  Future<List<ProductItemModel>?> getCachedProducts({bool ignoreExpiration = true}) async {
    if (_memoryProducts != null && _memoryProducts!.isNotEmpty) {
      return _memoryProducts;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_productsKey);
      if (raw == null || raw.isEmpty) return null;

      final timestamp = prefs.getInt(_timestampKey);
      if (!ignoreExpiration && timestamp != null) {
        final cachedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cachedDate) > _cacheTtl) {
          debugPrint('[ProductLocalCache] Products cache expired (older than 12h).');
        }
      }

      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final products = decoded
            .whereType<Map<String, dynamic>>()
            .map((item) => ProductItemModel.fromMap(item))
            .where((p) => p.id.isNotEmpty)
            .toList();
        if (products.isNotEmpty) {
          _memoryProducts = List.unmodifiable(products);
          debugPrint('[ProductLocalCache] Loaded ${products.length} products from disk cache.');
          return _memoryProducts;
        }
      }
    } catch (e) {
      debugPrint('[ProductLocalCache] Error reading cached products: $e');
    }
    return null;
  }

  /// Cache categories list
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    if (categories.isEmpty) return;
    try {
      _memoryCategories = List.unmodifiable(categories);
      final prefs = await SharedPreferences.getInstance();
      final mapped = categories.map((c) => c.toMap()).toList();
      await prefs.setString(_categoriesKey, jsonEncode(mapped));
    } catch (e) {
      debugPrint('[ProductLocalCache] Failed to cache categories: $e');
    }
  }

  /// Get cached categories
  Future<List<CategoryModel>?> getCachedCategories() async {
    if (_memoryCategories != null && _memoryCategories!.isNotEmpty) {
      return _memoryCategories;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_categoriesKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final categories = decoded
            .whereType<Map<String, dynamic>>()
            .map((item) => CategoryModel.fromMap(item))
            .where((c) => c.name.isNotEmpty)
            .toList();
        if (categories.isNotEmpty) {
          _memoryCategories = List.unmodifiable(categories);
          return _memoryCategories;
        }
      }
    } catch (e) {
      debugPrint('[ProductLocalCache] Error reading cached categories: $e');
    }
    return null;
  }

  /// Cache carousel items
  Future<void> cacheCarousel(List<HomeCarouselItemModel> carousel) async {
    if (carousel.isEmpty) return;
    try {
      _memoryCarousel = List.unmodifiable(carousel);
      final prefs = await SharedPreferences.getInstance();
      final mapped = carousel.map((item) => item.toMap()).toList();
      await prefs.setString(_carouselKey, jsonEncode(mapped));
    } catch (e) {
      debugPrint('[ProductLocalCache] Failed to cache carousel: $e');
    }
  }

  /// Get cached carousel items
  Future<List<HomeCarouselItemModel>?> getCachedCarousel() async {
    if (_memoryCarousel != null && _memoryCarousel!.isNotEmpty) {
      return _memoryCarousel;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_carouselKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final items = decoded
            .whereType<Map<String, dynamic>>()
            .map((item) => HomeCarouselItemModel.fromMap(item))
            .where((i) => i.id.isNotEmpty)
            .toList();
        if (items.isNotEmpty) {
          _memoryCarousel = List.unmodifiable(items);
          return _memoryCarousel;
        }
      }
    } catch (e) {
      debugPrint('[ProductLocalCache] Error reading cached carousel: $e');
    }
    return null;
  }

  /// Check if local products cache exists
  Future<bool> hasCachedProducts() async {
    if (_memoryProducts != null && _memoryProducts!.isNotEmpty) return true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_productsKey);
    return raw != null && raw.isNotEmpty;
  }

  /// Clear all cache (e.g. on logout or manual cache clear)
  Future<void> clearAll() async {
    _memoryProducts = null;
    _memoryCategories = null;
    _memoryCarousel = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productsKey);
    await prefs.remove(_categoriesKey);
    await prefs.remove(_carouselKey);
    await prefs.remove(_timestampKey);
  }
}

