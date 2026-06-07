import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/main_navigation.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const AsasApp(),
    ),
  );
}

class AsasApp extends StatelessWidget {
  const AsasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'أَسَاس',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode, 
      
      builder: (context, child) {
        return Directionality(
          // تغيير الاتجاه تلقائياً بناءً على اللغة المحددة
          textDirection: settings.language == 'ar' ? TextDirection.rtl : TextDirection.ltr, 
          child: child!,
        );
      },
      
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1A365D),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A365D),
          brightness: Brightness.light,
          secondary: const Color(0xFFE27D60),
        ),
        textTheme: GoogleFonts.tajawalTextTheme(ThemeData.light().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1A365D),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0F203B),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F203B),
          brightness: Brightness.dark,
          secondary: const Color(0xFFE27D60),
        ),
        textTheme: GoogleFonts.tajawalTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0F203B),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      
      home: const MainNavigation(),
    );
  }
}