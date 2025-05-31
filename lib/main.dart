import 'package:expensetrackerbloc/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

void printHiveDbContents() async {
  var box = await Hive.openBox('catalogBox');
  var box1 = await Hive.openBox('db');
  var box2 = await Hive.openBox('catlog');
  var box3 = await Hive.openBox('catalogs');
  var box4 = await Hive.openBox('cash');
  var box5 = await Hive.openBox('selectButtonCotalog');

  print("🔍 Hive 'catalogBox' box ichidagi barcha ma'lumotlar:");
  print(box.toMap());
  print("🔍 Hive 'db' box ichidagi barcha ma'lumotlar:");
  print(box1.toMap());
  print("🔍 Hive 'catlog' box ichidagi barcha ma'lumotlar:");
  print(box2.toMap());
  print("🔍 Hive 'catalogs' box ichidagi barcha ma'lumotlar:");
  print(box3.toMap());
  print("🔍 Hive 'cash' box ichidagi barcha ma'lumotlar:");
  print(box4.toMap());
  print("🔍 Hive 'selectButtonCotalog' box ichidagi barcha ma'lumotlar:");
  print(box5.toMap());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('catalogBox');
  printHiveDbContents();
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
