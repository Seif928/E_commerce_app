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
    final currentUserId = _authRepository.currentUserId;
    if (currentUserId == null) {
      emit(FavoriteLoaded(const []));
      return;
    }
    emit(FavoriteLoading());
    try {
      final favoriteProducts = await _favoriteRepository.getFavorites(
        currentUserId,
      );

      if (isClosed) return;
      emit(FavoriteLoaded(favoriteProducts));
    } catch (e) {
      if (isClosed) return;
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> removeFavorite(Product product) async {
    emit(FavoriteRemoving(product.id));
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(FavoriteRemoveError('User is not logged in'));
        return;
      }
      await _favoriteRepository.removeFavorite(currentUserId, product.id);

      final favoriteProducts = await _favoriteRepository.getFavorites(
        currentUserId,
      );
      if (isClosed) return;
      emit(FavoriteLoaded(favoriteProducts));
    } catch (e) {
      if (isClosed) return;
      emit(FavoriteRemoveError(e.toString()));
    }
  }

  Future<void> setFavorite(Product product) async {
    emit(SetFavoriteLoading(productId: product.id));
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(
          SetFavoriteLoadedError(
            error: 'User is not logged in',
            productId: product.id,
          ),
        );
        return;
      }
      final favoriteProducts = await _favoriteRepository.getFavorites(
        currentUserId,
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