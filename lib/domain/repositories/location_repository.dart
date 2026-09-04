import 'package:e_commerce_app/domain/entities/location.dart';

abstract class LocationRepository {
  Future<List<Location>> fetchLocations(
    String userId, {
    bool chosen = false,
  });
  Future<void> setLocation(Location location, String userId);
  Future<Location> fetchLocation(String userId, String locationId);
}