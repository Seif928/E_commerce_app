part of 'favorite_cubit.dart';

sealed class FavoriteState {
  const FavoriteState();
}

final class FavoriteInitial extends FavoriteState {}

final class FavoriteLoading extends FavoriteState {}

final class FavoriteLoaded extends FavoriteState {
  final List<Product> favoriteProducts;

  FavoriteLoaded(this.favoriteProducts);
}

final class FavoriteError extends FavoriteState {
  final String error;

  FavoriteError(this.error);
}

final class FavoriteRemoved extends FavoriteState {
  final String productId;
  final bool isFav;
  FavoriteRemoved({required this.productId, required this.isFav});
}

final class FavoriteRemoving extends FavoriteState {
  final String productId;

  FavoriteRemoving(this.productId);
}

final class FavoriteRemoveError extends FavoriteState {
  final String error;

  FavoriteRemoveError(this.error);
}

final class SetFavoriteLoading extends FavoriteState {
  final String productId;
  const SetFavoriteLoading({required this.productId});
}

final class SetFavoriteLoaded extends FavoriteState {
  final String productId;
  final bool isFav;
  const SetFavoriteLoaded({required this.productId, required this.isFav});
}

final class SetFavoriteLoadedError extends FavoriteState {
  final String productId;
  final String error;
  const SetFavoriteLoadedError({required this.productId, required this.error});
}
