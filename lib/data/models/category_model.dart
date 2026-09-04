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
    id: '1',
    name: 'New Arrivals',
    productsCount: 208,
    bgColor: AppColors.grey1,
    textColor: AppColors.black,
  ),
  CategoryModel(
    id: '2',
    name: 'Clothes',
    productsCount: 358,
    bgColor: AppColors.green,
    textColor: AppColors.white1,
  ),
  CategoryModel(
    id: '3',
    name: 'Bags',
    productsCount: 160,
    bgColor: AppColors.black,
    textColor: AppColors.white1,
  ),
  CategoryModel(
    id: '4',
    name: 'Shoes',
    productsCount: 230,
    bgColor: AppColors.grey1,
    textColor: AppColors.black,
  ),
  CategoryModel(
    id: '5',
    name: 'Electronics',
    productsCount: 101,
    bgColor: AppColors.blue,
    textColor: AppColors.white1,
  ),
];