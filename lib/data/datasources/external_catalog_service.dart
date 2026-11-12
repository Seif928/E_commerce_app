import 'dart:convert';
import 'dart:io';

import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/data/datasources/product_local_cache.dart';
import 'package:e_commerce_app/data/models/category_model.dart';
import 'package:e_commerce_app/data/models/home_carosel_item_model.dart';
import 'package:e_commerce_app/data/models/product_item_model.dart';
import 'package:flutter/material.dart';

/// Fetches live catalog products, product details, and search results from DummyJSON API.
class ExternalCatalogService {
  ExternalCatalogService._();
  static final ExternalCatalogService instance = ExternalCatalogService._();

  static const String _baseUrl = 'https://dummyjson.com';
  static const Duration _timeout = Duration(seconds: 8);

  List<ProductItemModel>? _cachedProducts;
  DateTime? _cacheTimestamp;

  static const List<Color> _categoryPalette = [
    AppColors.primaryColor,
    AppColors.accentColor,
    AppColors.teal,
    Color(0xFF2C3E50),
    Color(0xFF5B4B8A),
    Color(0xFFB45309),
  ];

  Future<Map<String, dynamic>> _getJson(String url) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await client.getUrl(Uri.parse(url)).timeout(_timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close().timeout(_timeout);
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(url));
      }
      final body = await response.transform(utf8.decoder).join().timeout(_timeout);
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw const FormatException('Unexpected JSON payload');
    } finally {
      client.close(force: true);
    }
  }

  String _formatCategory(String raw) {
    return raw
        .split(RegExp(r'[-_\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  ProductItemModel _mapProduct(Map<String, dynamic> item) {
    final images = item['images'];
    final firstImage = images is List && images.isNotEmpty ? images.first?.toString() : null;
    final thumbnail = item['thumbnail']?.toString();
    final imgUrl =
        (thumbnail != null && thumbnail.startsWith('http'))
            ? thumbnail
            : (firstImage != null && firstImage.startsWith('http'))
            ? firstImage
            : '';

    final rawCategory = item['category']?.toString() ?? 'General';
    final rawPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
    final rawRating = (item['rating'] as num?)?.toDouble() ?? 4.5;

    return ProductItemModel(
      id: (item['id'] ?? '').toString(),
      name: (item['title'] ?? 'Product').toString(),
      imgUrl: imgUrl,
      description: (item['description'] ?? '').toString(),
      price: rawPrice,
      category: _formatCategory(rawCategory),
      averageRate: double.parse(rawRating.clamp(0.0, 5.0).toStringAsFixed(1)),
    );
  }

  Future<List<ProductItemModel>> fetchProducts({bool forceRefresh = false}) async {
    final now = DateTime.now();

    // 1. Fast in-memory check
    if (!forceRefresh &&
        _cachedProducts != null &&
        _cachedProducts!.isNotEmpty &&
        _cacheTimestamp != null &&
        now.difference(_cacheTimestamp!) < const Duration(minutes: 10)) {
      return _cachedProducts!;
    }

    // 2. Check local disk cache if memory is empty
    if (!forceRefresh && (_cachedProducts == null || _cachedProducts!.isEmpty)) {
      final diskCached = await ProductLocalCache.instance.getCachedProducts();
      if (diskCached != null && diskCached.isNotEmpty) {
        _cachedProducts = diskCached;
        _cacheTimestamp = now;
        return diskCached;
      }
    }

    // 3. Fetch from remote live API
    try {
      final json = await _getJson('$_baseUrl/products?limit=60');
      final rawList = json['products'];
      if (rawList is! List || rawList.isEmpty) {
        throw const FormatException('No products returned from API');
      }

      final mapped =
          rawList
              .whereType<Map<String, dynamic>>()
              .map(_mapProduct)
              .where((p) => p.id.isNotEmpty && p.imgUrl.isNotEmpty)
              .toList();

      if (mapped.isNotEmpty) {
        _cachedProducts = mapped;
        _cacheTimestamp = now;

        // Persist to local disk cache (survives offline & app restart)
        await ProductLocalCache.instance.cacheProducts(mapped);
        await ProductLocalCache.instance.cacheCategories(
          buildCategoriesFromProducts(mapped),
        );
        await ProductLocalCache.instance.cacheCarousel(
          buildCarouselFromProducts(mapped),
        );

        return mapped;
      }
    } catch (e) {
      // 4. On network error / timeout, retrieve persistent cache regardless of expiration
      final diskFallback = await ProductLocalCache.instance.getCachedProducts(
        ignoreExpiration: true,
      );
      if (diskFallback != null && diskFallback.isNotEmpty) {
        _cachedProducts = diskFallback;
        return diskFallback;
      }
      rethrow;
    }

    return _cachedProducts ?? [];
  }

  Future<ProductItemModel?> fetchProductById(String productId) async {
    // 1. Check in-memory cache
    final memCached = _cachedProducts?.where((p) => p.id == productId).toList();
    if (memCached != null && memCached.isNotEmpty) {
      return memCached.first;
    }

    // 2. Check persistent disk cache
    final diskCached = await ProductLocalCache.instance.getCachedProducts();
    final matching = diskCached?.where((p) => p.id == productId).toList();
    if (matching != null && matching.isNotEmpty) {
      return matching.first;
    }

    // 3. Fetch from remote API
    try {
      final json = await _getJson('$_baseUrl/products/$productId');
      if (json['id'] != null) {
        return _mapProduct(json);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<List<ProductItemModel>> searchProducts(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return fetchProducts();
    }
    try {
      final encoded = Uri.encodeQueryComponent(trimmed);
      final json = await _getJson('$_baseUrl/products/search?q=$encoded&limit=25');
      final rawList = json['products'];
      if (rawList is List) {
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(_mapProduct)
            .where((p) => p.id.isNotEmpty && p.imgUrl.isNotEmpty)
            .toList();
      }
    } catch (_) {
      final products = _cachedProducts ?? dummyProducts;
      final lower = trimmed.toLowerCase();
      return products
          .where(
            (p) =>
                p.name.toLowerCase().contains(lower) ||
                p.category.toLowerCase().contains(lower),
          )
          .toList();
    }
    return const [];
  }

  List<CategoryModel> buildCategoriesFromProducts(List<ProductItemModel> products) {
    final Map<String, int> counts = {};
    for (final p in products) {
      counts[p.category] = (counts[p.category] ?? 0) + 1;
    }
    final categories = <CategoryModel>[
      CategoryModel(
        id: 'all',
        name: 'All Products',
        productsCount: products.length,
        bgColor: AppColors.primaryColor,
        textColor: AppColors.white1,
      ),
    ];
    int colorIndex = 1;
    for (final entry in counts.entries) {
      final bg = _categoryPalette[colorIndex % _categoryPalette.length];
      categories.add(
        CategoryModel(
          id: 'cat_$colorIndex',
          name: entry.key,
          productsCount: entry.value,
          bgColor: bg,
          textColor: AppColors.white1,
        ),
      );
      colorIndex++;
    }
    return categories;
  }

  List<HomeCarouselItemModel> buildCarouselFromProducts(
    List<ProductItemModel> products,
  ) {
    final picks = products.take(4).toList();
    if (picks.isEmpty) return dummyHomeCarouselItems;
    return picks
        .map(
          (p) => HomeCarouselItemModel(
            id: p.id,
            imgUrl: p.imgUrl,
          ),
        )
        .toList();
  }
}

