// main.dart

import 'package:e_commerce_app/Presentation/controller/auth_cubit/auth_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/favorite_cubit/favorite_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/porfile_cubit/cubit/profile_cubit.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';

import 'package:e_commerce_app/core/utils/app_router.dart';
import 'package:e_commerce_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final navigtorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  await initialzeApp();
  runApp(MyApp());
}

Future<void> initialzeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await handleNotification();
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> handleNotification() async {
  //Handling background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // Taking permision
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  debugPrint('User granted permission: ${settings.authorizationStatus}');

  //Handling foreground messages

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      String title = message.notification!.title ?? '';
      String body = message.notification!.body ?? '';
      debugPrint('Message also contained a notification title: $title');

      debugPrint('Message also contained a notification body: $body');
      showDialog(
        context: navigtorKey.currentContext!,
        builder: (_) {
          return AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(navigtorKey.currentContext!).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('Message clicked!');
    debugPrint('Message data: ${message.data}');
    if (message.notification != null) {
      String title = message.notification!.title ?? '';
      String body = message.notification!.body ?? '';
      debugPrint('Message also contained a notification title: $title');

      debugPrint('Message also contained a notification body: $body');
      showDialog(
        context: navigtorKey.currentContext!,
        builder: (_) {
          return AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(navigtorKey.currentContext!).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('Message clicked!');
    debugPrint('Message data: ${message.data}');
    final messageData = message.data;
    if (messageData['product_id'] != null) {
      Navigator.of(navigtorKey.currentContext!).pushNamed(
        AppRoute.productDetailsRoute,
        arguments: {messageData['product_id']},
      );
    } else if (messageData['route'] == "") {
      Navigator.of(navigtorKey.currentContext!).pushNamed(AppRoute.cartRoute);
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = AuthCubit();
            cubit.checkAuth();
            return cubit;
          },
        ),
        BlocProvider(create: (context) => ProfileCubit()..getUserData()),
        BlocProvider(
          create: (context) => FavoriteCubit()..getFavoriteProducts(),
        ),
      ],

      child: Builder(
        builder: (context) {
          final authCubit = BlocProvider.of<AuthCubit>(context);
          return BlocBuilder<AuthCubit, AuthState>(
            bloc: authCubit,
            buildWhen:
                (previous, current) =>
                    current is AuthDone || current is AuthInitial,
            builder: (context, state) {
              return MaterialApp(
                navigatorKey: navigtorKey,
                debugShowCheckedModeBanner: false,
                title: "E-commerce App",
                initialRoute:
                    state is AuthDone
                        ? AppRoute.homeRoute
                        : AppRoute.loginRoute,
                onGenerateRoute: AppRouter.onGenerateRoute,
              );
            },
          );
        },
      ),
    );
  }
}
