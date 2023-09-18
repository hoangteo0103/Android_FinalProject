import 'package:antap/main_screen.dart';
import 'package:antap/screens/map/restaurant_detail/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:antap/screens/auth/home_screen.dart';
import 'package:antap/screens/auth/login_screen.dart';
import 'package:antap/screens/auth/signup_screen.dart';
import 'package:antap/screens/image_video_post/customize_screen.dart';
import 'package:antap/screens/image_video_post/customize_image_screen.dart';
import 'package:antap/screens/image_video_post/customize_video_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:antap/screens/map/pop_up/popup_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
  // runApp(const MaterialApp(home: ExampleApp()));
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontFamily: 'Ubuntu',
        ),
      )),
      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        SignUpScreen.id: (context) => SignUpScreen(),
        MainScreen.id: (context) => MainScreen(),
        CustomizeImageScreen.id: (context) => CustomizeImageScreen(),
        CustomizeVideoScreen.id: (context) => CustomizeVideoScreen(),
        RestaurantDetailsScreen.id: (context) =>  RestaurantDetailsScreen(),
      },
    );
  });
  }
}
