import 'package:e_commerce_app/data/repositories/auth_repository_impl.dart';
import 'package:e_commerce_app/data/repositories/favorite_repository_impl.dart';
import 'package:e_commerce_app/domain/entities/product.dart';
import 'package:e_commerce_app/domain/repositories/auth_repository.dart';
import 'package:e_commerce_app/domain/repositories/favorite_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit({
    FavoriteRepository? favoriteRepository,
    AuthRepository? authRepository,
  }) : _favoriteRepository = favoriteRepository ?? FavoriteRepositoryImpl(),
       _authRepository = authRepository ?? AuthRepositoryImpl(),
       super(FavoriteInitial());

  final FavoriteRepository _favoriteRepository;
  final AuthRepository _authRepository;

  Future<void> getFavoriteProducts() async {
    emit(FavoriteLoading());
    try {
      final currentUserId = _authRepository.currentUserId!;
      final favoriteProducts = await _favoriteRepository.getFavorites(
        currentUserId,
      );

      emit(FavoriteLoaded(favoriteProducts));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> removeFavorite(Product product) async {
    emit(FavoriteRemoving(product.id));
    try {
      final currentUserId = _authRepository.currentUserId!;
      await _favoriteRepository.removeFavorite(currentUserId, product.id);

      final favoriteProducts = await _favoriteRepository.getFavorites(
        currentUserId,
      );
      emit(FavoriteLoaded(favoriteProducts));
    } catch (e) {
      emit(FavoriteRemoveError(e.toString()));
    }
  }

  Future<void> setFavorite(Product product) async {
    emit(SetFavoriteLoading(productId: product.id));
    try {
      final currentUserId = _authRepository.currentUserId;
      final favoriteProducts = await _favoriteRepository.getFavorites(
        currentUserId!,
      );
      final isFavorite = favoriteProducts.any((item) => item.id == product.id);
      if (isFavorite) {
        await _favoriteRepository.removeFavorite(currentUserId, product.id);
      } else {
        await _favoriteRepository.addFavorite(currentUserId, product);
      }
      final updatedFavorites = await _favoriteRepository.getFavorites(
        currentUserId,
      );
      if (isClosed) return;
      emit(FavoriteLoaded(updatedFavorites));
    } catch (e) {
      if (isClosed) return;
      emit(SetFavoriteLoadedError(error: e.toString(), productId: product.id));
    }
  }
}