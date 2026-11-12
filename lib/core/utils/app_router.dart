import 'package:e_commerce_app/Presentation/controller/add_new_card_cubit/payment_methods_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/auth_cubit/auth_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/checkout_cubit/checkout_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/choose_location_cubit/choose_location_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/product_details_cubit/product_details_cubit.dart';
import 'package:e_commerce_app/Presentation/views/pages/add_new_card_page.dart';
import 'package:e_commerce_app/Presentation/views/pages/cart_page.dart';
import 'package:e_commerce_app/Presentation/views/pages/checkout_page.dart'
    show CheckoutPage;
import 'package:e_commerce_app/Presentation/views/pages/choose_location_page.dart';
import 'package:e_commerce_app/Presentation/views/pages/custom_bottom_navbar.dart';
import 'package:e_commerce_app/Presentation/views/pages/edit_profile.dart';
import 'package:e_commerce_app/Presentation/views/pages/login_page.dart';
import 'package:e_commerce_app/Presentation/views/pages/payment_methods_page.dart';
import 'package:e_commerce_app/Presentation/views/pages/product_details_page.dart';
import 'package:e_commerce_app/Presentation/views/pages/profile_page.dart';
import 'package:e_commerce_app/Presentation/views/pages/register_page.dart';
import 'package:e_commerce_app/Presentation/views/pages/settings_page.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoute.homeRoute:
        return MaterialPageRoute(
          builder: (_) => const CustomBottomNavbar(),
          settings: settings,
        );

      case AppRoute.loginRoute:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) => AuthCubit(),
                child: const LoginPage(),
              ),
          settings: settings,
        );

      case AppRoute.registerRoute:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) => AuthCubit(),
                child: const RegisterPage(),
              ),
          settings: settings,
        );

      case AppRoute.checkoutRoute:
        return MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) {
                      final cubit = CheckoutCubit();
                      cubit.getCheckoutContent();
                      return cubit;
                    },
                  ),
                  BlocProvider(create: (context) => PaymentMethodsCubit()),
                ],
                child: const CheckoutPage(),
              ),
          settings: settings,
        );
      case AppRoute.chooseLocation:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) {
                  final cubit = ChooseLocationCubit();
                  cubit.fetchLocations();
                  return cubit;
                },
                child: const ChooseLocationPage(),
              ),
          settings: settings,
        );
      case AppRoute.paymentMethodsRoute:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) => PaymentMethodsCubit()..fetchPaymentMethods(),
                child: const PaymentMethodsPage(),
              ),
          settings: settings,
        );
      case AppRoute.addNewCardRoute:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder:
              (_) =>
                  args is PaymentMethodsCubit
                      ? BlocProvider.value(
                        value: args,
                        child: const AddNewCardPage(),
                      )
                      : BlocProvider(
                        create: (context) => PaymentMethodsCubit(),
                        child: const AddNewCardPage(),
                      ),
          settings: settings,
        );
      case AppRoute.productDetailsRoute:
        final String productId = settings.arguments as String;
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) {
                  final cubit = ProductDetailsCubit();
                  cubit.getProductDetails(productId);
                  return cubit;
                },
                child: ProductDetailsPage(productId: productId),
              ),
          settings: settings,
        );
      case AppRoute.cartRoute:
        return MaterialPageRoute(
          builder: (_) => const CartPage(),
          settings: settings,
        );
      case AppRoute.settingsRoute:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );
      case AppRoute.profileRoute:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );
      case AppRoute.editProfileRoute:
        return MaterialPageRoute(
          builder: (_) => const EditProfile(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
