import 'package:e_commerce_app/Presentation/views/pages/cart_page.dart';
import 'package:e_commerce_app/Presentation/views/pages/favorites_page.dart';
import 'package:e_commerce_app/Presentation/views/pages/home_page.dart';
import 'package:e_commerce_app/Presentation/views/pages/profile_page.dart';
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
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController();
  }

  List<Widget> _buildScreens(BuildContext context) {
    return [
      const HomePage(),
      const CartPage(),
      const FavoritesPage(),
      const ProfilePage(),
    ];
  }

  List<ItemConfig> _navBarsItems() {
    return [
      ItemConfig(
        icon: const Icon(CupertinoIcons.home),
        title: "Home",
        activeForegroundColor: Theme.of(context).primaryColor,
        // activeColorPrimary: Theme.of(context).primaryColor,
        // inactiveColorPrimary: AppColors.grey,
      ),
      ItemConfig(
        icon: const Icon(CupertinoIcons.cart),
        title: "Cart",
        activeForegroundColor: Theme.of(context).primaryColor,
        // activeColorPrimary: Theme.of(context).primaryColor,
        // inactiveColorPrimary: AppColors.grey,
      ),
      ItemConfig(
        icon: const Icon(CupertinoIcons.heart),
        title: "Favorites",
        activeForegroundColor: Theme.of(context).primaryColor,
        // activeColorPrimary: Theme.of(context).primaryColor,
        // inactiveColorPrimary: AppColors.grey,
      ),
      ItemConfig(
        icon: const Icon(CupertinoIcons.person),
        title: "Profile",
        activeForegroundColor: Theme.of(context).primaryColor,
        // activeColorPrimary: Theme.of(context).primaryColor,
        // inactiveColorPrimary: AppColors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        controller: _controller,
        tabs: [
          PersistentTabConfig(
            item: _navBarsItems()[0],
            screen: _buildScreens(context)[0],
          ),
          PersistentTabConfig(
            item: _navBarsItems()[1],
            screen: _buildScreens(context)[1],
          ),
          PersistentTabConfig(
            item: _navBarsItems()[2],
            screen: _buildScreens(context)[2],
          ),
          PersistentTabConfig(
            item: _navBarsItems()[3],
            screen: _buildScreens(context)[3],
          ),
        ],
        navBarBuilder:
            (navbarConfig) => Style1BottomNavBar(navBarConfig: navbarConfig),
        onTabChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: AppColors.white1, // Default is Colors.white.
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset:
            true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: false, // Default is true.
      ),
    );
  }
}
