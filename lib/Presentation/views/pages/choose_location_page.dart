import 'package:e_commerce_app/Presentation/controller/choose_location_cubit/choose_location_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/location_item_widget.dart';
import 'package:e_commerce_app/Presentation/views/widgets/main_button.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
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
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<ChooseLocationCubit>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorder = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.isArabic ? 'عنوان التوصيل' : 'Delivery Address'),
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamedAndRemoveUntil(
                AppRoute.checkoutRoute,
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.isArabic ? 'اختر موقع التوصيل' : 'Choose your location',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                context.isArabic
                    ? 'أضف المدينة والدولة (مثال: Cairo-Egypt) أو اختر عنواناً محفوظاً.'
                    : 'Add a city and country (e.g. Cairo-Egypt) or pick a saved address.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: AppColors.grey1),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on_outlined),
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
                                current is LocationAddingFailure ||
                                current is ConfirmAddressLoaded ||
                                current is ConfirmAddressFailure,
                        listener: (context, state) {
                          if (state is LocationAdded) {
                            locationController.clear();
                          } else if (state is LocationAddingFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.trError(state.errorMessage))),
                            );
                          } else if (state is ConfirmAddressFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.trError(state.errorMessage))),
                            );
                          } else if (state is ConfirmAddressLoaded) {
                            Navigator.of(context).pop();
                          }
                        },
                        builder: (context, state) {
                          if (state is AddingLocation) {
                            return const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          return IconButton(
                            icon: const Icon(
                              Icons.add_circle_rounded,
                              color: AppColors.accentColor,
                            ),
                            onPressed: () {
                              if (locationController.text.trim().isNotEmpty) {
                                cubit.addLocation(locationController.text);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.trError('Enter City-Country first!'),
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                  hintText: context.isArabic ? 'القاهرة - مصر (Cairo-Egypt)' : 'Cairo-Egypt',
                ),
              ),
              const SizedBox(height: 26),
              Text(
                context.tr('addresses'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
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
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  } else if (state is FetchedLocations) {
                    final locations = state.locations;
                    if (locations.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          context.isArabic
                              ? 'لا توجد مواقع محفوظة حتى الآن. أضف عنواناً بالأعلى (مثل: Cairo-Egypt).'
                              : 'No saved locations yet. Add one above (e.g. Cairo-Egypt).',
                          style: const TextStyle(color: AppColors.grey1),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: locations.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final location = locations[index];
                        return BlocBuilder<
                          ChooseLocationCubit,
                          ChooseLocationState
                        >(
                          bloc: cubit,
                          buildWhen:
                              (previous, current) => current is LocationChosen,
                          builder: (context, chosenState) {
                            final chosenId =
                                chosenState is LocationChosen
                                    ? chosenState.location.id
                                    : cubit.selectedLocationId;
                            final isSelected = chosenId == location.id;
                            return LocationItemWidget(
                              onTap: () => cubit.selectLocation(location.id),
                              onDelete: () => cubit.deleteLocation(location.id),
                              location: location,
                              borderColor:
                                  isSelected
                                      ? AppColors.accentColor
                                      : defaultBorder,
                              isSelected: isSelected,
                            );
                          },
                        );
                      },
                    );
                  } else if (state is FetchLocationsFailure) {
                    return Center(child: Text(context.trError(state.errorMessage)));
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 28),
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
                    text: context.isArabic ? 'تأكيد العنوان' : 'Confirm Address',
                    onTap: () => cubit.confirmAddress(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
