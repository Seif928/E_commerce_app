class Category {
  final String id;
  final String name;
  final int productsCount;
  final int bgColorValue;
  final int textColorValue;

  const Category({
    required this.id,
    required this.name,
    required this.productsCount,
    this.bgColorValue = 0xFF673AB7,
    this.textColorValue = 0xFFFFFFFF,
  });
}