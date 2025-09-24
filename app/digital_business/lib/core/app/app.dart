import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/helper/app_routes.dart';
import '../../common/theme/app_colors.dart';
import '../constants/fonts.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,

        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(0.9),
          ),
          child: child!,
        ),
        debugShowCheckedModeBanner: false,
        title: 'Digital Business card',
        onGenerateRoute: Routes.generateRoute,
        initialRoute: Routes.splashScreen,
        theme: ThemeData(
          fontFamily: AppFonts.dmsans,
          primaryColor: AppColors.primaryColor,
          scaffoldBackgroundColor: AppColors.backgroundColor,
          useMaterial3: true,
        ),
      ),
    );
  }
}
