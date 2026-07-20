import 'package:flutter/material.dart';
import 'package:dashboard_screen/utility/app_constants.dart';
import 'views/splash_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const FarmerChatApp());
}

class FarmerChatApp extends StatelessWidget {
  const FarmerChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agri Dost',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: AppConstants.bgCream,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryGreen,
          primary: AppConstants.primaryGreen,
          secondary: AppConstants.secondaryGreen,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.primaryGreen,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}