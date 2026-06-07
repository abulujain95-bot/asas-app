import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/ad_banner_widget.dart';

// استدعاء جميع الصفحات
import 'home_screen.dart';
import 'calculator_screen.dart';
import 'loan_calculator_screen.dart';
import 'tracker_screen.dart';
import 'tips_screen.dart'; 
import 'settings_screen.dart'; // تأكد من وجود هذا السطر

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    HomeScreen(onNavigate: (index) => setState(() => _currentIndex = index)),
    const CalculatorScreen(),
    const LoanCalculatorScreen(),
    const TrackerScreen(),
    const TipsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isAr = settings.language == 'ar';

    final List<String> titles = [
      isAr ? 'الرئيسية' : 'Home',
      isAr ? 'حاسبة التكاليف' : 'Cost Calc',
      isAr ? 'القروض' : 'Loans',
      isAr ? 'المراحل' : 'Tracker',
      isAr ? 'نصائح' : 'Tips',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          // زر الإعدادات
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: isAr ? 'الإعدادات' : 'Settings',
            onPressed: () {
              // أمر الانتقال لصفحة الإعدادات
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const SettingsScreen())
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          const AdBannerWidget(), 
          BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey.shade500,
            selectedFontSize: 12,
            unselectedFontSize: 10,
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: titles[0]),
              BottomNavigationBarItem(icon: const Icon(Icons.calculate_outlined), activeIcon: const Icon(Icons.calculate), label: titles[1]),
              BottomNavigationBarItem(icon: const Icon(Icons.monetization_on_outlined), activeIcon: const Icon(Icons.monetization_on), label: titles[2]),
              BottomNavigationBarItem(icon: const Icon(Icons.playlist_add_check), activeIcon: const Icon(Icons.assignment_turned_in), label: titles[3]),
              BottomNavigationBarItem(icon: const Icon(Icons.lightbulb_outline), activeIcon: const Icon(Icons.lightbulb), label: titles[4]),
            ],
          ),
        ],
      ),
    );
  }
}