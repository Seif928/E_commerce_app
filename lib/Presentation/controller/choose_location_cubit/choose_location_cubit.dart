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
      if (currentUserId == null) {
        emit(FetchLocationsFailure('User is not logged in'));
        return;
      }
      final locations = await _locationRepository.fetchLocations(currentUserId);
      selectedLocationId = null;
      selectedLocation = null;
      for (final location in locations) {
        if (location.isChosen) {
          selectedLocationId = location.id;
          selectedLocation = location;
        }
      }
      if (locations.isNotEmpty) {
        selectedLocationId ??= locations.first.id;
        selectedLocation ??= locations.first;
      }
      if (isClosed) return;
      emit(FetchedLocations(locations));
      if (selectedLocation != null) {
        emit(LocationChosen(selectedLocation!));
      }
    } catch (e) {
      if (isClosed) return;
      emit(FetchLocationsFailure(e.toString()));
    }
  }

  Future<void> addLocation(String location) async {
    emit(AddingLocation());
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(LocationAddingFailure('User is not logged in'));
        return;
      }
      final separator = location.contains('-') ? '-' : ',';
      final splittedLocations = location.split(separator);
      if (splittedLocations.length < 2 ||
          splittedLocations[0].trim().isEmpty ||
          splittedLocations[1].trim().isEmpty) {
        emit(
          LocationAddingFailure(
            'Please enter location in format: City-Country',
          ),
        );
        return;
      }
      final existing = await _locationRepository.fetchLocations(currentUserId);
      final locationItem = Location(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        city: splittedLocations[0].trim(),
        country: splittedLocations[1].trim(),
        isChosen: existing.isEmpty,
      );
      await _locationRepository.setLocation(locationItem, currentUserId);
      if (isClosed) return;
      emit(LocationAdded());
      final locations = await _locationRepository.fetchLocations(currentUserId);
      selectedLocationId ??= locationItem.id;
      selectedLocation ??= locationItem;
      if (isClosed) return;
      emit(FetchedLocations(locations));
      emit(LocationChosen(selectedLocation!));
    } catch (e) {
      if (isClosed) return;
      emit(LocationAddingFailure(e.toString()));
    }
  }

  Future<void> selectLocation(String id) async {
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(ConfirmAddressFailure('User is not logged in'));
        return;
      }
      selectedLocationId = id;
      final chosenLocation = await _locationRepository.fetchLocation(
        currentUserId,
        id,
      );
      selectedLocation = chosenLocation;
      if (isClosed) return;
      emit(LocationChosen(chosenLocation));
    } catch (e) {
      if (isClosed) return;
      emit(ConfirmAddressFailure(e.toString()));
    }
  }

  Future<void> deleteLocation(String id) async {
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(FetchLocationsFailure('User is not logged in'));
        return;
      }
      await _locationRepository.deleteLocation(currentUserId, id);
      await fetchLocations();
    } catch (e) {
      if (isClosed) return;
      emit(FetchLocationsFailure(e.toString()));
    }
  }

  Future<void> confirmAddress() async {
    if (selectedLocation == null) {
      emit(ConfirmAddressFailure('Please add or select a location first'));
      return;
    }
    emit(ConfirmAddressLoading());
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(ConfirmAddressFailure('User is not logged in'));
        return;
      }
      final previousChosenLocations = await _locationRepository.fetchLocations(
        currentUserId,
        chosen: true,
      );
      for (final previousLocation in previousChosenLocations) {
        if (previousLocation.id != selectedLocation!.id) {
          await _locationRepository.setLocation(
            previousLocation.copyWith(isChosen: false),
            currentUserId,
          );
        }
      }
      selectedLocation = selectedLocation!.copyWith(isChosen: true);
      await _locationRepository.setLocation(selectedLocation!, currentUserId);
      if (isClosed) return;
      emit(ConfirmAddressLoaded());
    } catch (e) {
      if (isClosed) return;
      emit(ConfirmAddressFailure(e.toString()));
    }
  }
}
