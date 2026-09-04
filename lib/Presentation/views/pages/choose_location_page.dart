import 'package:e_commerce_app/Presentation/controller/choose_location_cubit/choose_location_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/location_item_widget.dart';
import 'package:e_commerce_app/Presentation/views/widgets/main_button.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseLocationPage extends StatefulWidget {
  const ChooseLocationPage({super.key});

  @override
  State<ChooseLocationPage> createState() => _ChooseLocationPageState();
}

class _ChooseLocationPageState extends State<ChooseLocationPage> {
  final TextEditingController locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<ChooseLocationCubit>(context);

    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Address')),
        leading: IconButton(
          onPressed: () {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamedAndRemoveUntil(AppRoute.checkoutRoute, (route) => false);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your location',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Let\'s find an unforgettable event. Choose a location below to get started:',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(color: AppColors.grey1),
                ),
                const SizedBox(height: 36),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon:
                        BlocConsumer<ChooseLocationCubit, ChooseLocationState>(
                          bloc: cubit,
                          buildWhen:
                              (previous, current) =>
                                  current is AddingLocation ||
                                  current is LocationAdded ||
                                  current is LocationAddingFailure,
                          listenWhen:
                              (previous, current) =>
                                  current is LocationAdded ||
                                  current is ConfirmAddressLoaded,
                          listener: (context, state) {
                            if (state is LocationAdded) {
                              locationController.clear();
                            } else if (state is ConfirmAddressLoaded) {
                              Navigator.of(context).pop();
                            }
                          },
                          builder: (context, state) {
                            if (state is AddingLocation) {
                              return const Center(
                                child: CircularProgressIndicator.adaptive(
                                  backgroundColor: AppColors.grey1,
                                ),
                              );
                            }
                            return IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                if (locationController.text.isNotEmpty) {
                                  cubit.addLocation(locationController.text);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Enter your location!'),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                    suffixIconColor: AppColors.grey1,
                    prefixIconColor: AppColors.grey1,
                    hintText: 'Write location: city-country',
                    fillColor: AppColors.grey2,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  'Select Location',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                BlocBuilder<ChooseLocationCubit, ChooseLocationState>(
                  bloc: cubit,
                  buildWhen:
                      (previous, current) =>
                          current is FetchLocationsFailure ||
                          current is FetchedLocations ||
                          current is FetchingLocations,
                  builder: (context, state) {
                    if (state is FetchingLocations) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else if (state is FetchedLocations) {
                      final locations = state.locations;

                      return ListView.builder(
                        itemCount: locations.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final location = locations[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: BlocBuilder<
                              ChooseLocationCubit,
                              ChooseLocationState
                            >(
                              bloc: cubit,
                              buildWhen:
                                  (previous, current) =>
                                      current is LocationChosen,
                              builder: (context, state) {
                                if (state is LocationChosen) {
                                  final chosenLocation = state.location;
                                  return LocationItemWidget(
                                    onTap: () {
                                      cubit.selectLocation(location.id);
                                    },
                                    location: location,
                                    borderColor:
                                        chosenLocation.id == location.id
                                            ? AppColors.primaryColor
                                            : AppColors.grey1,
                                  );
                                }
                                return LocationItemWidget(
                                  onTap: () {
                                    cubit.selectLocation(location.id);
                                  },
                                  location: location,
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else if (state is FetchLocationsFailure) {
                      return Center(child: Text(state.errorMessage));
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<ChooseLocationCubit, ChooseLocationState>(
                  bloc: cubit,
                  buildWhen:
                      (previous, current) =>
                          current is ConfirmAddressLoading ||
                          current is ConfirmAddressLoaded ||
                          current is ConfirmAddressFailure,
                  builder: (context, state) {
                    if (state is ConfirmAddressLoading) {
                      return MainButton(isLoading: true);
                    }
                    return MainButton(
                      text: 'Confirm Address',
                      onTap: () {
                        cubit.confirmAddress();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
