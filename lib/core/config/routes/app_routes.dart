import 'package:hisab/presentations/screens/history/arg/arguments.dart';
import 'package:hisab/presentations/screens/history/history_screen.dart';
import 'package:hisab/presentations/screens/home/test.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hisab/presentations/screens/home/home_screen.dart';
import 'package:hisab/presentations/screens/splash/splash_screen.dart';
part 'route_name.dart';

class AppRoutes {
  AppRoutes._();

  // Define the GoRouter instance
  static final GoRouter router = GoRouter(
    initialLocation: RouteName.splash,
    routes: [
      GoRoute(path: RouteName.splash, name: RouteName.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: RouteName.home, name: RouteName.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: RouteName.test, name: RouteName.test, builder: (context, state) => const Test()),
      GoRoute(
        path: RouteName.historyScreen,
        name: RouteName.historyScreen,
        builder: (context, state) {
          final arg = state.extra as HistoryScreenArguments;
          return  HistoryScreen(
            arg: arg,
          );
        },
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(body: Center(child: Text('Page not found: ${state.name}')));
    },
  );
}
