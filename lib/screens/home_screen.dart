import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  // وظيفة لاستقبال أمر الانتقال بين الصفحات وتحديث شريط الملاحة السفلي
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // عرض أيقونة التطبيق لتعزيز الهوية البصرية
          Image.asset(
            'assets/icon/app_icon.png',
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.architecture, 
              size: 100, 
              color: Color(0xFF1A365D),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'مرحباً بك في أَسَاس',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          
          const SizedBox(height: 10),
          
          const Text(
            'دليلك المتكامل لحساب تكاليف ومراحل البناء',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'الوصول السريع',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          
          const SizedBox(height: 15),
          
          // 1. بطاقة الوصول لحاسبة التكاليف (مؤشر 1)
          _buildQuickAccessCard(
            context,
            icon: Icons.calculate,
            title: 'حاسبة التكاليف',
            subtitle: 'احسب التكلفة التقديرية لمشروعك بدقة',
            onTap: () => onNavigate(1), 
          ),
          
          const SizedBox(height: 15),
          
          // 2. بطاقة الوصول لحاسبة القروض الذكية (مؤشر 2)
          _buildQuickAccessCard(
            context,
            icon: Icons.monetization_on,
            title: 'حاسبة القروض والتمويل',
            subtitle: 'حلل قسطك الشهري ونسبة فائدة البنك بدقة',
            onTap: () => onNavigate(2), 
          ),
          
          const SizedBox(height: 15),
          
          // 3. بطاقة الوصول لمتعقب مراحل البناء (مؤشر 3)
          _buildQuickAccessCard(
            context,
            icon: Icons.checklist_rtl,
            title: 'مراحل البناء',
            subtitle: 'تابع تقدم مشروعك خطوة بخطوة',
            onTap: () => onNavigate(3),
          ),
        ],
      ),
    );
  }

  // ويدجت مساعد لتصميم بطاقات الوصول السريع بشكل موحد وأنيق
  Widget _buildQuickAccessCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          radius: 25,
          child: Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 28),
        ),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle, style: const TextStyle(fontSize: 14)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}