import 'package:e_commerce_app/data/repositories/auth_repository_impl.dart';
import 'package:e_commerce_app/data/repositories/location_repository_impl.dart';
import 'package:e_commerce_app/domain/entities/location.dart';
import 'package:e_commerce_app/domain/repositories/auth_repository.dart';
import 'package:e_commerce_app/domain/repositories/location_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'choose_location_state.dart';

class ChooseLocationCubit extends Cubit<ChooseLocationState> {
  ChooseLocationCubit({
    LocationRepository? locationRepository,
    AuthRepository? authRepository,
  }) : _locationRepository = locationRepository ?? LocationRepositoryImpl(),
       _authRepository = authRepository ?? AuthRepositoryImpl(),
       super(ChooseLocationInitial());

  final LocationRepository _locationRepository;
  final AuthRepository _authRepository;

  String? selectedLocationId;
  Location? selectedLocation;

  Future<void> fetchLocations() async {
    emit(FetchingLocations());
    try {
      final currentUserId = _authRepository.currentUserId;
      final locations = await _locationRepository.fetchLocations(
        currentUserId!,
      );
      for (var location in locations) {
        if (location.isChosen) {
          selectedLocationId = location.id;
          selectedLocation = location;
        }
      }
      selectedLocationId ??= locations.first.id;
      selectedLocation ??= locations.first;
      emit(FetchedLocations(locations));
      emit(LocationChosen(selectedLocation!));
    } catch (e) {
      emit(FetchLocationsFailure(e.toString()));
    }
  }

  Future<void> addLocation(String location) async {
    emit(AddingLocation());
    try {
      final splittedLocations = location.split('-');
      final locationItem = Location(
        id: DateTime.now().toIso8601String(),
        city: splittedLocations[0],
        country: splittedLocations[1],
      );
      final currentUserId = _authRepository.currentUserId;
      await _locationRepository.setLocation(locationItem, currentUserId!);
      emit(LocationAdded());
      final locations = await _locationRepository.fetchLocations(currentUserId);
      emit(FetchedLocations(locations));
    } catch (e) {
      emit(LocationAddingFailure(e.toString()));
    }
  }

  Future<void> selectLocation(String id) async {
    selectedLocationId = id;
    final currentUserId = _authRepository.currentUserId;
    final chosenLocation = await _locationRepository.fetchLocation(
      currentUserId!,
      id,
    );
    selectedLocation = chosenLocation;
    emit(LocationChosen(chosenLocation));
  }

  Future<void> confirmAddress() async {
    emit(ConfirmAddressLoading());
    try {
      final currentUserId = _authRepository.currentUserId;
      var previousChosenLocations = await _locationRepository.fetchLocations(
        currentUserId!,
        chosen: true,
      );
      if (previousChosenLocations.isNotEmpty) {
        var previousLocation = previousChosenLocations.first;
        previousLocation = previousLocation.copyWith(isChosen: false);
        await _locationRepository.setLocation(previousLocation, currentUserId);
      }
      selectedLocation = selectedLocation!.copyWith(isChosen: true);
      await _locationRepository.setLocation(selectedLocation!, currentUserId);
      emit(ConfirmAddressLoaded());
    } catch (e) {
      emit(ConfirmAddressFailure(e.toString()));
    }
  }
}