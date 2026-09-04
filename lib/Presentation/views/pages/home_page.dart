import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Presentation/controller/home_cubit/home_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/category_tab_view.dart';
import 'package:e_commerce_app/Presentation/views/widgets/home_tab_view.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..getHomeData(),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: const Padding(
              padding: EdgeInsets.all(4.0),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.grey1,
                backgroundImage: CachedNetworkImageProvider(
                  ImageUtils.userImgUrl,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seif Sallam',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Let\'s go shopping!',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              InkWell(onTap: () {}, child: const Icon(Icons.search_outlined)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(child: Icon(Icons.notifications_none_rounded)),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  unselectedLabelColor: AppColors.grey1,
                  tabs: const [Tab(text: 'Home'), Tab(text: 'Category')],
                ),
                const SizedBox(height: 24.0),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [HomeTabView(), CategoryTabView()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
