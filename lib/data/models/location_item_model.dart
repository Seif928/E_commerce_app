import 'package:e_commerce_app/domain/entities/location.dart';

class LocationItemModel extends Location {
  const LocationItemModel({
    required super.id,
    required super.city,
    required super.country,
    super.isChosen,
    super.imgUrl,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'city': city});
    result.addAll({'country': country});
    result.addAll({'imgUrl': imgUrl});
    result.addAll({'isChosen': isChosen});

    return result;
  }

  factory LocationItemModel.fromMap(Map<String, dynamic> map) {
    return LocationItemModel(
      id: map['id'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      imgUrl: map['imgUrl'] ?? '',
      isChosen: map['isChosen'] ?? false,
    );
  }
}

List<LocationItemModel> dummyLocations = [
  LocationItemModel(
    id: '1',
    city: 'Cairo',
    country: 'Egypt',
  ),
  LocationItemModel(
    id: '2',
    city: 'Giza',
    country: 'Egypt',
  ),
  LocationItemModel(
    id: '3',
    city: 'Alexandria',
    country: 'Egypt',
  ),
];