import 'package:e_commerce_app/Presentation/controller/home_cubit/home_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/porfile_cubit/cubit/profile_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/category_tab_view.dart';
import 'package:e_commerce_app/Presentation/views/widgets/home_tab_view.dart';
import 'package:e_commerce_app/Presentation/views/widgets/notifications_sheet.dart';
import 'package:e_commerce_app/Presentation/views/widgets/user_avatar.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:e_commerce_app/data/models/category_model.dart';
import 'package:e_commerce_app/domain/entities/category.dart';
import 'package:e_commerce_app/domain/entities/product.dart';
import 'package:e_commerce_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final TabController _tabController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openSearch(
    BuildContext context,
    List<Product> products,
    List<Category> categories,
  ) async {
    final selected = await showSearch<Product?>(
      context: context,
      delegate: _ProductSearchDelegate(
        products: products,
        categories: categories,
        hintText: context.tr('search'),
        isArabic: context.isArabic,
      ),
    );
    if (selected != null && context.mounted) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamed(AppRoute.productDetailsRoute, arguments: selected.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final softBg = isDark ? AppColors.surfaceSoftDark : AppColors.surfaceSoft;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.black;

    return BlocProvider(
      create: (context) => HomeCubit()..getHomeData(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, state) {
                        String username = 'Shopper';
                        String photoUrl = '';
                        if (state is ProfileLoaded) {
                          username = state.user.username;
                          photoUrl = state.user.photoUrl;
                        } else if (state is ProfileUpdatedSuccess) {
                          username = state.user.username;
                          photoUrl = state.user.photoUrl;
                        }
                        return Row(
                          children: [
                            UserAvatar(
                              username: username,
                              photoUrl: photoUrl,
                              radius: 22,
                              onTap: () {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pushNamed(AppRoute.editProfileRoute);
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.isArabic
                                        ? 'مرحباً، $username'
                                        : 'Hello, $username',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium!.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    context.isArabic
                                        ? 'مختارات حصرية وكتالوج مباشر'
                                        : 'Curated picks & live catalog',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall!.copyWith(
                                      color:
                                          isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.grey1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ValueListenableBuilder<List<InAppNotification>>(
                              valueListenable:
                                  NotificationService.instance
                                      .notificationsNotifier,
                              builder: (context, notifications, _) {
                                final unreadCount =
                                    notifications
                                        .where((n) => !n.isRead)
                                        .length;
                                return Stack(
                                  children: [
                                    IconButton(
                                      style: IconButton.styleFrom(
                                        backgroundColor: cardBg,
                                        side: BorderSide(color: borderColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.notifications_none_rounded,
                                        color: textColor,
                                      ),
                                      onPressed:
                                          () => showNotificationsSheet(context),
                                    ),
                                    if (unreadCount > 0)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: AppColors.accentColor,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            unreadCount > 9
                                                ? '9+'
                                                : '$unreadCount',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: AppColors.white1,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        final homeState = context.read<HomeCubit>().state;
                        final products =
                            homeState is HomeLoaded
                                ? homeState.products
                                : <Product>[];
                        final categories =
                            homeState is HomeLoaded
                                ? homeState.categories
                                : dummyCategories;
                        _openSearch(context, products, categories);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.grey1,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.tr('search'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.grey1,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.tune_rounded,
                              color:
                                  isDark
                                      ? AppColors.accentColor
                                      : AppColors.primaryColor,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: softBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.04,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        labelColor: textColor,
                        unselectedLabelColor:
                            isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.grey1,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        tabs: [
                          Tab(text: context.tr('nav_discover')),
                          Tab(text: context.tr('categories')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          HomeTabView(
                            selectedCategory: _selectedCategory,
                            onCategorySelected: (category) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            onShowAll: () {
                              if (_selectedCategory != null) {
                                setState(() {
                                  _selectedCategory = null;
                                });
                              } else {
                                context.read<HomeCubit>().getHomeData();
                              }
                            },
                          ),
                          CategoryTabView(
                            onCategoryTap: (categoryName) {
                              setState(() {
                                _selectedCategory =
                                    categoryName == 'All Products'
                                        ? null
                                        : categoryName;
                              });
                              _tabController.animateTo(0);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductSearchDelegate extends SearchDelegate<Product?> {
  final List<Product> products;
  final List<Category> categories;
  final String hintText;
  final bool isArabic;

  _ProductSearchDelegate({
    required this.products,
    required this.categories,
    required this.hintText,
    required this.isArabic,
  });

  @override
  String? get searchFieldLabel => hintText;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor:
            isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg,
        foregroundColor: isDark ? AppColors.textDark : AppColors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.grey1,
          fontSize: 15,
        ),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        isArabic
            ? Icons.arrow_forward_ios_rounded
            : Icons.arrow_back_ios_new_rounded,
        size: 18,
      ),
      onPressed: () => close(context, null),
    );
  }

  List<Category> _getCleanCategories() {
    final list =
        categories
            .where(
              (c) =>
                  c.id != 'all' &&
                  c.name.trim().toLowerCase() != 'all products' &&
                  c.name.trim().toLowerCase() != 'all',
            )
            .toList();
    if (list.isNotEmpty) return list;
    return dummyCategories
        .where(
          (c) =>
              c.id != 'all' &&
              c.name.trim().toLowerCase() != 'all products' &&
              c.name.trim().toLowerCase() != 'all',
        )
        .toList();
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('beauty') || lower.contains('جمال')) {
      return Icons.spa_rounded;
    }
    if (lower.contains('fragrance') || lower.contains('عطر')) {
      return Icons.local_florist_rounded;
    }
    if (lower.contains('shoe') || lower.contains('حذاء')) {
      return Icons.directions_run_rounded;
    }
    if (lower.contains('laptop') ||
        lower.contains('electronic') ||
        lower.contains('لابتوب')) {
      return Icons.laptop_mac_rounded;
    }
    if (lower.contains('shirt') ||
        lower.contains('dress') ||
        lower.contains('cloth') ||
        lower.contains('ملابس') ||
        lower.contains('قميص')) {
      return Icons.checkroom_rounded;
    }
    if (lower.contains('watch') || lower.contains('ساعة')) {
      return Icons.watch_rounded;
    }
    if (lower.contains('grocer') || lower.contains('بقالة')) {
      return Icons.shopping_basket_rounded;
    }
    if (lower.contains('furniture') || lower.contains('أثاث')) {
      return Icons.chair_rounded;
    }
    if (lower.contains('decoration') || lower.contains('ديكور')) {
      return Icons.weekend_rounded;
    }
    if (lower.contains('kitchen') || lower.contains('مطبخ')) {
      return Icons.soup_kitchen_rounded;
    }
    if (lower.contains('bag') || lower.contains('حقيبة')) {
      return Icons.shopping_bag_rounded;
    }
    if (lower.contains('phone') ||
        lower.contains('موبايل') ||
        lower.contains('هاتف')) {
      return Icons.smartphone_rounded;
    }
    return Icons.category_rounded;
  }

  bool _matchesQuery(Product p, String q, BuildContext context) {
    final lowerQ = q.toLowerCase();
    final nameLower = p.name.toLowerCase();
    final catLower = p.category.toLowerCase();
    final catArabic = context.trCategory(p.category).toLowerCase();
    return nameLower.contains(lowerQ) ||
        catLower.contains(lowerQ) ||
        catArabic.contains(lowerQ);
  }

  @override
  Widget buildResults(BuildContext context) {
    final trimmed = query.trim();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.black;

    final results =
        trimmed.isEmpty
            ? products
            : products
                .where((p) => _matchesQuery(p, trimmed, context))
                .toList();

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? AppColors.surfaceSoftDark
                          : AppColors.surfaceSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 36,
                  color: AppColors.grey1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('no_products_found'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('explore_categories_hint'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.grey1),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  query = '';
                  showSuggestions(context);
                },
                icon: const Icon(Icons.category_rounded, size: 18),
                label: Text(context.tr('suggested_categories')),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: isDark ? AppColors.surfaceSoftDark : AppColors.surfaceSoft,
          child: Row(
            children: [
              Text(
                '${results.length} ${context.tr('items_count')}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.grey1,
                ),
              ),
              const Spacer(),
              if (trimmed.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.filter_alt_rounded,
                        size: 13,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trimmed,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: _renderProductList(results, context)),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final trimmed = query.trim();

    // If query is empty, show Categories as suggestions (User Request!)
    if (trimmed.isEmpty) {
      return _buildCategoriesSuggestionView(context);
    }

    final cleanCats = _getCleanCategories();
    final matchingCategories =
        cleanCats.where((c) {
          final q = trimmed.toLowerCase();
          final nameEn = c.name.toLowerCase();
          final nameAr = context.trCategory(c.name).toLowerCase();
          return nameEn.contains(q) || nameAr.contains(q);
        }).toList();

    final matchingProducts =
        products.where((p) => _matchesQuery(p, trimmed, context)).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.black;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        if (matchingCategories.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(
                  Icons.category_rounded,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('matching_categories'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          ...matchingCategories.map((cat) {
            final catColor = Color(cat.bgColorValue);
            final translatedName = context.trCategory(cat.name);
            return ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(cat.name),
                  color: catColor,
                  size: 20,
                ),
              ),
              title: Text(
                translatedName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${context.tr('search_in_category')}: $translatedName',
                style: const TextStyle(fontSize: 12, color: AppColors.grey1),
              ),
              trailing: const Icon(Icons.north_west_rounded, size: 16),
              onTap: () {
                query = cat.name;
                showResults(context);
              },
            );
          }),
          const Divider(height: 20),
        ],
        if (matchingProducts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 18,
                  color: AppColors.accentColor,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('matching_products'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          ...matchingProducts.map((p) => _buildProductTile(p, context)),
        ] else if (matchingCategories.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                context.tr('no_products_found'),
                style: const TextStyle(color: AppColors.grey1, fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoriesSuggestionView(BuildContext context) {
    final cleanCategories = _getCleanCategories();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final softBg = isDark ? AppColors.surfaceSoftDark : AppColors.surfaceSoft;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.black;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? AppColors.primaryColor.withValues(alpha: 0.2)
                        : AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                size: 20,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('suggested_categories'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr('explore_categories_hint'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Quick Category Chips (Horizontal)
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cleanCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = cleanCategories[index];
              final catColor = Color(cat.bgColorValue);
              final translatedName = context.trCategory(cat.name);
              return ActionChip(
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                avatar: Icon(
                  _getCategoryIcon(cat.name),
                  size: 16,
                  color: catColor,
                ),
                label: Text(
                  translatedName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                backgroundColor: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: borderColor),
                ),
                onPressed: () {
                  query = cat.name;
                  showResults(context);
                },
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        // Categories List View
        ...cleanCategories.map((category) {
          final catColor = Color(category.bgColorValue);
          final translatedName = context.trCategory(category.name);
          final productCount =
              products
                  .where(
                    (p) =>
                        p.category.toLowerCase() ==
                        category.name.toLowerCase(),
                  )
                  .length;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  query = category.name;
                  showResults(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(category.name),
                          color: catColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translatedName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              productCount > 0
                                  ? '$productCount ${context.tr('items_count')}'
                                  : category.name,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.grey1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: softBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              size: 14,
                              color: AppColors.grey1,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isArabic
                                  ? Icons.arrow_back_ios_new_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: AppColors.grey1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _renderProductList(List<Product> list, BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => _buildProductTile(list[index], context),
    );
  }

  Widget _buildProductTile(Product p, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.black;
    final translatedCategory = context.trCategory(p.category);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          p.imgUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Container(
                width: 52,
                height: 52,
                color:
                    isDark ? AppColors.surfaceSoftDark : AppColors.surfaceSoft,
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.grey1,
                ),
              ),
        ),
      ),
      title: Text(
        p.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textColor,
        ),
      ),
      subtitle: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? AppColors.primaryColor.withValues(alpha: 0.2)
                      : AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              translatedCategory,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${p.price.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.accentColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
      trailing: Icon(
        isArabic
            ? Icons.arrow_back_ios_new_rounded
            : Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppColors.grey1,
      ),
      onTap: () => close(context, p),
    );
  }
}
