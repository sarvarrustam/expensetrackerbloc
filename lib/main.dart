import 'package:expensetrackerbloc/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('catalogBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.goRouter,
          theme: ThemeData(
              colorScheme: ColorScheme.light(
                  surface: Colors.grey.shade100,
                  onSurface: Colors.black,
                  primary: const Color(0xFF00B2E7),
                  secondary: const Color(0xFFE064F7),
                  tertiary: const Color(0xFFFF8D6C),
                  outline: Colors.grey)),
        );
      },
    );
  }
}
