import 'package:e_commerce_app/data/datasources/api_paths.dart';
import 'package:e_commerce_app/data/datasources/firestore_services.dart';
import 'package:e_commerce_app/data/models/location_item_model.dart';
import 'package:e_commerce_app/domain/entities/location.dart';
import 'package:e_commerce_app/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final firestoreServices = FirestoreServices.instance;

  @override
  Future<void> setLocation(Location location, String userId) async {
    final locationModel = location is LocationItemModel
        ? location
        : LocationItemModel(
            id: location.id,
            city: location.city,
            country: location.country,
            imgUrl: location.imgUrl,
            isChosen: location.isChosen,
          );
    await firestoreServices.setData(
      path: ApiPaths.location(userId, location.id),
      data: locationModel.toMap(),
    );
  }

  @override
  Future<List<Location>> fetchLocations(
    String userId, {
    bool chosen = false,
  }) async => await firestoreServices.getCollection<LocationItemModel>(
    path: ApiPaths.locations(userId),
    builder: (data, documentId) => LocationItemModel.fromMap(data),
    queryBuilder:
        chosen ? (query) => query.where('isChosen', isEqualTo: true) : null,
  );

  @override
  Future<Location> fetchLocation(String userId, String locationId) async =>
      await firestoreServices.getDocument<Location>(
        path: ApiPaths.location(userId, locationId),
        builder: (data, documentId) => LocationItemModel.fromMap(data),
      );
}