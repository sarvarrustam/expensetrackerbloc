import 'package:expensetrackerbloc/pages/home/home_page.dart';
import 'package:expensetrackerbloc/pages/report/bloc/hisobotlar_bloc.dart';
import 'package:expensetrackerbloc/pages/report/hisobotlar.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'pages/home/bloc/home_bloc.dart';
// import 'package:expensetrackerbloc/pages/report/'; // to'g'ri yo'l bo'lishi kerak

class AppRouter {
  static final GoRouter goRouter = GoRouter(initialLocation: '/home', routes: [
    GoRoute(
      path: '/home',
      name: "home",
      builder: (context, state) {
        return BlocProvider(
          create: (context) => HomeBloc()..add(HomeLocalReadEvent()),
          child: const HomePage(),
        );
      },
    ),
    GoRoute(
      path: '/hisoborlar',
      name: "hisoborlar",
      builder: (context, state) {
        return BlocProvider(
          create: (context) => HisobotBloc(),
          child: const HisobotPage(),
        );
      },
    ),
  ]);
}
