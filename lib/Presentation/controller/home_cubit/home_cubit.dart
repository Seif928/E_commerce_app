import 'package:e_commerce_app/data/repositories/auth_repository_impl.dart';
import 'package:e_commerce_app/data/repositories/favorite_repository_impl.dart';
import 'package:e_commerce_app/data/repositories/home_repository_impl.dart';
import 'package:e_commerce_app/domain/entities/carousel_item.dart';
import 'package:e_commerce_app/domain/entities/product.dart';
import 'package:e_commerce_app/domain/repositories/auth_repository.dart';
import 'package:e_commerce_app/domain/repositories/favorite_repository.dart';
import 'package:e_commerce_app/domain/repositories/home_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    HomeRepository? homeRepository,
    FavoriteRepository? favoriteRepository,
    AuthRepository? authRepository,
  }) : _homeRepository = homeRepository ?? HomeRepositoryImpl(),
       _favoriteRepository = favoriteRepository ?? FavoriteRepositoryImpl(),
       _authRepository = authRepository ?? AuthRepositoryImpl(),
       super(HomeInitial());

  final HomeRepository _homeRepository;
  final FavoriteRepository _favoriteRepository;
  final AuthRepository _authRepository;

  Future<void> getHomeData() async {
    emit(HomeLoading());
    try {
      final currentUserId = _authRepository.currentUserId;
      final products = await _homeRepository.fetchProducts();
      final carouselItems = await _homeRepository.fetchCarouselItems();
      final favoriteProducts = await _favoriteRepository.getFavorites(
        currentUserId!,
      );

      final List<Product> finalProducts = products.map((product) {
        final isFavorite = favoriteProducts.any(
          (item) => item.id == product.id,
        );
        return product.copyWith(isFavorite: isFavorite);
      }).toList();
      if (isClosed) return;
      emit(HomeLoaded(carouselItems: carouselItems, products: finalProducts));
    } catch (e) {
      if (isClosed) return;
      emit(HomeError(e.toString()));
    }
  }
}