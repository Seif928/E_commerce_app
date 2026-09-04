import 'package:e_commerce_app/data/models/category_model.dart';
import 'package:flutter/material.dart';

class CategoryTabView extends StatelessWidget {
  const CategoryTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final category = dummyCategories[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: () {},
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Color(category.bgColorValue),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(category.textColorValue),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${category.productsCount} Products',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Color(category.textColorValue),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      itemCount: dummyCategories.length,
    );
  }
}
