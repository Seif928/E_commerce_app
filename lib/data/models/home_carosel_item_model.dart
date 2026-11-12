import 'package:e_commerce_app/domain/entities/carousel_item.dart';

class HomeCarouselItemModel extends CarouselItem {
  const HomeCarouselItemModel({
    required super.id,
    required super.imgUrl,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'imgUrl': imgUrl});

    return result;
  }

  factory HomeCarouselItemModel.fromMap(Map<String, dynamic> map) {
    return HomeCarouselItemModel(
      id: map['id'] ?? '',
      imgUrl: map['imgUrl'] ?? '',
    );
  }
}

List<HomeCarouselItemModel> dummyHomeCarouselItems = [
  const HomeCarouselItemModel(
    id: '88',
    imgUrl:
        'https://cdn.dummyjson.com/product-images/mens-shoes/nike-air-jordan-1-red-and-black/1.webp',
  ),
  const HomeCarouselItemModel(
    id: '78',
    imgUrl:
        'https://cdn.dummyjson.com/product-images/laptops/apple-macbook-pro-14-inch-space-grey/1.webp',
  ),
  const HomeCarouselItemModel(
    id: '6',
    imgUrl:
        'https://cdn.dummyjson.com/product-images/fragrances/calvin-klein-ck-one/1.webp',
  ),
  const HomeCarouselItemModel(
    id: '93',
    imgUrl:
        'https://cdn.dummyjson.com/product-images/mens-watches/brown-leather-belt-watch/1.webp',
  ),
];