import 'package:e_commerce_app/data/datasources/api_paths.dart';
import 'package:e_commerce_app/data/datasources/firestore_services.dart';
import 'package:e_commerce_app/data/models/user_data.dart';
import 'package:e_commerce_app/domain/entities/app_user.dart';
import 'package:e_commerce_app/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final firebaseServices = FirestoreServices.instance;

  @override
  Future<AppUser> getUserData(String userId) async =>
      await firebaseServices.getDocument<AppUser>(
        path: ApiPaths.user(userId),
        builder: (data, documentId) => UserData.fromMap(data),
      );

  @override
  Future<void> changeUserEmail(String userId, String newEmail) async =>
      await firebaseServices.updateData(
        path: ApiPaths.user(userId),
        data: {'email': newEmail},
      );

  @override
  Future<void> changeUserName(String userId, String newName) async =>
      await firebaseServices.updateData(
        path: ApiPaths.user(userId),
        data: {'name': newName},
      );

  @override
  Future<void> changeUserPassword(String userId, String newPassword) async =>
      await firebaseServices.updateData(
        path: ApiPaths.user(userId),
        data: {'password': newPassword},
      );

  @override
  Future<void> deleteUser(String userId) async =>
      await firebaseServices.deleteData(path: ApiPaths.user(userId));
}