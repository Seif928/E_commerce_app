import 'package:e_commerce_app/Presentation/views/pages/cart_page.dart';
import 'package:e_commerce_app/Presentation/views/pages/favorites_page.dart';
import 'package:e_commerce_app/Presentation/views/pages/home_page.dart';
import 'package:e_commerce_app/Presentation/views/pages/profile_page.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class CustomBottomNavbar extends StatefulWidget {
  const CustomBottomNavbar({super.key});

  @override
  State<CustomBottomNavbar> createState() => _CustomBottomNavbarState();
}

class _CustomBottomNavbarState extends State<CustomBottomNavbar> {
  late final PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<ItemConfig> _navBarsItems(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.accentColor : AppColors.primaryColor;
    final inactiveColor =
        isDark ? AppColors.textSecondaryDark : AppColors.grey1;

    return [
      ItemConfig(
        icon: const Icon(CupertinoIcons.house_fill),
        inactiveIcon: const Icon(CupertinoIcons.house),
        title: context.tr('nav_discover'),
        activeForegroundColor: activeColor,
        inactiveForegroundColor: inactiveColor,
      ),
      ItemConfig(
        icon: const Icon(CupertinoIcons.bag_fill),
        inactiveIcon: const Icon(CupertinoIcons.bag),
        title: context.tr('nav_cart'),
        activeForegroundColor: activeColor,
        inactiveForegroundColor: inactiveColor,
      ),
      ItemConfig(
        icon: const Icon(CupertinoIcons.heart_fill),
        inactiveIcon: const Icon(CupertinoIcons.heart),
        title: context.tr('nav_saved'),
        activeForegroundColor: AppColors.accentColor,
        inactiveForegroundColor: inactiveColor,
      ),
      ItemConfig(
        icon: const Icon(CupertinoIcons.person_fill),
        inactiveIcon: const Icon(CupertinoIcons.person),
        title: context.tr('nav_account'),
        activeForegroundColor: activeColor,
        inactiveForegroundColor: inactiveColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final items = _navBarsItems(context);

    return Scaffold(
      body: PersistentTabView(
        controller: _controller,
        tabs: [
          PersistentTabConfig(item: items[0], screen: const HomePage()),
          PersistentTabConfig(item: items[1], screen: const CartPage()),
          PersistentTabConfig(item: items[2], screen: const FavoritesPage()),
          PersistentTabConfig(item: items[3], screen: const ProfilePage()),
        ],
        navBarBuilder:
            (navbarConfig) => Style6BottomNavBar(
              navBarConfig: navbarConfig,
              navBarDecoration: NavBarDecoration(
                color: navBg,
                border: Border(top: BorderSide(color: borderColor, width: 1)),
              ),
            ),
        backgroundColor: navBg,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: false,
      ),
    );
  }
}
