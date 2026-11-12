import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/domain/entities/category.dart';
import 'package:flutter/material.dart';

class CategoryModel extends Category {
  CategoryModel({
    required super.id,
    required super.name,
    required super.productsCount,
    Color bgColor = AppColors.primaryColor,
    Color textColor = AppColors.white1,
  }) : super(
          bgColorValue: bgColor.toARGB32(),
          textColorValue: textColor.toARGB32(),
        );

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'productsCount': productsCount});
    result.addAll({'bgColor': bgColorValue});
    result.addAll({'textColor': textColorValue});

    return result;
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      productsCount: map['productsCount']?.toInt() ?? 0,
      bgColor: Color(map['bgColor']),
      textColor: Color(map['textColor']),
    );
  }
}

List<CategoryModel> dummyCategories = [
  CategoryModel(
    id: 'all',
    name: 'All Products',
    productsCount: 8,
    bgColor: AppColors.primaryColor,
    textColor: AppColors.white1,
  ),
  CategoryModel(
    id: 'cat_1',
    name: 'Beauty',
    productsCount: 1,
    bgColor: AppColors.accentColor,
    textColor: AppColors.white1,
  ),
  CategoryModel(
    id: 'cat_2',
    name: 'Fragrances',
    productsCount: 1,
    bgColor: AppColors.teal,
    textColor: AppColors.white1,
  ),
  CategoryModel(
    id: 'cat_3',
    name: 'Mens Shoes',
    productsCount: 1,
    bgColor: const Color(0xFF2C3E50),
    textColor: AppColors.white1,
  ),
  CategoryModel(
    id: 'cat_4',
    name: 'Laptops',
    productsCount: 1,
    bgColor: AppColors.plum,
    textColor: AppColors.white1,
  ),
];